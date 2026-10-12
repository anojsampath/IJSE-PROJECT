package lk.ijse.moviebooking;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import io.jsonwebtoken.Jwts;
import java.math.BigDecimal;
import java.time.*;
import java.util.*;
import java.util.concurrent.*;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.enums.Types.*;
import lk.ijse.moviebooking.repository.UserRepository;
import lk.ijse.moviebooking.security.*;
import lk.ijse.moviebooking.service.*;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.*;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.*;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import tools.jackson.databind.*;

@SpringBootTest
@AutoConfigureMockMvc
abstract class WorkflowContract {
    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;
    @Autowired AuthService auth;
    @Autowired CatalogService catalog;
    @Autowired ShowService shows;
    @Autowired BookingService bookings;
    @Autowired PaymentService payments;
    @Autowired UserRepository users;
    @Autowired JwtService jwt;
    @Autowired PlatformTransactionManager transactionManager;
    @MockitoBean Clock clock;
    Actor customer;
    Actor other;
    Actor admin;
    String customerToken;
    String otherToken;
    String adminToken;
    MovieView movie;
    TheatreView theatre;
    ShowView show;
    static final Instant NOW = Instant.parse("2030-01-01T00:00:00Z");
    static final LocalDate SHOW_DATE = LocalDate.of(2030, 2, 1);
    static final BigDecimal PRICE = new BigDecimal("1250.50");

    @DynamicPropertySource
    static void jwtProperties(DynamicPropertyRegistry registry) {
        String key = Base64.getEncoder().encodeToString(Jwts.SIG.HS256.key().build().getEncoded());
        registry.add("app.jwt.secret", () -> key);
    }

    @BeforeEach
    void fixtures() {
        when(clock.instant()).thenReturn(NOW);
        when(clock.getZone()).thenReturn(ZoneId.of("Asia/Colombo"));
        customer = account(Role.CUSTOMER);
        other = account(Role.CUSTOMER);
        admin = account(Role.ADMIN);
        customerToken = jwt.issue(customer.id());
        otherToken = jwt.issue(other.id());
        adminToken = jwt.issue(admin.id());
        movie = catalog.createMovie(movieRequest(MovieStatus.NOW_SHOWING, 120));
        theatre =
                catalog.createTheatre(
                        new TheatreRequest("Cinema", "Colombo", 12, TheatreStatus.ACTIVE));
        show =
                shows.create(
                        showRequest(
                                movie.id(),
                                theatre.id(),
                                SHOW_DATE.atTime(12, 0),
                                ShowStatus.SCHEDULED));
    }

    @Test
    void signupSigninAndRoleInjection() throws Exception {
        String email = UUID.randomUUID() + "@example.com";
        JsonNode registered =
                request(
                        post("/api/auth/signup"),
                        Map.of(
                                "name",
                                "Customer",
                                "email",
                                email,
                                "password",
                                "TestOnly123!",
                                "role",
                                "ADMIN"),
                        null,
                        201);
        assertThat(registered.get("role").asText()).isEqualTo("CUSTOMER");
        assertThat(registered.has("passwordHash")).isFalse();
        JsonNode token =
                request(
                        post("/api/auth/signin"),
                        new Signin(email.toUpperCase(Locale.ROOT), "TestOnly123!"),
                        null,
                        200);
        assertThat(token.get("token").asText()).isNotBlank();
        request(get("/api/movies"), null, token.get("token").asText(), 200);
        request(post("/api/auth/signup"), new Signup("Again", email, "TestOnly123!"), null, 409);
        request(post("/api/auth/signin"), new Signin(email, "wrong-password"), null, 401);
        request(post("/api/auth/signup"), new Signup("Bad", "bad-email", "short"), null, 400);
    }

