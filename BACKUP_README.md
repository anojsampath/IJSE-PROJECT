# Movie Ticket Booking - Full System Backup (MovieBooking-Backup-20261011-184529)

Self-contained backup of the combined system: MySQL data dumps, full backend and
frontend source, configuration and documentation. Extracted from the workspace on
2026-10-11 18:45:30 local time.

## Contents
- `database/movie_booking.sql` - live application data (users, movies, theatres, shows, bookings, payments).
- `database/movie_booking_test.sql` - isolated MySQL integration-test schema data.
- `backend/` - Spring Boot 4 / Java 21 source, Maven wrapper, Flyway migrations, PowerShell scripts, README, API documentation, user guide.
- `frontend/` - React 18 + Vite source and configuration (`node_modules` excluded; run `npm install`).
- `SETUP.md` - combined and standalone startup guides with all environment variables.
- `RESPONSIVE_DESIGN.md` - mobile/tablet/desktop layout analysis.

## Architecture
Controller -> Service -> Repository -> MySQL. Stateless JWT security (issuer movie-booking),
BCrypt password hashing, Flyway schema migrations, pessimistic locking on Show rows for
concurrent seat booking, simulated payment lifecycle (PENDING -> COMPLETED/FAILED, refund on cancel).

    [Browser SPA React/Vite :5173] --/api proxy--> [Spring Boot API :8081] --JDBC--> [MySQL 8 :3306]

## ERD (see backend/README.md and API_DOCUMENTATION.md for details)
    User(1) -- (*) Booking        Movie(1) -- (*) Show
    Theatre(1) -- (*) Show        Show(1) -- (*) Booking
    Booking(1) -- (0..1) Payment  Booking(*) -- seats element collection

## API endpoint groups (full reference: backend/API_DOCUMENTATION.md)
- `/api/auth` signup, signin (public)
- `/api/movies` CRUD (ADMIN), `/api/movies/{id}/shows`
- `/api/theatres` CRUD (ADMIN)
- `/api/shows` CRUD (ADMIN), `/api/shows/{id}/seats` availability
- `/api/bookings` reserve, my-bookings, cancel (refund), status (ADMIN)
- `/api/payments` create, process outcome (simulated)
- `/api/users/{id}` role updates (ADMIN)

## Restore
1. Start MySQL 8+ (or use backend/scripts/Initialize-LocalMySql.ps1 + Start-LocalMySql.ps1).
2. `& "<MySQL bin>\mysql.exe" -u root -p -e "source database/movie_booking.sql"` (repeat for the test dump).
   The dumps recreate the schemas; database accounts are NOT recreated - run Initialize-LocalMySql.ps1
   for local credentials, or grant an existing account access to the restored schemas.
3. Follow SETUP.md Scenario 1 (combined), 2 (backend only) or 3 (frontend only).

## Excluded by policy (same rules as Build-Distribution.ps1)
DPAPI credential store (`.local/credentials.clixml`), MySQL data directory, JWT secret,
admin password, Git history, build outputs (`target/`, `dist/`), `node_modules`, logs, .env files.
Password material inside the dumps is bcrypt-hashed only.

Manifest: `BACKUP-MANIFEST.json` lists SHA-256 for every file in this archive.
