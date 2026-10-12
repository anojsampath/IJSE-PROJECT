package lk.ijse.moviebooking.repository;

import java.util.List;
import java.util.Optional;
import lk.ijse.moviebooking.entity.Booking;
import lk.ijse.moviebooking.enums.Types.BookingStatus;
import org.springframework.data.jpa.repository.*;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByUserIdOrderByBookingDateDesc(Long userId);

    List<Booking> findByShowIdAndStatusNot(Long showId, BookingStatus status);

    boolean existsByShowId(Long showId);

    boolean existsByUserId(Long userId);

    @Query("select b.show.id from Booking b where b.id = :id")
    Optional<Long> findShowId(Long id);
}
