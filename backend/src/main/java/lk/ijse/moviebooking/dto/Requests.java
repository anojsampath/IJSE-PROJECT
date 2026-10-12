package lk.ijse.moviebooking.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import lk.ijse.moviebooking.enums.Types.*;

public final class Requests {
    private Requests() {}

    public record Signup(
            @NotBlank @Size(max = 100) String name,
            @NotBlank @Email @Size(max = 254) String email,
            @NotBlank @Size(min = 8, max = 72) String password) {}

    public record Signin(
            @NotBlank @Email @Size(max = 254) String email,
            @NotBlank @Size(max = 72) String password) {}

    public record UserUpdate(
            @NotBlank @Size(max = 100) String name,
            @NotBlank @Email @Size(max = 254) String email,
            @NotNull Role role) {}

    public record MovieRequest(
            @NotBlank @Size(max = 200) String title,
            @NotBlank @Size(max = 4000) String description,
            @Min(1) @Max(1440) int duration,
            @NotBlank @Size(max = 50) String language,
            @NotBlank @Size(max = 80) String genre,
            @NotNull LocalDate releaseDate,
            @NotNull MovieStatus status) {}

    public record TheatreRequest(
            @NotBlank @Size(max = 150) String name,
            @NotBlank @Size(max = 250) String location,
            @Min(1) @Max(10000) int capacity,
            @NotNull TheatreStatus status) {}

    public record ShowRequest(
            @NotNull @Positive Long movieId,
            @NotNull @Positive Long theatreId,
            @NotNull LocalDate showDate,
            @NotNull LocalTime showTime,
            @NotNull @DecimalMin("0.01") @DecimalMax("999999.99") @Digits(integer = 6, fraction = 2)
                    BigDecimal ticketPrice,
            @NotNull ShowStatus status) {}

    public record BookingRequest(
            @NotNull @Positive Long showId,
            @NotEmpty @Size(max = 10000) List<@NotBlank @Size(max = 12) String> seatNumbers,
            @Min(1) @Max(10000) int numberOfTickets) {}

    public record BookingStatusRequest(@NotNull BookingStatus status) {}

    public record PaymentRequest(
            @NotNull @Positive Long bookingId, @NotNull PaymentMethod paymentMethod) {}

    public record ProcessPayment(@NotNull PaymentOutcome outcome) {}
}
