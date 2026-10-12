param(
    [string]$MySqlHome = 'C:\Program Files\MySQL\MySQL Server 8.4',
    [ValidateRange(1024, 65535)][int]$DatabasePort = 3306,
    [ValidateRange(1024, 65535)][int]$ApplicationPort = 8081
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$local = Join-Path $root '.local'
$data = Join-Path $local 'mysql-data'
$credentialsPath = Join-Path $local 'credentials.clixml'
$server = Join-Path $MySqlHome 'bin\mysqld.exe'
if (-not (Test-Path $server)) { throw "MySQL server executable not found: $server" }
if ((Test-Path $data) -or (Test-Path $credentialsPath)) {
    throw 'Local database setup already exists. Refusing to overwrite data or credentials.'
}
if (Get-NetTCPConnection -LocalPort $DatabasePort -State Listen -ErrorAction SilentlyContinue) {
    throw "Port $DatabasePort is already in use. Choose another DatabasePort."
}
New-Item -ItemType Directory -Path $local -Force | Out-Null
# Limit all local data, temporary bootstrap SQL, and encrypted secrets to this Windows account.
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$acl = Get-Acl $local
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
$acl.SetAccessRule($rule)
Set-Acl -Path $local -AclObject $acl
function New-RandomSecret {
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    [Convert]::ToBase64String($bytes)
}
$rootPassword = New-RandomSecret
$devPassword = New-RandomSecret
$testPassword = New-RandomSecret
$adminPassword = New-RandomSecret
$jwtSecret = New-RandomSecret
$config = [pscustomobject]@{
    MySqlHome = $MySqlHome
    DatabasePort = $DatabasePort
    ApplicationPort = $ApplicationPort
    RootPassword = ConvertTo-SecureString $rootPassword -AsPlainText -Force
    DevelopmentPassword = ConvertTo-SecureString $devPassword -AsPlainText -Force
    TestPassword = ConvertTo-SecureString $testPassword -AsPlainText -Force
    AdminEmail = 'admin@example.com'
    AdminPassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
    JwtSecret = ConvertTo-SecureString $jwtSecret -AsPlainText -Force
}
# SecureString values are encrypted by Windows DPAPI for this user on this computer.
$config | Export-Clixml -Path $credentialsPath
# This file is needed only for first startup and must not be committed or shared.
@"
ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootPassword';
CREATE DATABASE movie_booking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE movie_booking_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'movie_booking'@'127.0.0.1' IDENTIFIED BY '$devPassword';
CREATE USER 'movie_booking_test'@'127.0.0.1' IDENTIFIED BY '$testPassword';
GRANT ALL PRIVILEGES ON movie_booking.* TO 'movie_booking'@'127.0.0.1';
GRANT ALL PRIVILEGES ON movie_booking_test.* TO 'movie_booking_test'@'127.0.0.1';
"@ | Set-Content -Path (Join-Path $local 'mysql-bootstrap.sql') -Encoding ASCII
& $server --no-defaults "--basedir=$MySqlHome" "--datadir=$data" "--log-error=$(Join-Path $local 'mysql-error.log')" --initialize
if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $data 'auto.cnf'))) {
    throw 'MySQL initialization failed. Inspect the private .local/mysql-error.log.'
}
Write-Host 'Project-only MySQL data initialized. Credentials saved with Windows user encryption.'
Write-Host 'Start the server with scripts/Start-LocalMySql.ps1 -FirstStart, then remove the bootstrap SQL after verification.'
