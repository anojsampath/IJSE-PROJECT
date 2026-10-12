package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.net.URI;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses.BookingView;
import lk.ijse.moviebooking.security.Actor;
import lk.ijse.moviebooking.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {
    private final BookingService bookings;

    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<BookingView> create(
            @Valid @RequestBody BookingRequest request, @AuthenticationPrincipal Actor actor) {
        var booking = bookings.create(request, actor);
        return ResponseEntity.created(URI.create("/api/bookings/" + booking.id())).body(booking);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<BookingView> all() {
        return bookings.all();
    }

    @GetMapping("/my-bookings")
    @PreAuthorize("hasRole('CUSTOMER')")
    public List<BookingView> mine(@AuthenticationPrincipal Actor actor) {
        return bookings.mine(actor);
    }

    @GetMapping("/{id}")
    public BookingView get(@PathVariable @Positive Long id, @AuthenticationPrincipal Actor actor) {
        return bookings.get(id, actor);
    }

    @PutMapping("/{id}/cancel")
    public BookingView cancel(
            @PathVariable @Positive Long id, @AuthenticationPrincipal Actor actor) {
        return bookings.cancel(id, actor);
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public BookingView status(
            @PathVariable @Positive Long id,
            @Valid @RequestBody BookingStatusRequest request,
            @AuthenticationPrincipal Actor actor) {
        return bookings.updateStatus(id, request, actor);
    }
}
