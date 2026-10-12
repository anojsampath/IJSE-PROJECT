package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.net.URI;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.TheatreRequest;
import lk.ijse.moviebooking.dto.Responses.TheatreView;
import lk.ijse.moviebooking.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/theatres")
@RequiredArgsConstructor
public class TheatreController {
    private final CatalogService catalog;

    @GetMapping
    public List<TheatreView> all() {
        return catalog.theatres();
    }

    @GetMapping("/{id}")
    public TheatreView get(@PathVariable @Positive Long id) {
        return catalog.theatre(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TheatreView> create(@Valid @RequestBody TheatreRequest request) {
        var theatre = catalog.createTheatre(request);
        return ResponseEntity.created(URI.create("/api/theatres/" + theatre.id())).body(theatre);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public TheatreView update(
            @PathVariable @Positive Long id, @Valid @RequestBody TheatreRequest request) {
        return catalog.updateTheatre(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable @Positive Long id) {
        catalog.deleteTheatre(id);
    }
}
