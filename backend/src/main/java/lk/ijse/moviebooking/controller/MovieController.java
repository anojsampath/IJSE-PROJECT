package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.net.URI;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.MovieRequest;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
public class MovieController {
    private final CatalogService catalog;
    private final ShowService shows;

    @GetMapping
    public List<MovieView> all() {
        return catalog.movies();
    }

    @GetMapping("/{id}")
    public MovieView get(@PathVariable @Positive Long id) {
        return catalog.movie(id);
    }

    @GetMapping("/{id}/shows")
    public List<ShowView> shows(@PathVariable @Positive Long id) {
        return shows.forMovie(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MovieView> create(@Valid @RequestBody MovieRequest request) {
        var movie = catalog.createMovie(request);
        return ResponseEntity.created(URI.create("/api/movies/" + movie.id())).body(movie);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public MovieView update(
            @PathVariable @Positive Long id, @Valid @RequestBody MovieRequest request) {
        return catalog.updateMovie(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable @Positive Long id) {
        catalog.deleteMovie(id);
    }
}
