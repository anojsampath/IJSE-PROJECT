# Creates a self-contained backup distribution ZIP:
#   - live MySQL data dumps (movie_booking + movie_booking_test)
#   - backend and frontend source (allowlist, no node_modules/target/.local)
#   - setup + responsive docs and a generated BACKUP_README
#   - SHA-256 manifest, post-write verification, .sha256 sidecar
# Exclusion rules follow Build-Distribution.ps1: no credentials, no .local
# database files, no Git history, no logs, no dependency caches.
$ErrorActionPreference = 'Stop'
$backendRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = Split-Path $backendRoot -Parent
$clixml = Join-Path $backendRoot '.local\credentials.clixml'
if (-not (Test-Path $clixml)) { throw 'Local credentials are required for the database dump. Run Initialize-LocalMySql.ps1 first.' }
$localConfig = Import-Clixml $clixml
$mysqldump = Join-Path $localConfig.MySqlHome 'bin\mysqldump.exe'
if (-not (Test-Path $mysqldump)) { throw "mysqldump.exe not found under $($localConfig.MySqlHome)." }
if (-not (Get-NetTCPConnection -LocalPort $localConfig.DatabasePort -State Listen -ErrorAction SilentlyContinue)) {
    throw "MySQL is not listening on port $($localConfig.DatabasePort). Start scripts/Start-LocalMySql.ps1 first."
}

