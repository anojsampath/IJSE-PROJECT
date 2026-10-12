package lk.ijse.moviebooking.repository;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import lk.ijse.moviebooking.entity.Movie;
import org.springframework.data.jpa.repository.*;

public interface MovieRepository extends JpaRepository<Movie, Long> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select m from Movie m where m.id = :id")
    Optional<Movie> lockById(Long id);
}
