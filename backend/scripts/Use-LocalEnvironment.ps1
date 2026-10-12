param([switch]$BootstrapAdmin)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$localConfig = Import-Clixml (Join-Path $projectRoot '.local\credentials.clixml')
function ConvertFrom-LocalSecret([System.Security.SecureString]$secret) {
    ([System.Net.NetworkCredential]::new('', $secret)).Password
}
# Password retrieval is permitted only for this loopback-only development instance.
$connectionOptions = '?sslMode=DISABLED&allowPublicKeyRetrieval=true'
$env:DB_URL = "jdbc:mysql://127.0.0.1:$($localConfig.DatabasePort)/movie_booking$connectionOptions"
$env:DB_USERNAME = 'movie_booking'
$env:DB_PASSWORD = ConvertFrom-LocalSecret $localConfig.DevelopmentPassword
$env:DB_TEST_URL = "jdbc:mysql://127.0.0.1:$($localConfig.DatabasePort)/movie_booking_test$connectionOptions"
$env:DB_TEST_USERNAME = 'movie_booking_test'
$env:DB_TEST_PASSWORD = ConvertFrom-LocalSecret $localConfig.TestPassword
$env:JWT_SECRET = ConvertFrom-LocalSecret $localConfig.JwtSecret
$env:PORT = [string]$localConfig.ApplicationPort
$env:SERVER_ADDRESS = '127.0.0.1'
$env:ADMIN_BOOTSTRAP_ENABLED = 'false'
$env:ADMIN_PASSWORD = $null
if ($BootstrapAdmin) {
    $env:ADMIN_BOOTSTRAP_ENABLED = 'true'
    $env:ADMIN_NAME = 'Local Administrator'
    $env:ADMIN_EMAIL = $localConfig.AdminEmail
    $env:ADMIN_PASSWORD = ConvertFrom-LocalSecret $localConfig.AdminPassword
}
$env:MAVEN_USER_HOME = Join-Path $projectRoot '.mvn'
Write-Host "Loaded local environment. Database: 127.0.0.1:$($localConfig.DatabasePort); API: http://127.0.0.1:$env:PORT"
