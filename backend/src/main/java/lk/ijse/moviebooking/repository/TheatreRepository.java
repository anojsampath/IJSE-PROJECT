package lk.ijse.moviebooking.repository;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import lk.ijse.moviebooking.entity.Theatre;
import org.springframework.data.jpa.repository.*;

public interface TheatreRepository extends JpaRepository<Theatre, Long> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from Theatre t where t.id = :id")
    Optional<Theatre> lockById(Long id);
}
