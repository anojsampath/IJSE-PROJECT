package lk.ijse.moviebooking.service;

import java.time.Clock;
import java.time.LocalDateTime;
import lk.ijse.moviebooking.entity.*;
import lk.ijse.moviebooking.enums.Types.*;
import lk.ijse.moviebooking.exception.ApiException;
import lk.ijse.moviebooking.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.*;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(propagation = Propagation.MANDATORY)
public class BookingWorkflow {
    private final ShowRepository shows;
    private final PaymentRepository payments;
    private final Clock clock;

    public Show lockShow(Long id) {
        return shows.lockById(id).orElseThrow(() -> ApiException.missing("Show"));
    }

    public void requireBookable(Show show) {
        if (show.getStatus() != ShowStatus.SCHEDULED
                || !show.startsAt().isAfter(LocalDateTime.now(clock)))
            throw ApiException.conflict("Show is not open for bookings or payments");
    }

    // The caller must hold the show's write lock before reading or changing bookings/payments.
    public void cancel(Booking booking) {
        if (booking.getStatus() == BookingStatus.CANCELLED) return;
        payments.findByBookingId(booking.getId())
                .ifPresent(
                        payment -> {
                            if (payment.getStatus() == PaymentStatus.COMPLETED) {
                                payment.setStatus(PaymentStatus.REFUNDED);
                                log.info("Simulated refund recorded paymentId={}", payment.getId());
                            } else if (payment.getStatus() == PaymentStatus.PENDING) {
                                payment.setStatus(PaymentStatus.FAILED);
                                payment.setPaymentDate(clock.instant());
                            }
                        });
        booking.setStatus(BookingStatus.CANCELLED);
        log.info("Booking canceled bookingId={}", booking.getId());
    }
}
