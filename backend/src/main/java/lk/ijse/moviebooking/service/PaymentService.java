package lk.ijse.moviebooking.service;

import java.time.Clock;
import java.util.List;
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
public class PaymentService {
    private final PaymentRepository payments;
    private final BookingRepository bookings;
    private final BookingWorkflow workflow;
    private final Clock clock;

    @Transactional
    public PaymentView create(PaymentRequest request, Actor actor) {
        actor.requireCustomer();
        Long showId =
                bookings.findShowId(request.bookingId())
                        .orElseThrow(() -> ApiException.missing("Booking"));
        workflow.lockShow(showId);
        Booking booking =
                bookings.findById(request.bookingId())
                        .orElseThrow(() -> ApiException.missing("Booking"));
        actor.requireOwnerOrAdmin(booking.getUser().getId());
        requirePayable(booking);
        if (payments.existsByBookingId(booking.getId()))
            throw ApiException.conflict("Booking already has a payment; reuse that payment");
        Payment payment = new Payment();
        payment.setBooking(booking);
        payment.setAmount(booking.getTotalAmount());
        payment.setPaymentMethod(request.paymentMethod());
        payment.setStatus(PaymentStatus.PENDING);
        payments.saveAndFlush(payment);
        log.info(
                "Simulated payment created paymentId={} bookingId={}",
                payment.getId(),
                booking.getId());
        return Responses.payment(payment);
    }

    @Transactional
    public PaymentView process(Long id, ProcessPayment request, Actor actor) {
        actor.requireCustomer();
        Long showId = payments.findShowId(id).orElseThrow(() -> ApiException.missing("Payment"));
        workflow.lockShow(showId);
        Payment payment = find(id);
        Booking booking = payment.getBooking();
        actor.requireOwnerOrAdmin(booking.getUser().getId());
        if (payment.getStatus() == PaymentStatus.COMPLETED
                || payment.getStatus() == PaymentStatus.REFUNDED)
            throw ApiException.conflict("Completed or refunded payments cannot be processed again");
        requirePayable(booking);
        payment.setPaymentDate(clock.instant());
        if (request.outcome() == PaymentOutcome.COMPLETED) {
            payment.setStatus(PaymentStatus.COMPLETED);
            booking.setStatus(BookingStatus.CONFIRMED);
        } else {
            payment.setStatus(PaymentStatus.FAILED);
        }
        log.info("Simulated payment processed paymentId={} status={}", id, payment.getStatus());
        return Responses.payment(payment);
    }

    public PaymentView get(Long id, Actor actor) {
        Payment payment = find(id);
        actor.requireOwnerOrAdmin(payment.getBooking().getUser().getId());
        return Responses.payment(payment);
    }

    public PaymentStatusView status(Long id, Actor actor) {
        PaymentView payment = get(id, actor);
        return new PaymentStatusView(payment.id(), payment.status());
    }

    public List<PaymentView> all() {
        return payments.findAll().stream().map(Responses::payment).toList();
    }

    private void requirePayable(Booking booking) {
        if (booking.getStatus() != BookingStatus.PENDING)
            throw ApiException.conflict("Only pending bookings can be paid for");
        workflow.requireBookable(booking.getShow());
    }

    private Payment find(Long id) {
        return payments.findById(id).orElseThrow(() -> ApiException.missing("Payment"));
    }
}
