param([switch]$FirstStart)
$ErrorActionPreference = 'Stop'
$local = Join-Path (Split-Path $PSScriptRoot -Parent) '.local'
$config = Import-Clixml (Join-Path $local 'credentials.clixml')
if (Get-NetTCPConnection -LocalPort $config.DatabasePort -State Listen -ErrorAction SilentlyContinue) {
    throw "Port $($config.DatabasePort) is already in use. The local server may already be running."
}
$arguments = @(
    '--no-defaults', "--basedir=$($config.MySqlHome)", "--datadir=$(Join-Path $local 'mysql-data')",
    "--port=$($config.DatabasePort)", '--bind-address=127.0.0.1', '--mysqlx=0', '--skip-name-resolve',
    "--log-error=$(Join-Path $local 'mysql-error.log')", "--pid-file=$(Join-Path $local 'mysql.pid')",
    '--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci'
)
if ($FirstStart) {
    $bootstrap = Join-Path $local 'mysql-bootstrap.sql'
    if (-not (Test-Path $bootstrap)) { throw 'First-start SQL not found; omit -FirstStart on subsequent runs.' }
    $arguments += "--init-file=$bootstrap"
}
Write-Host "Starting project MySQL on 127.0.0.1:$($config.DatabasePort). Keep this terminal open."
& (Join-Path $config.MySqlHome 'bin\mysqld.exe') @arguments
if ($LASTEXITCODE -ne 0) { throw 'MySQL stopped with an error. Inspect .local/mysql-error.log privately.' }
