# Movie Ticket Booking — Backend API Documentation

REST API reference for the Spring Boot + MySQL backend (package `lk.ijse.moviebooking`).
Covers every endpoint, request/response DTOs, validation rules, authentication, authorization, and error handling.

- **Architecture:** Controller → Service → Repository → Database (layered, DTO-only responses)
- **Auth:** Stateless JWT (HS256) + Spring Security; BCrypt password hashing
- **Data:** MySQL 8+ via Spring Data JPA/Hibernate; Flyway migrations
- **Money:** LKR, `BigDecimal` (max 2 decimals). **Dates:** ISO-8601. **Screening times:** local to `Asia/Colombo`; booking/payment timestamps are UTC instants.

---

## 1. Base URL

| Environment | Base URL |
| --- | --- |
| Default (`PORT` unset) | `http://localhost:8080/api` |
| This PC (project-local helper) | `http://127.0.0.1:8081/api` |

All paths below are relative to `/api`. Responses are `application/json` unless noted.

---

## 2. Authentication

Sign in to obtain a JWT, then send it on every protected request:

```
Authorization: Bearer <token>
```

| Property | Value |
| --- | --- |
| Issuer | `movie-booking` |
| Subject | user ID |
| Lifetime | 3600 seconds (1 hour) |
| Algorithm | HMAC-SHA256 (`JWT_SECRET`, Base64, ≥ 256 bits) |

The account and role are **reloaded from the database on every request**, so deletions and role changes take effect on the next call. Expired/invalid/absent tokens yield **401**; authenticated but unauthorized actions yield **403**.

### Public vs. protected

| Access | Who | Scope |
| --- | --- | --- |
| Public | anyone | `POST /auth/signup`, `POST /auth/signin` |
| Authenticated | ADMIN or CUSTOMER | catalog reads (movies/theatres/shows/seats) |
| Owner/admin | the record's customer or an ADMIN | get/cancel own booking & payment, payment status |
| ADMIN | administrators only | users, movie/theatre/show create-update-delete, list all bookings/payments, update booking status |
| CUSTOMER | customers only | create booking, create/process payment, list own bookings |

---

## 3. Response & status-code conventions

| Situation | HTTP status |
| --- | --- |
| Resource created | `201 Created` + `Location` header (e.g. `/api/movies/5`) |
| Read / update success | `200 OK` |
| Delete success | `204 No Content` (empty body) |
| Validation / malformed body | `400 Bad Request` |
| Missing or expired authentication | `401 Unauthorized` |
| Authenticated but forbidden (role/ownership) | `403 Forbidden` |
| No such record | `404 Not Found` |
| Business conflict (seat taken, overlap, lifecycle, referenced history) | `409 Conflict` |
| Unexpected failure | `500` (generic message, no internal details) |

Listing endpoints return JSON arrays. All create requests that return 201 also include a `Location` header pointing at the new resource.

---

## 4. Error format

Every error is a single consistent body (`exception/ApiError`):

```json
{
  "timestamp": "2026-10-11T14:05:00Z",
  "status": 400,
  "error": "BAD_REQUEST",
  "message": "Request validation failed",
  "path": "/api/bookings",
  "fieldErrors": { "numberOfTickets": "must be greater than or equal to 1" }
}
```

- `fieldErrors` is present only for Bean Validation failures.
- Security errors (401/403) are written by the security layer and include `WWW-Authenticate: Bearer` on 401.
- Stack traces and internal exception messages are never exposed to clients.

---

## 5. Enums (roles & statuses)

| Type | Values |
| --- | --- |
| `Role` | `ADMIN`, `CUSTOMER` |
| `MovieStatus` | `UPCOMING`, `NOW_SHOWING`, `ENDED` |
| `TheatreStatus` | `ACTIVE`, `INACTIVE` |
| `ShowStatus` | `SCHEDULED`, `COMPLETED`, `CANCELLED` |
| `BookingStatus` | `PENDING`, `CONFIRMED`, `CANCELLED` |
| `PaymentStatus` | `PENDING`, `COMPLETED`, `FAILED`, `REFUNDED` |
| `PaymentMethod` | `SIMULATED` |
| `PaymentOutcome` | `COMPLETED`, `FAILED` (accepted only by payment processing) |

