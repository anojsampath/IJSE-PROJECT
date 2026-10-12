package lk.ijse.moviebooking.service;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.entity.*;
import lk.ijse.moviebooking.enums.Types.*;
import lk.ijse.moviebooking.exception.ApiException;
import lk.ijse.moviebooking.repository.*;
import lk.ijse.moviebooking.security.Actor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class BookingService {
    private final BookingRepository bookings;
    private final UserRepository users;
    private final ShowRepository shows;
    private final PaymentRepository payments;
    private final BookingWorkflow workflow;
    private final Clock clock;

    @Transactional
    public BookingView create(BookingRequest request, Actor actor) {
        actor.requireCustomer();
        Show show = workflow.lockShow(request.showId());
        workflow.requireBookable(show);
        if (request.seatNumbers() == null || request.seatNumbers().isEmpty())
            throw ApiException.invalid("At least one seat is required");
        Set<String> seats = new LinkedHashSet<>();
        for (String seat : request.seatNumbers()) {
            if (seat == null || seat.isBlank() || !seats.add(seat.trim().toUpperCase(Locale.ROOT)))
                throw ApiException.invalid("Seats must be nonblank and unique");
        }
        if (request.numberOfTickets() != seats.size())
            throw ApiException.invalid("Ticket count must match selected seats");
        if (!new HashSet<>(SeatLayout.seats(show.getTheatre().getCapacity())).containsAll(seats))
            throw ApiException.invalid("A selected seat is outside theatre capacity");
        if (!Collections.disjoint(reserved(show.getId()), seats))
            throw ApiException.conflict("A selected seat is already booked");
        Booking booking = new Booking();
        booking.setUser(users.findById(actor.id()).orElseThrow(() -> ApiException.missing("User")));
        booking.setShow(show);
        booking.setSeatNumbers(seats);
        booking.setNumberOfTickets(seats.size());
        booking.setTotalAmount(show.getTicketPrice().multiply(BigDecimal.valueOf(seats.size())));
        booking.setBookingDate(clock.instant());
        booking.setStatus(BookingStatus.PENDING);
        bookings.saveAndFlush(booking);
        log.info(
                "Booking created bookingId={} userId={} showId={}",
                booking.getId(),
                actor.id(),
                show.getId());
        return Responses.booking(booking);
    }

    public BookingView get(Long id, Actor actor) {
        Booking booking = find(id);
        actor.requireOwnerOrAdmin(booking.getUser().getId());
        return Responses.booking(booking);
    }

    public List<BookingView> mine(Actor actor) {
        actor.requireCustomer();
        return bookings.findByUserIdOrderByBookingDateDesc(actor.id()).stream()
                .map(Responses::booking)
                .toList();
    }

    public List<BookingView> all() {
        return bookings.findAll().stream().map(Responses::booking).toList();
    }

    @Transactional
    public BookingView cancel(Long id, Actor actor) {
        Booking booking = lockedBooking(id);
        actor.requireOwnerOrAdmin(booking.getUser().getId());
        if (booking.getStatus() != BookingStatus.CANCELLED) {
            if (!booking.getShow().startsAt().isAfter(LocalDateTime.now(clock)))
                throw ApiException.conflict("Booking cannot be canceled after the show starts");
            workflow.cancel(booking);
        }
        return Responses.booking(booking);
    }

    @Transactional
    public BookingView updateStatus(Long id, BookingStatusRequest request, Actor actor) {
        if (request.status() == BookingStatus.CANCELLED) return cancel(id, actor);
        Booking booking = lockedBooking(id);
        if (booking.getStatus() == BookingStatus.CANCELLED)
            throw ApiException.conflict("Canceled bookings cannot reopen");
        if (request.status() == BookingStatus.CONFIRMED) {
            if (payments.findByBookingId(id)
                    .filter(p -> p.getStatus() == PaymentStatus.COMPLETED)
                    .isEmpty())
                throw ApiException.conflict("Booking confirmation requires a completed payment");
        } else if (booking.getStatus() != BookingStatus.PENDING) {
            throw ApiException.conflict("Confirmed bookings cannot return to PENDING");
        }
        booking.setStatus(request.status());
        log.info(
                "Booking status updated bookingId={} status={} actorId={}",
                id,
                request.status(),
                actor.id());
        return Responses.booking(booking);
    }

    public SeatsView seats(Long showId) {
        Show show = shows.findById(showId).orElseThrow(() -> ApiException.missing("Show"));
        List<String> total = SeatLayout.seats(show.getTheatre().getCapacity());
        Set<String> occupied = reserved(showId);
        boolean bookable =
                show.getStatus() == ShowStatus.SCHEDULED
                        && show.startsAt().isAfter(LocalDateTime.now(clock));
        return new SeatsView(
                showId,
                total.size(),
                bookable,
                total,
                total.stream().filter(occupied::contains).toList(),
                total.stream().filter(s -> !occupied.contains(s)).toList());
    }

    private Set<String> reserved(Long showId) {
        return bookings.findByShowIdAndStatusNot(showId, BookingStatus.CANCELLED).stream()
                .flatMap(b -> b.getSeatNumbers().stream())
                .collect(Collectors.toSet());
    }

    private Booking lockedBooking(Long id) {
        Long showId = bookings.findShowId(id).orElseThrow(() -> ApiException.missing("Booking"));
        workflow.lockShow(showId);
        return find(id);
    }

    private Booking find(Long id) {
        return bookings.findById(id).orElseThrow(() -> ApiException.missing("Booking"));
    }
}