    @Test
    void roleAndTokenBoundaries() throws Exception {
        request(get("/api/movies"), null, null, 401);
        request(get("/api/movies"), null, "invalid", 401);
        request(get("/api/users"), null, customerToken, 403);
        request(post("/api/movies"), movieRequest(MovieStatus.UPCOMING, 90), customerToken, 403);
        request(
                post("/api/theatres"),
                new TheatreRequest("Other", "Kandy", 20, TheatreStatus.ACTIVE),
                customerToken,
                403);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(18, 0), ShowStatus.SCHEDULED),
                customerToken,
                403);
        request(get("/api/bookings"), null, customerToken, 403);
        request(get("/api/payments"), null, customerToken, 403);
        request(post("/api/bookings"), bookingRequest("A1"), adminToken, 403);
        var user = users.findById(admin.id()).orElseThrow();
        user.setRole(Role.CUSTOMER);
        users.saveAndFlush(user);
        request(get("/api/users"), null, adminToken, 403);
        users.deleteById(other.id());
        request(get("/api/movies"), null, otherToken, 401);
        when(clock.instant()).thenReturn(NOW.plusSeconds(3601));
        request(get("/api/movies"), null, customerToken, 401);
    }

    @Test
    void catalogAndUserCrud() throws Exception {
        var created =
                request(
                        post("/api/movies"),
                        movieRequest(MovieStatus.UPCOMING, 100),
                        adminToken,
                        201);
        long id = created.get("id").asLong();
        request(get("/api/movies/" + id), null, customerToken, 200);
        request(
                put("/api/movies/" + id),
                movieRequest(MovieStatus.NOW_SHOWING, 110),
                adminToken,
                200);
        request(delete("/api/movies/" + id), null, adminToken, 204);
        request(get("/api/movies/" + id), null, customerToken, 404);
        var venue =
                request(
                        post("/api/theatres"),
                        new TheatreRequest("Small", "Galle", 5, TheatreStatus.ACTIVE),
                        adminToken,
                        201);
        long venueId = venue.get("id").asLong();
        request(get("/api/theatres/" + venueId), null, customerToken, 200);
        request(
                put("/api/theatres/" + venueId),
                new TheatreRequest("Renamed", "Galle", 7, TheatreStatus.INACTIVE),
                adminToken,
                200);
        request(delete("/api/theatres/" + venueId), null, adminToken, 204);
        request(get("/api/users/" + other.id()), null, adminToken, 200);
        request(
                put("/api/users/" + other.id()),
                new UserUpdate(
                        "Updated", "updated-" + UUID.randomUUID() + "@example.com", Role.CUSTOMER),
                adminToken,
                200);
        request(delete("/api/users/" + other.id()), null, adminToken, 204);
        request(delete("/api/users/" + admin.id()), null, adminToken, 409);
        request(get("/api/movies/" + movie.id() + "/shows"), null, customerToken, 200);
        request(get("/api/shows/" + show.id()), null, customerToken, 200);
    }

    @Test
    void bookingValidationPriceAndOwnership() throws Exception {
        request(
                post("/api/bookings"),
                new BookingRequest(show.id(), List.of(), 0),
                customerToken,
                400);
        request(
                post("/api/bookings"),
                new BookingRequest(show.id(), List.of("A1", " a1 "), 2),
                customerToken,
                400);
        request(
                post("/api/bookings"),
                new BookingRequest(show.id(), List.of("A1"), 2),
                customerToken,
                400);
        request(post("/api/bookings"), bookingRequest("B3"), customerToken, 400);
        request(
                post("/api/bookings"),
                new BookingRequest(Long.MAX_VALUE, List.of("A1"), 1),
                customerToken,
                404);
        var result =
                request(
                        post("/api/bookings"),
                        Map.of(
                                "showId",
                                show.id(),
                                "seatNumbers",
                                List.of(" a1 ", "A2"),
                                "numberOfTickets",
                                2,
                                "userId",
                                other.id(),
                                "totalAmount",
                                1),
                        customerToken,
                        201);
        long id = result.get("id").asLong();
        assertThat(result.get("userId").asLong()).isEqualTo(customer.id());
        assertThat(result.get("totalAmount").decimalValue()).isEqualByComparingTo("2501.00");
        request(post("/api/bookings"), bookingRequest("A1"), otherToken, 409);
        request(get("/api/bookings/" + id), null, otherToken, 403);
        request(put("/api/bookings/" + id + "/cancel"), null, otherToken, 403);
        request(get("/api/bookings/" + id), null, adminToken, 200);
        JsonNode mine = request(get("/api/bookings/my-bookings"), null, customerToken, 200);
        assertThat(mine.size()).isEqualTo(1);
        JsonNode seats =
                request(get("/api/shows/" + show.id() + "/seats"), null, customerToken, 200);
        assertThat(seats.get("reservedSeats").size()).isEqualTo(2);
        assertThat(seats.get("availableSeats").size()).isEqualTo(10);
    }

    @Test
    void paymentFailureRetryConfirmationAndRefund() throws Exception {
        BookingView booking = bookings.create(bookingRequest("A1"), customer);
        var payment =
                request(
                        post("/api/payments"),
                        Map.of(
                                "bookingId",
                                booking.id(),
                                "paymentMethod",
                                "SIMULATED",
                                "amount",
                                1),
                        customerToken,
                        201);
        long id = payment.get("id").asLong();
        assertThat(payment.get("amount").decimalValue()).isEqualByComparingTo(PRICE);
        request(
                post("/api/payments"),
                new PaymentRequest(booking.id(), PaymentMethod.SIMULATED),
                customerToken,
                409);
        request(get("/api/payments/" + id), null, otherToken, 403);
        request(
                post("/api/payments/" + id + "/process"),
                new ProcessPayment(PaymentOutcome.COMPLETED),
                otherToken,
                403);
        request(
                post("/api/payments/" + id + "/process"),
                new ProcessPayment(PaymentOutcome.FAILED),
                customerToken,
                200);
        assertThat(bookings.get(booking.id(), customer).status()).isEqualTo(BookingStatus.PENDING);
        request(
                put("/api/bookings/" + booking.id() + "/status"),
                new BookingStatusRequest(BookingStatus.CONFIRMED),
                adminToken,
                409);
        request(
                post("/api/payments/" + id + "/process"),
                new ProcessPayment(PaymentOutcome.COMPLETED),
                customerToken,
                200);
        assertThat(bookings.get(booking.id(), customer).status())
                .isEqualTo(BookingStatus.CONFIRMED);
        request(get("/api/payments/" + id + "/status"), null, customerToken, 200);
        request(
                post("/api/payments/" + id + "/process"),
                new ProcessPayment(PaymentOutcome.COMPLETED),
                customerToken,
                409);
        request(
                put("/api/bookings/" + booking.id() + "/status"),
                new BookingStatusRequest(BookingStatus.PENDING),
                adminToken,
                409);
        request(put("/api/bookings/" + booking.id() + "/cancel"), null, customerToken, 200);
        request(put("/api/bookings/" + booking.id() + "/cancel"), null, customerToken, 200);
        assertThat(payments.get(id, customer).status()).isEqualTo(PaymentStatus.REFUNDED);
        request(
                post("/api/payments/" + id + "/process"),
                new ProcessPayment(PaymentOutcome.COMPLETED),
                customerToken,
                409);
        assertThat(bookings.seats(show.id()).reservedSeats()).isEmpty();
        request(post("/api/bookings"), bookingRequest("A1"), otherToken, 201);
    }

    @Test
    void canceledBookingsRejectPaymentsAndReopening() throws Exception {
        var booking = bookings.create(bookingRequest("A1"), customer);
        bookings.cancel(booking.id(), customer);
        request(
                post("/api/payments"),
                new PaymentRequest(booking.id(), PaymentMethod.SIMULATED),
                customerToken,
                409);
        request(
                put("/api/bookings/" + booking.id() + "/status"),
                new BookingStatusRequest(BookingStatus.PENDING),
                adminToken,
                409);
        var second = bookings.create(bookingRequest("A2"), customer);
        var payment =
                payments.create(new PaymentRequest(second.id(), PaymentMethod.SIMULATED), customer);
        bookings.cancel(second.id(), customer);
        assertThat(payments.get(payment.id(), customer).status()).isEqualTo(PaymentStatus.FAILED);
        request(
                post("/api/payments/" + payment.id() + "/process"),
                new ProcessPayment(PaymentOutcome.COMPLETED),
                customerToken,
                409);
    }

    @Test
    void schedulingRulesAndCrossMidnightOverlap() throws Exception {
        request(
                post("/api/shows"),
                showRequest(
                        Long.MAX_VALUE,
                        theatre.id(),
                        SHOW_DATE.atTime(18, 0),
                        ShowStatus.SCHEDULED),
                adminToken,
                404);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(13, 0), ShowStatus.SCHEDULED),
                adminToken,
                409);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(14, 0), ShowStatus.SCHEDULED),
                adminToken,
                201);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(23, 0), ShowStatus.SCHEDULED),
                adminToken,
                201);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(),
                        theatre.id(),
                        SHOW_DATE.plusDays(1).atTime(0, 30),
                        ShowStatus.SCHEDULED),
                adminToken,
                409);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(),
                        theatre.id(),
                        SHOW_DATE.minusYears(1).atTime(12, 0),
                        ShowStatus.SCHEDULED),
                adminToken,
                400);
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(18, 0), ShowStatus.COMPLETED),
                adminToken,
                400);
        catalog.updateMovie(movie.id(), movieRequest(MovieStatus.ENDED, 120));
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(18, 0), ShowStatus.SCHEDULED),
                adminToken,
                409);
        catalog.updateMovie(movie.id(), movieRequest(MovieStatus.NOW_SHOWING, 120));
        catalog.updateTheatre(
                theatre.id(), new TheatreRequest("Cinema", "Colombo", 12, TheatreStatus.INACTIVE));
        request(
                post("/api/shows"),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(18, 0), ShowStatus.SCHEDULED),
                adminToken,
                409);
    }

    @Test
    void protectedHistoryAndShowUpdates() throws Exception {
        request(
                put("/api/shows/" + show.id()),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(11, 0), ShowStatus.SCHEDULED),
                adminToken,
                200);
        var booking = bookings.create(bookingRequest("A1"), customer);
        request(
                put("/api/shows/" + show.id()),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(10, 0), ShowStatus.SCHEDULED),
                adminToken,
                409);
        request(
                put("/api/movies/" + movie.id()),
                movieRequest(MovieStatus.NOW_SHOWING, 90),
                adminToken,
                409);
        request(
                put("/api/theatres/" + theatre.id()),
                new TheatreRequest("Cinema", "Colombo", 15, TheatreStatus.ACTIVE),
                adminToken,
                409);
        request(delete("/api/users/" + customer.id()), null, adminToken, 409);
        request(delete("/api/movies/" + movie.id()), null, adminToken, 409);
        request(delete("/api/theatres/" + theatre.id()), null, adminToken, 409);
        request(delete("/api/shows/" + show.id()), null, adminToken, 409);
        assertThat(bookings.get(booking.id(), customer).status()).isEqualTo(BookingStatus.PENDING);
        var emptyShow =
                shows.create(
                        showRequest(
                                movie.id(),
                                theatre.id(),
                                SHOW_DATE.atTime(18, 0),
                                ShowStatus.SCHEDULED));
        request(delete("/api/shows/" + emptyShow.id()), null, adminToken, 204);
    }

    @Test
    void showCancellationRefundsAndReleasesAllSeats() throws Exception {
        var first = bookings.create(bookingRequest("A1"), customer);
        var paid =
                payments.create(new PaymentRequest(first.id(), PaymentMethod.SIMULATED), customer);
        payments.process(paid.id(), new ProcessPayment(PaymentOutcome.COMPLETED), customer);
        var second = bookings.create(bookingRequest("A2"), other);
        request(
                put("/api/shows/" + show.id()),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(12, 0), ShowStatus.CANCELLED),
                adminToken,
                200);
        assertThat(payments.get(paid.id(), customer).status()).isEqualTo(PaymentStatus.REFUNDED);
        assertThat(bookings.get(second.id(), other).status()).isEqualTo(BookingStatus.CANCELLED);
        assertThat(bookings.seats(show.id()).reservedSeats()).isEmpty();
        request(post("/api/bookings"), bookingRequest("A3"), customerToken, 409);
        request(
                put("/api/shows/" + show.id()),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(12, 0), ShowStatus.SCHEDULED),
                adminToken,
                409);
    }

    @Test
    void completedOrStartedShowsRejectBookingsPaymentsAndCustomerCancellation() throws Exception {
        var booking = bookings.create(bookingRequest("A1"), customer);
        var payment =
                payments.create(
                        new PaymentRequest(booking.id(), PaymentMethod.SIMULATED), customer);
        request(
                put("/api/shows/" + show.id()),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(12, 0), ShowStatus.COMPLETED),
                adminToken,
                409);
        when(clock.instant())
                .thenReturn(SHOW_DATE.atTime(15, 0).atZone(ZoneId.of("Asia/Colombo")).toInstant());
        customerToken = jwt.issue(customer.id());
        adminToken = jwt.issue(admin.id());
        request(post("/api/bookings"), bookingRequest("A2"), customerToken, 409);
        request(
                post("/api/payments/" + payment.id() + "/process"),
                new ProcessPayment(PaymentOutcome.COMPLETED),
                customerToken,
                409);
        request(put("/api/bookings/" + booking.id() + "/cancel"), null, customerToken, 409);
        request(
                put("/api/shows/" + show.id()),
                showRequest(
                        movie.id(), theatre.id(), SHOW_DATE.atTime(12, 0), ShowStatus.COMPLETED),
                adminToken,
                200);
        request(post("/api/bookings"), bookingRequest("A2"), customerToken, 409);
    }

    @Test
    void malformedRequestsAndValidationReturnClientErrors() throws Exception {
        mvc.perform(post("/api/auth/signup").contentType(MediaType.APPLICATION_JSON).content("{"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("error").value("BAD_REQUEST"));
        request(
                post("/api/theatres"),
                new TheatreRequest("", "Colombo", 0, TheatreStatus.ACTIVE),
                adminToken,
                400);
        request(post("/api/movies"), movieRequest(MovieStatus.UPCOMING, 0), adminToken, 400);
        request(get("/api/movies/not-a-number"), null, customerToken, 400);
        request(get("/api/movies/-1"), null, customerToken, 400);
        request(
                post("/api/payments"),
                Map.of("bookingId", 1, "paymentMethod", "REAL_CARD"),
                customerToken,
                400);
        request(
                post("/api/auth/signup"),
                new Signup("Unicode", UUID.randomUUID() + "@example.com", "é".repeat(40)),
                null,
                400);
    }

    @Test
    void simultaneousSeatRequestsHaveOneWinner() throws Exception {
        assertThat(
                        race(
                                () ->
                                        httpStatus(
                                                post("/api/bookings"),
                                                bookingRequest("A1"),
                                                customerToken),
                                () ->
                                        httpStatus(
                                                post("/api/bookings"),
                                                bookingRequest("A1"),
                                                otherToken)))
                .containsExactlyInAnyOrder(201, 409);
        assertThat(bookings.seats(show.id()).reservedSeats()).containsExactly("A1");
    }

    @Test
    void simultaneousSchedulingHasOneWinner() throws Exception {
        var anotherMovie = catalog.createMovie(movieRequest(MovieStatus.UPCOMING, 100));
        assertThat(
                        race(
                                () ->
                                        httpStatus(
                                                post("/api/shows"),
                                                showRequest(
                                                        movie.id(),
                                                        theatre.id(),
                                                        SHOW_DATE.atTime(18, 0),
                                                        ShowStatus.SCHEDULED),
                                                adminToken),
                                () ->
                                        httpStatus(
                                                post("/api/shows"),
                                                showRequest(
                                                        anotherMovie.id(),
                                                        theatre.id(),
                                                        SHOW_DATE.atTime(18, 0),
                                                        ShowStatus.SCHEDULED),
                                                adminToken)))
                .containsExactlyInAnyOrder(201, 409);
    }

    @Test
    void simultaneousPaymentCreationAndProcessingHaveOneWinner() throws Exception {
        var booking = bookings.create(bookingRequest("A1"), customer);
        var body = new PaymentRequest(booking.id(), PaymentMethod.SIMULATED);
        assertThat(
                        race(
                                () -> httpStatus(post("/api/payments"), body, customerToken),
                                () -> httpStatus(post("/api/payments"), body, customerToken)))
                .containsExactlyInAnyOrder(201, 409);
        Long id =
                payments.all().stream()
                        .filter(p -> p.bookingId().equals(booking.id()))
                        .findFirst()
                        .orElseThrow()
                        .id();
        assertThat(
                        race(
                                () ->
                                        httpStatus(
                                                post("/api/payments/" + id + "/process"),
                                                new ProcessPayment(PaymentOutcome.COMPLETED),
                                                customerToken),
                                () ->
                                        httpStatus(
                                                post("/api/payments/" + id + "/process"),
                                                new ProcessPayment(PaymentOutcome.COMPLETED),
                                                customerToken)))
                .containsExactlyInAnyOrder(200, 409);
        assertThat(bookings.get(booking.id(), customer).status())
                .isEqualTo(BookingStatus.CONFIRMED);
    }

    @Test
    void paymentRacingCancellationNeverLeavesPaidCanceledBooking() throws Exception {
        var booking = bookings.create(bookingRequest("A1"), customer);
        var payment =
                payments.create(
                        new PaymentRequest(booking.id(), PaymentMethod.SIMULATED), customer);
        List<Integer> results =
                race(
                        () ->
                                httpStatus(
                                        post("/api/payments/" + payment.id() + "/process"),
                                        new ProcessPayment(PaymentOutcome.COMPLETED),
                                        customerToken),
                        () ->
                                httpStatus(
                                        put("/api/bookings/" + booking.id() + "/cancel"),
                                        null,
                                        customerToken));
        assertThat(results).allMatch(s -> s == 200 || s == 409);
        assertThat(results.get(1)).isEqualTo(200);
        assertThat(bookings.get(booking.id(), customer).status())
                .isEqualTo(BookingStatus.CANCELLED);
        assertThat(payments.get(payment.id(), customer).status())
                .isIn(PaymentStatus.FAILED, PaymentStatus.REFUNDED);
        assertThat(bookings.seats(show.id()).reservedSeats()).isEmpty();
    }

    @Test
    void paymentAndBookingRollBackTogether() {
        var booking = bookings.create(bookingRequest("A1"), customer);
        var payment =
                payments.create(
                        new PaymentRequest(booking.id(), PaymentMethod.SIMULATED), customer);
        assertThatThrownBy(
                        () ->
                                new TransactionTemplate(transactionManager)
                                        .executeWithoutResult(
                                                tx -> {
                                                    payments.process(
                                                            payment.id(),
                                                            new ProcessPayment(
                                                                    PaymentOutcome.COMPLETED),
                                                            customer);
                                                    throw new IllegalStateException(
                                                            "Simulated failure before commit");
                                                }))
                .isInstanceOf(IllegalStateException.class);
        assertThat(bookings.get(booking.id(), customer).status()).isEqualTo(BookingStatus.PENDING);
        assertThat(payments.get(payment.id(), customer).status()).isEqualTo(PaymentStatus.PENDING);
    }

    private Actor account(Role role) {
        var user =
                auth.signup(
                        new Signup(
                                "Test User", UUID.randomUUID() + "@example.com", "TestOnly123!"));
        if (role == Role.ADMIN) {
            var entity = users.findById(user.id()).orElseThrow();
            entity.setRole(role);
            users.saveAndFlush(entity);
        }
        return new Actor(user.id(), role);
    }

    private MovieRequest movieRequest(MovieStatus status, int duration) {
        return new MovieRequest(
                "Example",
                "Description",
                duration,
                "English",
                "Drama",
                LocalDate.of(2029, 1, 1),
                status);
    }

    private ShowRequest showRequest(
            Long movieId, Long theatreId, LocalDateTime start, ShowStatus status) {
        return new ShowRequest(
                movieId, theatreId, start.toLocalDate(), start.toLocalTime(), PRICE, status);
    }

    private BookingRequest bookingRequest(String seat) {
        return new BookingRequest(show.id(), List.of(seat), 1);
    }

    private JsonNode request(
            MockHttpServletRequestBuilder builder, Object body, String token, int expected)
            throws Exception {
        var result = perform(builder, body, token).andExpect(status().is(expected)).andReturn();
        String content = result.getResponse().getContentAsString();
        return content.isBlank() ? mapper.nullNode() : mapper.readTree(content);
    }

    private int httpStatus(MockHttpServletRequestBuilder builder, Object body, String token)
            throws Exception {
        return perform(builder, body, token).andReturn().getResponse().getStatus();
    }

    private ResultActions perform(MockHttpServletRequestBuilder builder, Object body, String token)
            throws Exception {
        if (token != null) builder.header("Authorization", "Bearer " + token);
        if (body != null)
            builder.contentType(MediaType.APPLICATION_JSON)
                    .content(mapper.writeValueAsString(body));
        return mvc.perform(builder);
    }

    private List<Integer> race(Callable<Integer> first, Callable<Integer> second) throws Exception {
        var ready = new CountDownLatch(2);
        var start = new CountDownLatch(1);
        try (var executor = Executors.newFixedThreadPool(2)) {
            List<Future<Integer>> futures = new ArrayList<>();
            for (var operation : List.of(first, second)) {
                futures.add(
                        executor.submit(
                                () -> {
                                    ready.countDown();
                                    if (!start.await(10, TimeUnit.SECONDS))
                                        throw new IllegalStateException("Start barrier timed out");
                                    return operation.call();
                                }));
            }
            assertThat(ready.await(10, TimeUnit.SECONDS)).isTrue();
            start.countDown();
            return List.of(
                    futures.get(0).get(30, TimeUnit.SECONDS),
                    futures.get(1).get(30, TimeUnit.SECONDS));
        }
    }
}