---

## 6. Endpoint reference

### 6.1 Authentication

| Method | Path | Access | Request body | Response |
| --- | --- | --- | --- | --- |
| POST | `/auth/signup` | Public | `Signup` | `201` → `UserView` (role is always `CUSTOMER`) |
| POST | `/auth/signin` | Public | `Signin` | `200` → `TokenView` |

Signup does **not** return a token — sign in afterwards to obtain one. Invalid credentials return `401`; duplicate email returns `409`.

### 6.2 Users (ADMIN only)

| Method | Path | Request body | Response |
| --- | --- | --- | --- |
| GET | `/users` | — | `200` → `UserView[]` |
| GET | `/users/{id}` | — | `200` → `UserView` |
| PUT | `/users/{id}` | `UserUpdate` | `200` → `UserView` |
| DELETE | `/users/{id}` | — | `204` |

Guards: duplicate email → `409`; deleting a user with booking history → `409`; an administrator cannot delete or demote **their own** account → `403`. The stored password hash is never returned.

### 6.3 Movies

| Method | Path | Access | Request body | Response |
| --- | --- | --- | --- | --- |
| GET | `/movies` | Authenticated | — | `200` → `MovieView[]` |
| GET | `/movies/{id}` | Authenticated | — | `200` → `MovieView` |
| GET | `/movies/{id}/shows` | Authenticated | — | `200` → `ShowView[]` |
| POST | `/movies` | ADMIN | `MovieRequest` | `201` → `MovieView` |
| PUT | `/movies/{id}` | ADMIN | `MovieRequest` | `200` → `MovieView` |
| DELETE | `/movies/{id}` | ADMIN | — | `204` |

Rules: an `ENDED` movie cannot receive new/rescheduled shows → `409`; changing duration while unfinished scheduled shows exist → `409`; deleting a referenced movie → `409`.

### 6.4 Theatres

| Method | Path | Access | Request body | Response |
| --- | --- | --- | --- | --- |
| GET | `/theatres` | Authenticated | — | `200` → `TheatreView[]` |
| GET | `/theatres/{id}` | Authenticated | — | `200` → `TheatreView` |
| POST | `/theatres` | ADMIN | `TheatreRequest` | `201` → `TheatreView` |
| PUT | `/theatres/{id}` | ADMIN | `TheatreRequest` | `200` → `TheatreView` |
| DELETE | `/theatres/{id}` | ADMIN | — | `204` |

Rules: shows can only target an `ACTIVE` theatre; changing capacity while scheduled shows exist → `409`; deleting a referenced theatre → `409`.

### 6.5 Shows

| Method | Path | Access | Request body | Response |
| --- | --- | --- | --- | --- |
| GET | `/shows` | Authenticated | — | `200` → `ShowView[]` |
| GET | `/shows/{id}` | Authenticated | — | `200` → `ShowView` |
| GET | `/shows/{id}/seats` | Authenticated | — | `200` → `SeatsView` |
| POST | `/shows` | ADMIN | `ShowRequest` | `201` → `ShowView` |
| PUT | `/shows/{id}` | ADMIN | `ShowRequest` | `200` → `ShowView` |
| DELETE | `/shows/{id}` | ADMIN | — | `204` |

Rules:
- New shows must be `SCHEDULED` and start in the **future** → `400` otherwise.
- No overlapping shows in the same theatre (checked across midnight; back-to-back allowed) → `409`.
- Screening details are immutable once any booking history exists → `409`.
- Status changes must be submitted **separately** from detail changes → `409`.
- A show cannot be marked `COMPLETED` before its end time → `409`.
- Setting a show to `CANCELLED` cancels/refunds every active booking for it.
- Terminal shows (`COMPLETED`/`CANCELLED`) cannot be changed or reopened; deleting a show with booking history → `409`.

