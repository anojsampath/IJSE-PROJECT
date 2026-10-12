param([switch]$BootstrapAdmin)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw 'Java was not found. Install a Java 21 JDK and add its bin directory to PATH.'
}
if (-not (Test-Path (Join-Path $projectRoot '.local\credentials.clixml'))) {
    throw 'Local setup is missing. Follow USER_GUIDE.html to initialize MySQL, or run java -jar manually with your own environment.'
}
. (Join-Path $PSScriptRoot 'Use-LocalEnvironment.ps1') -BootstrapAdmin:$BootstrapAdmin
if (-not (Get-NetTCPConnection -LocalPort $localConfig.DatabasePort -State Listen -ErrorAction SilentlyContinue)) {
    throw 'MySQL is not listening. Start scripts/Start-LocalMySql.ps1 in another terminal first.'
}
if (Get-NetTCPConnection -LocalPort $localConfig.ApplicationPort -State Listen -ErrorAction SilentlyContinue) {
    throw "API port $($localConfig.ApplicationPort) is already in use. Check the existing process; this script will not stop it."
}
$jar = Join-Path $projectRoot 'target\movie-booking-0.0.1-SNAPSHOT.jar'
if (-not (Test-Path $jar)) { $jar = Join-Path $projectRoot 'app\movie-booking.jar' }
if (-not (Test-Path $jar)) {
    throw 'Application JAR not found. Run .\mvnw.cmd verify from the project root first.'
}
Write-Host "Starting Movie Booking API at http://127.0.0.1:$env:PORT (no graphical homepage)."
Write-Host 'Keep this terminal open. Wait for the Started MovieBookingApplication message; Ctrl+C stops the API.'
try {
    & java -jar $jar
    if ($LASTEXITCODE -ne 0) { throw "Application exited with code $LASTEXITCODE. Check the startup error above." }
} finally {
    $env:ADMIN_BOOTSTRAP_ENABLED = 'false'
    $env:ADMIN_PASSWORD = $null
}
