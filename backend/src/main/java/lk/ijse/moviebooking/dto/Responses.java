package lk.ijse.moviebooking.dto;

import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import lk.ijse.moviebooking.entity.*;
import lk.ijse.moviebooking.enums.Types.*;

public final class Responses {
    private Responses() {}

    public record UserView(Long id, String name, String email, Role role) {}

    public record TokenView(String token, String tokenType, long expiresIn, UserView user) {}

    public record MovieView(
            Long id,
            String title,
            String description,
            int duration,
            String language,
            String genre,
            LocalDate releaseDate,
            MovieStatus status) {}

    public record TheatreView(
            Long id, String name, String location, int capacity, TheatreStatus status) {}

    public record ShowView(
            Long id,
            Long movieId,
            Long theatreId,
            LocalDate showDate,
            LocalTime showTime,
            BigDecimal ticketPrice,
            ShowStatus status) {}

    public record BookingView(
            Long id,
            Long userId,
            Long showId,
            List<String> seatNumbers,
            int numberOfTickets,
            BigDecimal totalAmount,
            Instant bookingDate,
            BookingStatus status) {}

    public record PaymentView(
            Long id,
            Long bookingId,
            BigDecimal amount,
            Instant paymentDate,
            PaymentMethod paymentMethod,
            PaymentStatus status) {}

    public record PaymentStatusView(Long id, PaymentStatus status) {}

    public record SeatsView(
            Long showId,
            int capacity,
            boolean bookable,
            List<String> totalSeats,
            List<String> reservedSeats,
            List<String> availableSeats) {}

    public static UserView user(User u) {
        return new UserView(u.getId(), u.getName(), u.getEmail(), u.getRole());
    }

    public static MovieView movie(Movie m) {
        return new MovieView(
                m.getId(),
                m.getTitle(),
                m.getDescription(),
                m.getDuration(),
                m.getLanguage(),
                m.getGenre(),
                m.getReleaseDate(),
                m.getStatus());
    }

    public static TheatreView theatre(Theatre t) {
        return new TheatreView(
                t.getId(), t.getName(), t.getLocation(), t.getCapacity(), t.getStatus());
    }

    public static ShowView show(Show s) {
        return new ShowView(
                s.getId(),
                s.getMovie().getId(),
                s.getTheatre().getId(),
                s.getShowDate(),
                s.getShowTime(),
                s.getTicketPrice(),
                s.getStatus());
    }

    public static BookingView booking(Booking b) {
        return new BookingView(
                b.getId(),
                b.getUser().getId(),
                b.getShow().getId(),
                b.getSeatNumbers().stream().sorted().toList(),
                b.getNumberOfTickets(),
                b.getTotalAmount(),
                b.getBookingDate(),
                b.getStatus());
    }

    public static PaymentView payment(Payment p) {
        return new PaymentView(
                p.getId(),
                p.getBooking().getId(),
                p.getAmount(),
                p.getPaymentDate(),
                p.getPaymentMethod(),
                p.getStatus());
    }
}