### 6.6 Bookings

| Method | Path | Access | Request body | Response |
| --- | --- | --- | --- | --- |
| POST | `/bookings` | CUSTOMER | `BookingRequest` | `201` → `BookingView` |
| GET | `/bookings` | ADMIN | — | `200` → `BookingView[]` |
| GET | `/bookings/my-bookings` | CUSTOMER | — | `200` → `BookingView[]` |
| GET | `/bookings/{id}` | Owner/admin | — | `200` → `BookingView` |
| PUT | `/bookings/{id}/cancel` | Owner/admin | — | `200` → `BookingView` |
| PUT | `/bookings/{id}/status` | ADMIN | `BookingStatusRequest` | `200` → `BookingView` |

Rules:
- Seats are normalized to uppercase; blank/duplicate/out-of-capacity labels and a ticket-count mismatch → `400`.
- Total amount is **server-computed** (`ticketPrice × seats`); client-supplied amounts are ignored.
- Booking a seat already reserved (PENDING or CONFIRMED) for the same show → `409`. Seat maps are snapshots, so always handle `409` on submit.
- Only customers create bookings; the acting user is taken from the JWT, never the request body.
- Cancellation is allowed before show start; cancelling an already-cancelled booking is harmless. Completed payments become `REFUNDED`, pending payments become `FAILED`, and seats are released.
- Admin status updates cannot confirm without a `COMPLETED` payment, cannot reopen a `CANCELLED` booking, and cannot move a confirmed booking back to `PENDING` → `409`.

### 6.7 Payments (simulated)

| Method | Path | Access | Request body | Response |
| --- | --- | --- | --- | --- |
| POST | `/payments` | CUSTOMER | `PaymentRequest` | `201` → `PaymentView` |
| POST | `/payments/{id}/process` | CUSTOMER | `ProcessPayment` | `200` → `PaymentView` |
| GET | `/payments` | ADMIN | — | `200` → `PaymentView[]` |
| GET | `/payments/{id}` | Owner/admin | — | `200` → `PaymentView` |
| GET | `/payments/{id}/status` | Owner/admin | — | `200` → `PaymentStatusView` |

Rules:
- `paymentMethod` must be `SIMULATED`; the amount is derived from the booking, never trusted from input.
- At most **one** payment per booking (creating a second → `409`); retry a `FAILED` payment using the same payment ID.
- Only `PENDING` bookings whose show is still bookable can be paid; cancelled bookings and started/terminal shows → `409`.
- `outcome=COMPLETED` marks the payment `COMPLETED` **and atomically confirms the booking**; `outcome=FAILED` marks it `FAILED` and leaves the booking `PENDING`.
- `COMPLETED`/`REFUNDED` payments cannot be processed again → `409`.

---

## 7. Request DTOs and validation

| DTO | Fields (constraints) |
| --- | --- |
| `Signup` | `name` (required, ≤100), `email` (required, valid email, ≤254), `password` (required, 8–72 chars; enforced ≤72 UTF-8 bytes) |
| `Signin` | `email` (required, valid email, ≤254), `password` (required, ≤72) |
| `UserUpdate` | `name` (required, ≤100), `email` (required, valid, ≤254), `role` (`ADMIN`\|`CUSTOMER`, required) |
| `MovieRequest` | `title` (required, ≤200), `description` (required, ≤4000), `duration` (1–1440 min), `language` (required, ≤50), `genre` (required, ≤80), `releaseDate` (`YYYY-MM-DD`, required), `status` (required) |
| `TheatreRequest` | `name` (required, ≤150), `location` (required, ≤250), `capacity` (1–10000), `status` (required) |
| `ShowRequest` | `movieId` (>0), `theatreId` (>0), `showDate` (`YYYY-MM-DD`), `showTime` (`HH:mm:ss`), `ticketPrice` (0.01–999999.99, ≤2 decimals), `status` (required) |
| `BookingRequest` | `showId` (>0), `seatNumbers` (non-empty, ≤10000 entries, each ≤12 chars), `numberOfTickets` (1–10000) |
| `BookingStatusRequest` | `status` (`PENDING`\|`CONFIRMED`\|`CANCELLED`, required) |
| `PaymentRequest` | `bookingId` (>0), `paymentMethod` (`SIMULATED`, required) |
| `ProcessPayment` | `outcome` (`COMPLETED`\|`FAILED`, required) |