function Get-PlainSecret([System.Security.SecureString]$s) { ([System.Net.NetworkCredential]::new('', $s)).Password }
function Test-Forbidden([string]$relative) {
    $normalized = $relative.Replace('\', '/')
    return $normalized -match '(^|/)(\.local|node_modules|\.git|target|dist)(/|$)' -or
           $normalized -match '\.(clixml|log|env)$' -or $normalized -match '(^|/)\.env'
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$packageRoot = "MovieBooking-Backup-$stamp"
$files = [ordered]@{}   # package-relative path -> source absolute path
$staging = Join-Path ([IO.Path]::GetTempPath()) "mbbackup-$stamp"
New-Item -ItemType Directory -Path $staging -Force | Out-Null
try {
    # 1. Database backups ------------------------------------------------------------
    $dbDir = Join-Path $staging "$packageRoot/database"
    New-Item -ItemType Directory -Path $dbDir -Force | Out-Null
    $dumps = @(
        @{ Db = 'movie_booking'; User = 'movie_booking'; Password = (Get-PlainSecret $localConfig.DevelopmentPassword) },
        @{ Db = 'movie_booking_test'; User = 'movie_booking_test'; Password = (Get-PlainSecret $localConfig.TestPassword) }
    )
    foreach ($d in $dumps) {
        $out = Join-Path $dbDir "$($d.Db).sql"
        $prevPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $mysqldump '--no-defaults' '--host=127.0.0.1' "--port=$($localConfig.DatabasePort)" "--user=$($d.User)" "--password=$($d.Password)" `
            '--single-transaction' '--routines' '--triggers' '--events' '--default-character-set=utf8mb4' `
            '--databases' $d.Db "--result-file=$out" 2>$null | Out-Null
        $dumpExit = $LASTEXITCODE
        $ErrorActionPreference = $prevPreference
        if ($dumpExit -ne 0 -or -not (Test-Path $out)) { throw "mysqldump failed for $($d.Db)." }
        $files["database/$($d.Db).sql"] = $out
        Write-Host "D dumped $($d.Db) -> database/$($d.Db).sql ($([math]::Round((Get-Item $out).Length/1KB,1)) KB)"
    }

    # 2. Approved file set -----------------------------------------------------------
    $fixed = @(
        @{ Pkg = '.gitignore'; Src = (Join-Path $repoRoot '.gitignore') },
        @{ Pkg = 'SETUP.md'; Src = (Join-Path $repoRoot 'SETUP.md') },
        @{ Pkg = 'RESPONSIVE_DESIGN.md'; Src = (Join-Path $repoRoot 'RESPONSIVE_DESIGN.md') },
        @{ Pkg = 'backend/pom.xml'; Src = (Join-Path $backendRoot 'pom.xml') },
        @{ Pkg = 'backend/mvnw'; Src = (Join-Path $backendRoot 'mvnw') },
        @{ Pkg = 'backend/mvnw.cmd'; Src = (Join-Path $backendRoot 'mvnw.cmd') },
        @{ Pkg = 'backend/.mvn/wrapper/maven-wrapper.properties'; Src = (Join-Path $backendRoot '.mvn\wrapper\maven-wrapper.properties') },
        @{ Pkg = 'backend/README.md'; Src = (Join-Path $backendRoot 'README.md') },
        @{ Pkg = 'backend/USER_GUIDE.html'; Src = (Join-Path $backendRoot 'USER_GUIDE.html') },
        @{ Pkg = 'backend/API_DOCUMENTATION.md'; Src = (Join-Path $backendRoot 'API_DOCUMENTATION.md') },
        @{ Pkg = 'frontend/index.html'; Src = (Join-Path $repoRoot 'frontend\index.html') },
        @{ Pkg = 'frontend/package.json'; Src = (Join-Path $repoRoot 'frontend\package.json') },
        @{ Pkg = 'frontend/package-lock.json'; Src = (Join-Path $repoRoot 'frontend\package-lock.json') },
        @{ Pkg = 'frontend/vite.config.js'; Src = (Join-Path $repoRoot 'frontend\vite.config.js') }
    )
    foreach ($item in $fixed) {
        if (-not (Test-Path $item.Src -PathType Leaf)) { throw "Required package input missing: $($item.Pkg)" }
        $files[$item.Pkg] = $item.Src
    }
    foreach ($script in Get-ChildItem (Join-Path $backendRoot 'scripts') -Filter '*.ps1' -File) {
        $files["backend/scripts/$($script.Name)"] = $script.FullName
    }
    foreach ($tree in @(
        @{ Src = (Join-Path $backendRoot 'src'); PkgPrefix = 'backend/src' },
        @{ Src = (Join-Path $repoRoot 'frontend\src'); PkgPrefix = 'frontend/src' }
    )) {
        foreach ($f in Get-ChildItem $tree.Src -Recurse -File -Force) {
            $rel = $tree.PkgPrefix + '/' + $f.FullName.Substring($tree.Src.Length + 1).Replace('\', '/')
            $files[$rel] = $f.FullName
        }
    }
    foreach ($rel in @($files.Keys)) {
        if (Test-Forbidden $rel) { throw "Forbidden path would have been packaged: $rel" }
    }

    # 3. Generated backup README -----------------------------------------------------
    $readme = @'
# Movie Ticket Booking - Full System Backup (%PACKAGE%)

Self-contained backup of the combined system: MySQL data dumps, full backend and
frontend source, configuration and documentation. Extracted from the workspace on
%DATE% local time.

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
'@
    $readme = $readme.Replace('%PACKAGE%', $packageRoot).Replace('%DATE%', (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
    Set-Content -LiteralPath (Join-Path $staging "$packageRoot/BACKUP_README.md") -Value $readme -Encoding UTF8
    $files['BACKUP_README.md'] = Join-Path $staging "$packageRoot/BACKUP_README.md"

    # 4. Manifest --------------------------------------------------------------------
    $hashes = [ordered]@{}
    foreach ($rel in @($files.Keys)) {
        $src = $files[$rel]
        if (Test-Forbidden $rel) { throw "Forbidden path in manifest: $rel" }
        if ($src.StartsWith($staging)) {
            $dest = Join-Path $staging "$packageRoot/$($rel.Replace('/', '\'))"
            New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
            if ($src -ne $dest) { Copy-Item $src $dest -Force }
        } else {
            $dest = Join-Path $staging "$packageRoot/$($rel.Replace('/', '\'))"
            New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
            Copy-Item $src $dest -Force
        }
        $hashes[$rel] = (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    $manifest = [ordered]@{
        package = 'MovieBooking-Backup'; createdUtc = [DateTime]::UtcNow.ToString('o')
        contents = @('database dumps', 'backend source', 'frontend source', 'documentation', 'configuration')
        excluded = @('credentials (.clixml, .env)', '.local MySQL data', 'Git history', 'target/ and dist/ builds', 'node_modules', 'logs')
        fileCount = $hashes.Count
        files = $hashes
    } | ConvertTo-Json -Depth 6
    $manifestPath = Join-Path $staging "$packageRoot/BACKUP-MANIFEST.json"
    [IO.File]::WriteAllText($manifestPath, $manifest, [Text.UTF8Encoding]::new($false))

    # 5. Zip + verification -----------------------------------------------------------
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $distDir = Join-Path $backendRoot 'dist'
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
    $zipPath = Join-Path $distDir "$packageRoot.zip"
    [IO.Compression.ZipFile]::CreateFromDirectory($staging, $zipPath, [IO.Compression.CompressionLevel]::Optimal, $false)

    $archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $seen = 0
        foreach ($entry in $archive.Entries) {
            $normalizedName = $entry.FullName.Replace('\', '/')
            if ($normalizedName.EndsWith('/')) { continue }
            if (-not $normalizedName.StartsWith("$packageRoot/")) { throw "ZIP contains an unexpected root: $($entry.FullName)" }
            $pkgRel = $normalizedName.Substring("$packageRoot/".Length)
            $seen++
            if (Test-Forbidden $pkgRel) { throw "Forbidden entry inside ZIP: $pkgRel" }
            if ($pkgRel -eq 'BACKUP-MANIFEST.json') { continue }
            $stream = $entry.Open()
            $sha = [Security.Cryptography.SHA256]::Create()
            try { $actual = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-', '').ToLowerInvariant() }
            finally { $sha.Dispose(); $stream.Dispose() }
            if (-not $hashes.Contains($pkgRel)) { throw "ZIP contains unapproved entry: $pkgRel" }
            if ($actual -ne $hashes[$pkgRel]) { throw "ZIP payload hash mismatch: $pkgRel" }
        }
        Write-Host "V verified $seen ZIP entries against the manifest."
    } finally { $archive.Dispose() }
    $zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    "$zipHash  $packageRoot.zip" | Set-Content -LiteralPath "$zipPath.sha256" -Encoding ASCII
    Write-Host "OUTPUT: $zipPath ($([math]::Round((Get-Item $zipPath).Length/1MB,2)) MB)"
    Write-Host "SHA256: $zipHash"
    Write-Host "SIDECAR: $zipPath.sha256"
} finally {
    Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
}
