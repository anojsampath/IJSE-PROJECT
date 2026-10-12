package lk.ijse.moviebooking.repository;

import java.util.Optional;
import lk.ijse.moviebooking.entity.Payment;
import org.springframework.data.jpa.repository.*;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    boolean existsByBookingId(Long bookingId);

    Optional<Payment> findByBookingId(Long bookingId);

    @Query("select p.booking.show.id from Payment p where p.id = :id")
    Optional<Long> findShowId(Long id);
}