Seat labels use ten positions per row: `A1`–`A10`, `B1`–`B10`, continuing after `Z` as `AA…`; the final row is truncated to the theatre capacity.

---

## 8. Response DTOs

| DTO | Fields |
| --- | --- |
| `UserView` | `id`, `name`, `email`, `role` |
| `TokenView` | `token`, `tokenType` (`Bearer`), `expiresIn` (seconds), `user` (`UserView`) |
| `MovieView` | `id`, `title`, `description`, `duration`, `language`, `genre`, `releaseDate`, `status` |
| `TheatreView` | `id`, `name`, `location`, `capacity`, `status` |
| `ShowView` | `id`, `movieId`, `theatreId`, `showDate`, `showTime`, `ticketPrice`, `status` |
| `SeatsView` | `showId`, `capacity`, `bookable` (boolean), `totalSeats[]`, `reservedSeats[]`, `availableSeats[]` |
| `BookingView` | `id`, `userId`, `showId`, `seatNumbers[]`, `numberOfTickets`, `totalAmount`, `bookingDate`, `status` |
| `PaymentView` | `id`, `bookingId`, `amount`, `paymentDate` (null until processed/cancelled), `paymentMethod`, `status` |
| `PaymentStatusView` | `id`, `status` |

---

## 9. Worked example (customer booking → payment → refund)

```http
# 1. Sign in as an existing customer
POST /api/auth/signin
{ "email": "customer@example.com", "password": "ExampleOnly123!" }
# → 200 TokenView  (use token as: Authorization: Bearer <token>)

# 2. Read the seat map for a scheduled show
GET /api/shows/1/seats
# → 200 SeatsView

# 3. Reserve seats (server computes total)
POST /api/bookings
Authorization: Bearer <token>
{ "showId": 1, "seatNumbers": ["A1", "A2"], "numberOfTickets": 2 }
# → 201 BookingView (status PENDING, totalAmount 2501.00)

# 4. Create a simulated payment (amount derived from booking)
POST /api/payments
Authorization: Bearer <token>
{ "bookingId": 1, "paymentMethod": "SIMULATED" }
# → 201 PaymentView (status PENDING)

# 5a. Simulate a failed charge, then retry successfully with the same payment id
POST /api/payments/1/process   { "outcome": "FAILED"    }  # → 200 PaymentView (FAILED)
POST /api/payments/1/process   { "outcome": "COMPLETED" }  # → 200 PaymentView (COMPLETED), booking CONFIRMED

# 5b. Or cancel the booking before the show starts (releases seats, refunds payment)
PUT /api/bookings/1/cancel
Authorization: Bearer <token>
# → 200 BookingView (CANCELLED); GET /api/payments/1 → status REFUNDED
```

---

## 10. Notes for UI and integration clients

- Catalog reads require a valid token; there is no unauthenticated browse. A login is the first screen.
- A seat-availability snapshot can be stale: expect and handle `409` when submitting a booking, then reload the seat map.
- Cross-origin browser access requires CORS. Spring Security currently permits same-origin/MockMvc requests and denies others, so before serving a separate-origin front-end a CORS allow-list must be added in `SecurityConfig` for the exact UI origin(s), e.g. `http://localhost:5173` (and OPTIONS preflight must be permitted).
- Do not bypass the API by writing reservations directly to SQL: seat concurrency safety relies on the service-level pessimistic locks on the Show.

---

*This document mirrors the implementation in `controller/`, `dto/`, and `service/`. If those change, update this reference accordingly.*
