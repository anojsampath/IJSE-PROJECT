package lk.ijse.moviebooking.repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;
import lk.ijse.moviebooking.entity.Show;
import lk.ijse.moviebooking.enums.Types.ShowStatus;
import org.springframework.data.jpa.repository.*;

public interface ShowRepository extends JpaRepository<Show, Long> {
    interface References {
        Long getMovieId();

        Long getTheatreId();
    }

    @Query("select s.movie.id as movieId, s.theatre.id as theatreId from Show s where s.id = :id")
    Optional<References> findReferences(Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select s from Show s where s.id = :id")
    Optional<Show> lockById(Long id);

    List<Show> findByMovieId(Long movieId);

    List<Show> findByMovieIdAndStatus(Long movieId, ShowStatus status);

    List<Show> findByTheatreIdAndStatus(Long theatreId, ShowStatus status);

    boolean existsByMovieId(Long movieId);

    boolean existsByTheatreId(Long theatreId);

    boolean existsByTheatreIdAndStatus(Long theatreId, ShowStatus status);
}
