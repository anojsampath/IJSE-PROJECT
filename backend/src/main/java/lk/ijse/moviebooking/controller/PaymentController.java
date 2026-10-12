package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.net.URI;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.security.Actor;
import lk.ijse.moviebooking.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {
    private final PaymentService payments;

    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<PaymentView> create(
            @Valid @RequestBody PaymentRequest request, @AuthenticationPrincipal Actor actor) {
        var payment = payments.create(request, actor);
        return ResponseEntity.created(URI.create("/api/payments/" + payment.id())).body(payment);
    }

    @PostMapping("/{id}/process")
    @PreAuthorize("hasRole('CUSTOMER')")
    public PaymentView process(
            @PathVariable @Positive Long id,
            @Valid @RequestBody ProcessPayment request,
            @AuthenticationPrincipal Actor actor) {
        return payments.process(id, request, actor);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<PaymentView> all() {
        return payments.all();
    }

    @GetMapping("/{id}")
    public PaymentView get(@PathVariable @Positive Long id, @AuthenticationPrincipal Actor actor) {
        return payments.get(id, actor);
    }

    @GetMapping("/{id}/status")
    public PaymentStatusView status(
            @PathVariable @Positive Long id, @AuthenticationPrincipal Actor actor) {
        return payments.status(id, actor);
    }
}
