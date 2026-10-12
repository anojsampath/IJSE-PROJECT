package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.net.URI;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.ShowRequest;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/shows")
@RequiredArgsConstructor
public class ShowController {
    private final ShowService shows;
    private final BookingService bookings;

    @GetMapping
    public List<ShowView> all() {
        return shows.all();
    }

    @GetMapping("/{id}")
    public ShowView get(@PathVariable @Positive Long id) {
        return shows.get(id);
    }

    @GetMapping("/{id}/seats")
    public SeatsView seats(@PathVariable @Positive Long id) {
        return bookings.seats(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ShowView> create(@Valid @RequestBody ShowRequest request) {
        var show = shows.create(request);
        return ResponseEntity.created(URI.create("/api/shows/" + show.id())).body(show);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ShowView update(
            @PathVariable @Positive Long id, @Valid @RequestBody ShowRequest request) {
        return shows.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable @Positive Long id) {
        shows.delete(id);
    }
}
