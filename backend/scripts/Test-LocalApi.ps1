param([switch]$CreateDemo)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Use-LocalEnvironment.ps1')
$base = "http://127.0.0.1:$env:PORT/api"
function Send-Json($method, $path, $body, $headers = @{}) {
    $options = @{ Method = $method; Uri = "$base$path"; Headers = $headers; TimeoutSec = 30 }
    if ($null -ne $body) {
        $options.ContentType = 'application/json'
        $options.Body = $body | ConvertTo-Json -Depth 5
    }
    Invoke-RestMethod @options
}
function Assert-Check([bool]$condition, [string]$message) {
    if (-not $condition) { throw "Verification failed: $message" }
    Write-Host "PASS: $message"
}
$anonymousStatus = 0
try {
    Invoke-WebRequest -UseBasicParsing -Uri "$base/movies" -TimeoutSec 15 | Out-Null
} catch {
    if ($null -eq $_.Exception.Response) { throw 'API is unreachable. Start the application and wait for startup to finish.' }
    $anonymousStatus = [int]$_.Exception.Response.StatusCode
}
Assert-Check ($anonymousStatus -eq 401) 'Unauthenticated catalog access returns 401'
$adminLogin = @{ email = $localConfig.AdminEmail; password = (ConvertFrom-LocalSecret $localConfig.AdminPassword) }
try { $admin = Send-Json POST '/auth/signin' $adminLogin } finally { $adminLogin = $null }
Assert-Check ($admin.user.role -eq 'ADMIN') 'Local administrator signs in'
$ah = @{ Authorization = "Bearer $($admin.token)" }
Send-Json GET '/users' $null $ah | Out-Null
Send-Json GET '/movies' $null $ah | Out-Null
Assert-Check $true 'Authenticated user and movie lists are accessible'
if (-not $CreateDemo) {
    Write-Host 'Read-only API check passed. Use -CreateDemo to create sample records and test booking/payment/refund.'
    return
}
Write-Host 'Creating uniquely labeled demo records in the development database; history is retained.'
$tag = [guid]::NewGuid().ToString('N')
$movie = Send-Json POST '/movies' @{
    title = "Demo Movie $tag"; description = 'Local user-guide demonstration'; duration = 120
    language = 'English'; genre = 'Adventure'; releaseDate = '2026-01-01'; status = 'NOW_SHOWING'
} $ah
$theatre = Send-Json POST '/theatres' @{
    name = "Demo Cinema $tag"; location = 'Colombo'; capacity = 52; status = 'ACTIVE'
} $ah
$show = Send-Json POST '/shows' @{
    movieId = $movie.id; theatreId = $theatre.id
    showDate = (Get-Date).AddDays(7).ToString('yyyy-MM-dd'); showTime = '18:00:00'
    ticketPrice = 1250.50; status = 'SCHEDULED'
} $ah
$customerLogin = @{ name = 'Demo Customer'; email = "demo-$tag@example.com"; password = ([guid]::NewGuid().ToString('N') + '!aA1') }
try {
    Send-Json POST '/auth/signup' $customerLogin | Out-Null
    $customer = Send-Json POST '/auth/signin' @{ email = $customerLogin.email; password = $customerLogin.password }
} finally { $customerLogin = $null }
Assert-Check ($customer.user.role -eq 'CUSTOMER') 'Customer registration and sign-in succeed'
$ch = @{ Authorization = "Bearer $($customer.token)" }
$booking = Send-Json POST '/bookings' @{
    showId = $show.id; seatNumbers = @('A1', 'A2'); numberOfTickets = 2
} $ch
Assert-Check ($booking.status -eq 'PENDING' -and [decimal]$booking.totalAmount -eq 2501.00) 'Two reserved seats cost LKR 2501.00'
$seats = Send-Json GET "/shows/$($show.id)/seats" $null $ch
Assert-Check ($seats.reservedSeats -contains 'A1' -and $seats.reservedSeats -contains 'A2') 'Pending booking reserves both seats'
$payment = Send-Json POST '/payments' @{ bookingId = $booking.id; paymentMethod = 'SIMULATED' } $ch
$failed = Send-Json POST "/payments/$($payment.id)/process" @{ outcome = 'FAILED' } $ch
Assert-Check ($failed.status -eq 'FAILED') 'Simulated failure is recorded'
$paid = Send-Json POST "/payments/$($payment.id)/process" @{ outcome = 'COMPLETED' } $ch
$confirmed = Send-Json GET "/bookings/$($booking.id)" $null $ch
Assert-Check ($paid.status -eq 'COMPLETED' -and $confirmed.status -eq 'CONFIRMED') 'Retry succeeds and confirms the booking'
$cancelled = Send-Json PUT "/bookings/$($booking.id)/cancel" $null $ch
$refunded = Send-Json GET "/payments/$($payment.id)" $null $ch
$seats = Send-Json GET "/shows/$($show.id)/seats" $null $ch
Assert-Check ($cancelled.status -eq 'CANCELLED' -and $refunded.status -eq 'REFUNDED') 'Cancellation issues a simulated refund'
Assert-Check ($seats.availableSeats -contains 'A1' -and $seats.availableSeats -contains 'A2') 'Cancellation releases both seats'
[pscustomobject]@{
    Result = 'PASS'; MovieId = $movie.id; TheatreId = $theatre.id; ShowId = $show.id
    BookingId = $booking.id; PaymentId = $payment.id; BookingStatus = $cancelled.status; PaymentStatus = $refunded.status
}
