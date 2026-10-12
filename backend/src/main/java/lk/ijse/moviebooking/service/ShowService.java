package lk.ijse.moviebooking.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.*;
import lk.ijse.moviebooking.dto.Requests.ShowRequest;
import lk.ijse.moviebooking.dto.Responses;
import lk.ijse.moviebooking.dto.Responses.ShowView;
import lk.ijse.moviebooking.entity.*;
import lk.ijse.moviebooking.enums.Types.*;
import lk.ijse.moviebooking.exception.ApiException;
import lk.ijse.moviebooking.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ShowService {
    private final ShowRepository shows;
    private final MovieRepository movies;
    private final TheatreRepository theatres;
    private final BookingRepository bookings;
    private final BookingWorkflow workflow;
    private final Clock clock;

    public List<ShowView> all() {
        return shows.findAll().stream().map(Responses::show).toList();
    }

    public ShowView get(Long id) {
        return Responses.show(shows.findById(id).orElseThrow(() -> ApiException.missing("Show")));
    }

    public List<ShowView> forMovie(Long id) {
        if (!movies.existsById(id)) throw ApiException.missing("Movie");
        return shows.findByMovieId(id).stream().map(Responses::show).toList();
    }

    @Transactional
    public ShowView create(ShowRequest request) {
        if (request.status() != ShowStatus.SCHEDULED)
            throw ApiException.invalid("New shows must be SCHEDULED");
        Movie movie =
                movies.lockById(request.movieId()).orElseThrow(() -> ApiException.missing("Movie"));
        Theatre theatre =
                theatres.lockById(request.theatreId())
                        .orElseThrow(() -> ApiException.missing("Theatre"));
        validateSchedule(request, movie, theatre, null);
        Show show = new Show();
        apply(show, request, movie, theatre);
        shows.save(show);
        log.info("Show created showId={}", show.getId());
        return Responses.show(show);
    }

    @Transactional
    public ShowView update(Long id, ShowRequest request) {
        // Read scalar references first, not an entity that could become stale while waiting for
        // locks.
        var references = shows.findReferences(id).orElseThrow(() -> ApiException.missing("Show"));
        Map<Long, Movie> lockedMovies = new HashMap<>();
        for (Long movieId : new TreeSet<>(List.of(references.getMovieId(), request.movieId()))) {
            lockedMovies.put(
                    movieId,
                    movies.lockById(movieId).orElseThrow(() -> ApiException.missing("Movie")));
        }
        Map<Long, Theatre> lockedTheatres = new HashMap<>();
        for (Long theatreId :
                new TreeSet<>(List.of(references.getTheatreId(), request.theatreId()))) {
            lockedTheatres.put(
                    theatreId,
                    theatres.lockById(theatreId)
                            .orElseThrow(() -> ApiException.missing("Theatre")));
        }
        Show show = workflow.lockShow(id);
        if (!show.getMovie().getId().equals(references.getMovieId())
                || !show.getTheatre().getId().equals(references.getTheatreId()))
            throw ApiException.conflict("Show changed concurrently; refresh and retry");
        boolean detailsChanged = detailsChanged(show, request);
        if (show.getStatus() != ShowStatus.SCHEDULED) {
            if (detailsChanged || request.status() != show.getStatus())
                throw ApiException.conflict("Terminal shows cannot be changed or reopened");
            return Responses.show(show);
        }
        if (request.status() != show.getStatus()) {
            if (detailsChanged)
                throw ApiException.conflict("Change show status separately from screening details");
            if (request.status() == ShowStatus.COMPLETED
                    && show.endsAt().isAfter(LocalDateTime.now(clock)))
                throw ApiException.conflict("Show cannot complete before its end time");
            if (request.status() == ShowStatus.CANCELLED) {
                bookings.findByShowIdAndStatusNot(id, BookingStatus.CANCELLED)
                        .forEach(workflow::cancel);
            }
            show.setStatus(request.status());
        } else if (detailsChanged) {
            if (bookings.existsByShowId(id))
                throw ApiException.conflict("Screening details cannot change once bookings exist");
            Movie movie = lockedMovies.get(request.movieId());
            Theatre theatre = lockedTheatres.get(request.theatreId());
            validateSchedule(request, movie, theatre, id);
            apply(show, request, movie, theatre);
        }
        log.info("Show updated showId={} status={}", id, show.getStatus());
        return Responses.show(show);
    }

    @Transactional
    public void delete(Long id) {
        Show show = workflow.lockShow(id);
        if (bookings.existsByShowId(id)) throw ApiException.conflict("Show has booking history");
        shows.delete(show);
        shows.flush();
        log.info("Show deleted showId={}", id);
    }

    private void validateSchedule(
            ShowRequest request, Movie movie, Theatre theatre, Long excludedId) {
        if (movie.getStatus() == MovieStatus.ENDED)
            throw ApiException.conflict("Ended movies cannot receive new shows");
        if (theatre.getStatus() != TheatreStatus.ACTIVE)
            throw ApiException.conflict("Theatre is inactive");
        LocalDateTime start = LocalDateTime.of(request.showDate(), request.showTime());
        if (!start.isAfter(LocalDateTime.now(clock)))
            throw ApiException.invalid("Show start must be in the future");
        LocalDateTime end = start.plusMinutes(movie.getDuration());
        boolean overlaps =
                shows.findByTheatreIdAndStatus(theatre.getId(), ShowStatus.SCHEDULED).stream()
                        .filter(s -> !s.getId().equals(excludedId))
                        .anyMatch(s -> start.isBefore(s.endsAt()) && end.isAfter(s.startsAt()));
        if (overlaps) throw ApiException.conflict("Theatre already has an overlapping show");
    }

    private boolean detailsChanged(Show show, ShowRequest request) {
        return !show.getMovie().getId().equals(request.movieId())
                || !show.getTheatre().getId().equals(request.theatreId())
                || !show.getShowDate().equals(request.showDate())
                || !show.getShowTime().equals(request.showTime())
                || show.getTicketPrice().compareTo(request.ticketPrice()) != 0;
    }

    private void apply(Show show, ShowRequest request, Movie movie, Theatre theatre) {
        show.setMovie(movie);
        show.setTheatre(theatre);
        show.setShowDate(request.showDate());
        show.setShowTime(request.showTime());
        show.setTicketPrice(request.ticketPrice());
        show.setStatus(request.status());
    }
}
