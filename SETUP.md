# Movie Ticket Booking System - Setup Guide

This document provides complete instructions for running the Movie Ticket Booking system in three scenarios: combined (full stack), backend-only, and frontend-only.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Scenario 1: Combined System (Recommended)](#scenario-1-combined-system-recommended)
- [Scenario 2: Backend API Only](#scenario-2-backend-api-only)
- [Scenario 3: Frontend Development Server Only](#scenario-3-frontend-development-server-only)
- [Environment Variables Reference](#environment-variables-reference)
- [Configuration Adjustments](#configuration-adjustments)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Java 21 JDK** (or later) — [Download](https://adoptium.net/)
- **Node.js 18+** (includes npm) — [Download](https://nodejs.org/)
- **Git** — [Download](https://git-scm.com/)
- **MySQL 8.0+** (for backend) — [Download](https://dev.mysql.com/downloads/mysql/)

### Optional
- **Postman** or **curl** — for API testing
- **Modern web browser** (Chrome, Firefox, Edge, Safari)

### Verify Installation
```bash
java -version        # Should show 21.x or later
node --version       # Should show v18.x or later
npm --version        # Should show 9.x or later
mysql --version      # Should show 8.x or later
```

---

## Scenario 1: Combined System (Recommended)

This runs the full stack: MySQL database + Spring Boot API + React frontend.

### Step 1: Clone and Navigate
```bash
git clone <your-repo-url>
cd "final project"
```

### Step 2: Initialize Local Environment (First Time Only)

The backend uses a local setup script that creates encrypted credentials and configures MySQL.

```bash
cd backend
.\scripts\Initialize-LocalMySql.ps1 -FirstStart
```

This script:
- Creates `.local\credentials.clixml` with DPAPI-encrypted secrets
- Initializes MySQL with `movie_booking` database and user
- Generates a random JWT secret
- Creates an administrator account

**Note:** On Windows, this uses DPAPI encryption tied to your user account. The credentials are stored locally and never committed to Git.

### Step 3: Start MySQL (Terminal 1)
```bash
cd backend
.\scripts\Start-LocalMySql.ps1
```
Keep this terminal open. MySQL runs on `127.0.0.1:3306`.

### Step 4: Build and Start Backend API (Terminal 2)
```bash
cd backend
.\mvnw.cmd package -DskipTests
.\scripts\Start-LocalApp.ps1
```
Keep this terminal open. Wait for the message:
```
Started MovieBookingApplication in XX seconds
```
API runs on `http://127.0.0.1:8081`.

### Step 5: Install Frontend Dependencies (First Time Only)
```bash
cd frontend
npm install
```

### Step 6: Start Frontend Dev Server (Terminal 3)
```bash
cd frontend
npm run dev
```
Frontend runs on `http://127.0.0.1:5173`.

### Step 7: Access the Application
Open your browser to **http://127.0.0.1:5173**

**Login credentials** (created during initialization):
- **Administrator:** Check `.local\credentials.clixml` for the admin email/password, or use the bootstrap script to create one:
  ```bash
  .\scripts\Start-LocalApp.ps1 -BootstrapAdmin
  ```
- **Customer:** Register via the UI at `/login` → "Register" tab

### Stopping the System
Press `Ctrl+C` in each terminal in reverse order:
1. Frontend (Terminal 3)
2. Backend API (Terminal 2)
3. MySQL (Terminal 1)

---

## Scenario 2: Backend API Only

Run the Spring Boot REST API independently (useful for API testing, mobile apps, or third-party integrations).

### Prerequisites
- MySQL 8.0+ running and accessible
- Java 21 JDK

### Option A: Using Local Helper Scripts

If you've already run `Initialize-LocalMySql.ps1`:

```bash
cd backend
.\mvnw.cmd package -DskipTests
.\scripts\Start-LocalApp.ps1
```

This loads all environment variables from `.local\credentials.clixml` automatically.

### Option B: Manual Configuration (Standalone)

If you don't have the local setup or want to use your own MySQL instance:

#### 1. Build the JAR
```bash
cd backend
.\mvnw.cmd package -DskipTests
```

#### 2. Set Environment Variables

**PowerShell:**
```powershell
$env:DB_URL = 'jdbc:mysql://127.0.0.1:3306/movie_booking?sslMode=DISABLED&allowPublicKeyRetrieval=true'
$env:DB_USERNAME = 'movie_booking'
$env:DB_PASSWORD = 'your_database_password'
$env:JWT_SECRET = 'your_jwt_secret_at_least_32_bytes_long'
$env:PORT = '8081'
```

**Linux/macOS (bash):**
```bash
export DB_URL='jdbc:mysql://127.0.0.1:3306/movie_booking?sslMode=DISABLED&allowPublicKeyRetrieval=true'
export DB_USERNAME='movie_booking'
export DB_PASSWORD='your_database_password'
export JWT_SECRET='your_jwt_secret_at_least_32_bytes_long'
export PORT='8081'
```

#### 3. Create MySQL Database and User
```sql
CREATE DATABASE movie_booking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'movie_booking'@'127.0.0.1' IDENTIFIED BY 'your_database_password';
GRANT ALL PRIVILEGES ON movie_booking.* TO 'movie_booking'@'127.0.0.1';
FLUSH PRIVILEGES;
```

#### 4. (Optional) Bootstrap Administrator
To create an admin account on first startup:
```powershell
$env:ADMIN_BOOTSTRAP_ENABLED = 'true'
$env:ADMIN_NAME = 'Administrator'
$env:ADMIN_EMAIL = 'admin@example.com'
$env:ADMIN_PASSWORD = 'SecureAdminPassword123!'
```

#### 5. Start the API
```bash
java -jar target\movie-booking-0.0.1-SNAPSHOT.jar
```

Wait for:
```
Started MovieBookingApplication in XX seconds
Tomcat started on port 8081 (http)
```

### Verify API is Running
```bash
curl http://127.0.0.1:8081/api/movies
# Should return 401 Unauthorized (no JWT token)
```

### API Documentation
See [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md) for the full REST API reference.

---

## Scenario 3: Frontend Development Server Only

Run the React/Vite development server independently (useful for UI development, design work, or when the backend is hosted elsewhere).

### Prerequisites
- Node.js 18+

### Step 1: Install Dependencies
```bash
cd frontend
npm install
```

### Step 2: Start Development Server
```bash
npm run dev
```

The dev server starts at **http://127.0.0.1:5173**.

### Step 3: Configure Backend Connection

By default, the frontend proxies `/api` requests to `http://127.0.0.1:8081`. If your backend runs on a different host or port, set the proxy target:

**PowerShell:**
```powershell
$env:VITE_PROXY_TARGET = 'http://127.0.0.1:9090'
npm run dev
```

**Linux/macOS:**
```bash
VITE_PROXY_TARGET='http://127.0.0.1:9090' npm run dev
```

### Alternative: Direct Cross-Origin Calls

Instead of using the proxy, you can configure the frontend to call the backend directly (requires CORS to be enabled on the backend):

**PowerShell:**
```powershell
$env:VITE_API_BASE = 'http://127.0.0.1:8081/api'
npm run dev
```

**Linux/macOS:**
```bash
VITE_API_BASE='http://127.0.0.1:8081/api' npm run dev
```

**Note:** When using `VITE_API_BASE`, the backend's CORS configuration must allow the frontend's origin. The default CORS settings allow `http://localhost:5173` and `http://127.0.0.1:5173`.

### Behavior Without Backend

If the backend is not running, the frontend will:
- Load and render pages
- Show "Cannot reach the API server. Is the backend running?" on data fetch failures
- Allow navigation but all data operations (login, browse, book) will fail

### Production Build

To create a production build:
```bash
npm run build
```

Output is in `frontend/dist/`. Serve with any static file server:
```bash
npm run preview   # Runs on http://127.0.0.1:4173
```

**Important:** For production builds, set `VITE_API_BASE` at **build time** to bake in the backend URL:
```bash
$env:VITE_API_BASE = 'https://api.yourdomain.com/api'
npm run build
```

---

## Environment Variables Reference

### Backend (Spring Boot)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DB_URL` | Yes | — | JDBC connection string to MySQL |
| `DB_USERNAME` | Yes | — | MySQL username |
| `DB_PASSWORD` | Yes | — | MySQL password |
| `JWT_SECRET` | Yes | — | Secret key for JWT signing (≥32 bytes) |
| `PORT` | No | `8080` | HTTP port for the API |
| `SERVER_ADDRESS` | No | `0.0.0.0` | Bind address |
| `CORS_ALLOWED_ORIGINS` | No | `http://localhost:5173,http://127.0.0.1:5173` | Comma-separated list of allowed CORS origins |
| `ADMIN_BOOTSTRAP_ENABLED` | No | `false` | Enable admin account creation on startup |
| `ADMIN_NAME` | No | `Administrator` | Admin account name |
| `ADMIN_EMAIL` | No | — | Admin account email |
| `ADMIN_PASSWORD` | No | — | Admin account password |

### Frontend (Vite)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `VITE_PROXY_TARGET` | No | `http://127.0.0.1:8081` | Backend URL for dev proxy |
| `VITE_API_BASE` | No | `/api` | Absolute backend URL (bypasses proxy) |

---

## Configuration Adjustments

### Change Backend Port

If you want the API to run on a different port (e.g., 9090):

**Option 1: Environment variable**
```powershell
$env:PORT = '9090'
.\scripts\Start-LocalApp.ps1
```

**Option 2: Update `application.yml`**
```yaml
server:
  port: 9090
```

Then update the frontend proxy target:
```powershell
$env:VITE_PROXY_TARGET = 'http://127.0.0.1:9090'
npm run dev
```

### Enable CORS for Additional Origins

If your frontend runs on a different origin (e.g., `http://localhost:3000`), update the CORS configuration:

**Edit `backend/src/main/resources/application.yml`:**
```yaml
app:
  cors:
    allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000}
```

Or set the environment variable:
```powershell
$env:CORS_ALLOWED_ORIGINS = 'http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000'
```

Rebuild and restart the backend:
```bash
.\mvnw.cmd package -DskipTests
.\scripts\Start-LocalApp.ps1
```

### Use External MySQL Server

To connect to a remote or cloud-hosted MySQL instance:

```powershell
$env:DB_URL = 'jdbc:mysql://db.example.com:3306/movie_booking?sslMode=REQUIRED'
$env:DB_USERNAME = 'movie_booking'
$env:DB_PASSWORD = 'your_password'
```

Ensure the MySQL user has remote access permissions.

### Disable Admin Bootstrap

After initial setup, disable admin bootstrap to prevent re-creation:

```powershell
$env:ADMIN_BOOTSTRAP_ENABLED = 'false'
```

Or remove the `ADMIN_*` environment variables entirely.

---

## Troubleshooting

### Backend Issues

#### "Application exited with code 1"
- Check the error message above for details
- Common causes:
  - MySQL not running → Start with `.\scripts\Start-LocalMySql.ps1`
  - Missing environment variables → Ensure `DB_PASSWORD` and `JWT_SECRET` are set
  - Port already in use → Change `PORT` or stop the conflicting process

#### "Could not resolve placeholder 'JWT_SECRET'"
- `JWT_SECRET` is required and has no default
- Set it in the environment or use the local helper scripts

#### "Access denied for user 'movie_booking'@'localhost'"
- MySQL user doesn't exist or password is wrong
- Re-run `.\scripts\Initialize-LocalMySql.ps1 -FirstStart` to recreate the user
- Or manually create the user (see [Backend API Only](#option-b-manual-configuration-standalone))

#### "Port 8081 is already in use"
- Another process is using port 8081
- Stop it or change the backend port:
  ```powershell
  $env:PORT = '9090'
  .\scripts\Start-LocalApp.ps1
  ```

### Frontend Issues

#### "Cannot reach the API server. Is the backend running?"
- Backend is not running or not accessible
- Verify backend is running on the expected port
- Check `VITE_PROXY_TARGET` or `VITE_API_BASE` configuration

#### "npm: command not found"
- Node.js is not installed or not in PATH
- Install Node.js from [nodejs.org](https://nodejs.org/)

#### "Module not found" errors
- Dependencies not installed
- Run `npm install` in the `frontend` directory

#### CORS errors in browser console
- Frontend is calling backend cross-origin but CORS is not configured
- Ensure backend's `CORS_ALLOWED_ORIGINS` includes the frontend's origin
- Or use the dev proxy (default behavior)

### Database Issues

#### "Unknown database 'movie_booking'"
- Database doesn't exist
- Flyway should auto-create it on first startup
- If using manual setup, create it:
  ```sql
  CREATE DATABASE movie_booking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  ```

#### "Table 'movie_booking.movie' doesn't exist"
- Flyway migration failed or was skipped
- Check `backend/.local/mysql-error.log` for details
- Re-run the backend startup script

### General Tips

- **Logs:** Backend logs are printed to the console. Frontend logs appear in the browser's developer console (F12).
- **Clean slate:** To reset the database, stop MySQL, delete `backend/.local/mysql-data/`, and re-run `Initialize-LocalMySql.ps1 -FirstStart`.
- **Rebuild:** If you modify backend code, rebuild with `.\mvnw.cmd package -DskipTests` before restarting.
- **Hot reload:** Frontend changes are automatically reflected in the browser (Vite HMR). Backend changes require a restart.

---

## Additional Resources

### Creating a Full Backup Package

To generate a timestamped, self-contained backup ZIP (live MySQL dumps + full source + docs + SHA-256 manifest, credentials excluded — same rules as `Build-Distribution.ps1`):

```powershell
cd 'e:\Projects\Anoj yya\final project\backend'
.\scripts\New-BackupPackage.ps1
```

Requirements: MySQL running (`Start-LocalMySql.ps1`) and `.local\credentials.clixml` present (used only to authorize `mysqldump`; never packaged). Output lands in `backend\dist\MovieBooking-Backup-<timestamp>.zip` with a `.sha256` sidecar. Extract the ZIP and open its `BACKUP_README.md` for restore instructions.

### Documentation
- [Backend API Documentation](backend/API_DOCUMENTATION.md)
- [User Guide](backend/USER_GUIDE.html)
- [Backend README](backend/README.md)
- [Responsive Design Analysis](RESPONSIVE_DESIGN.md)

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the API documentation for endpoint details
3. Inspect browser console and backend logs for error messages
4. Verify all prerequisites are installed and running

---

**Last Updated:** October 2026  
**Version:** 1.0.0
