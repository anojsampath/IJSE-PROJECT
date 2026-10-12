package lk.ijse.moviebooking.service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.entity.*;
import lk.ijse.moviebooking.enums.Types.ShowStatus;
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
public class CatalogService {
    private final MovieRepository movies;
    private final TheatreRepository theatres;
    private final ShowRepository shows;
    private final Clock clock;

    public List<MovieView> movies() {
        return movies.findAll().stream().map(Responses::movie).toList();
    }

    public MovieView movie(Long id) {
        return Responses.movie(
                movies.findById(id).orElseThrow(() -> ApiException.missing("Movie")));
    }

    public List<TheatreView> theatres() {
        return theatres.findAll().stream().map(Responses::theatre).toList();
    }

    public TheatreView theatre(Long id) {
        return Responses.theatre(
                theatres.findById(id).orElseThrow(() -> ApiException.missing("Theatre")));
    }

    @Transactional
    public MovieView createMovie(MovieRequest request) {
        Movie movie = new Movie();
        apply(movie, request);
        movies.save(movie);
        log.info("Movie created movieId={}", movie.getId());
        return Responses.movie(movie);
    }

    @Transactional
    public MovieView updateMovie(Long id, MovieRequest request) {
        Movie movie = movies.lockById(id).orElseThrow(() -> ApiException.missing("Movie"));
        if (movie.getDuration() != request.duration()
                && shows.findByMovieIdAndStatus(id, ShowStatus.SCHEDULED).stream()
                        .anyMatch(s -> s.endsAt().isAfter(LocalDateTime.now(clock))))
            throw ApiException.conflict(
                    "Duration cannot change while unfinished scheduled shows exist");
        apply(movie, request);
        log.info("Movie updated movieId={}", id);
        return Responses.movie(movie);
    }

    @Transactional
    public void deleteMovie(Long id) {
        Movie movie = movies.lockById(id).orElseThrow(() -> ApiException.missing("Movie"));
        if (shows.existsByMovieId(id)) throw ApiException.conflict("Movie has show history");
        movies.delete(movie);
        movies.flush();
        log.info("Movie deleted movieId={}", id);
    }

    @Transactional
    public TheatreView createTheatre(TheatreRequest request) {
        Theatre theatre = new Theatre();
        apply(theatre, request);
        theatres.save(theatre);
        log.info("Theatre created theatreId={}", theatre.getId());
        return Responses.theatre(theatre);
    }

    @Transactional
    public TheatreView updateTheatre(Long id, TheatreRequest request) {
        Theatre theatre = theatres.lockById(id).orElseThrow(() -> ApiException.missing("Theatre"));
        if (theatre.getCapacity() != request.capacity()
                && shows.existsByTheatreIdAndStatus(id, ShowStatus.SCHEDULED))
            throw ApiException.conflict("Capacity cannot change while scheduled shows exist");
        apply(theatre, request);
        log.info("Theatre updated theatreId={}", id);
        return Responses.theatre(theatre);
    }

    @Transactional
    public void deleteTheatre(Long id) {
        Theatre theatre = theatres.lockById(id).orElseThrow(() -> ApiException.missing("Theatre"));
        if (shows.existsByTheatreId(id)) throw ApiException.conflict("Theatre has show history");
        theatres.delete(theatre);
        theatres.flush();
        log.info("Theatre deleted theatreId={}", id);
    }

    private void apply(Movie movie, MovieRequest request) {
        movie.setTitle(request.title().trim());
        movie.setDescription(request.description().trim());
        movie.setDuration(request.duration());
        movie.setLanguage(request.language().trim());
        movie.setGenre(request.genre().trim());
        movie.setReleaseDate(request.releaseDate());
        movie.setStatus(request.status());
    }

    private void apply(Theatre theatre, TheatreRequest request) {
        theatre.setName(request.name().trim());
        theatre.setLocation(request.location().trim());
        theatre.setCapacity(request.capacity());
        theatre.setStatus(request.status());
    }
}
