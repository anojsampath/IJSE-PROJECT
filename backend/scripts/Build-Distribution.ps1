$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (Test-Path (Join-Path $root '.local\credentials.clixml')) {
    . (Join-Path $PSScriptRoot 'Use-LocalEnvironment.ps1')
}
foreach ($name in @('DB_TEST_URL', 'DB_TEST_USERNAME', 'DB_TEST_PASSWORD')) {
    if (-not [Environment]::GetEnvironmentVariable($name)) {
        throw "$name is missing. Start local MySQL and load its environment, or configure an isolated MySQL test database as described in README.md."
    }
}
$env:MAVEN_USER_HOME = Join-Path $root '.mvn'
$buildStarted = [DateTime]::UtcNow.AddSeconds(-2)
Push-Location $root
try {
    & (Join-Path $root 'mvnw.cmd') -B -ntp "-Dmaven.repo.local=$root\.mvn\repository" spotless:check verify -Pintegration
    if ($LASTEXITCODE -ne 0) { throw 'Verification failed. No distribution ZIP was created.' }
} finally { Pop-Location }

function Get-TestSummary([string]$directory) {
    $reports = @(Get-ChildItem -LiteralPath $directory -Filter 'TEST-*.xml' -File)
    if ($reports.Count -eq 0) { throw "No test reports found in $directory" }
    $totals = [ordered]@{ tests = 0; failures = 0; errors = 0; skipped = 0 }
    foreach ($report in $reports) {
        if ($report.LastWriteTimeUtc -lt $buildStarted) { throw "Stale test report: $($report.Name). Reconcile obsolete reports before packaging." }
        [xml]$xml = Get-Content -LiteralPath $report.FullName -Raw
        foreach ($key in @('tests', 'failures', 'errors', 'skipped')) {
            $totals[$key] += [int]$xml.testsuite.GetAttribute($key)
        }
    }
    if ($totals.tests -lt 1 -or $totals.failures -ne 0 -or $totals.errors -ne 0 -or $totals.skipped -ne 0) {
        throw 'All test suites must execute without failures, errors, or skipped tests before packaging.'
    }
    [pscustomobject]$totals
}
$localTests = Get-TestSummary (Join-Path $root 'target\surefire-reports')
$mysqlTests = Get-TestSummary (Join-Path $root 'target\failsafe-reports')

# Construct the archive from approved inputs, never from a recursive workspace ZIP.
$files = [ordered]@{}
$fixedFiles = @(
    '.gitignore', 'pom.xml', 'mvnw', 'mvnw.cmd', '.mvn/wrapper/maven-wrapper.properties',
    'README.md', 'USER_GUIDE.html', 'scripts/Initialize-LocalMySql.ps1',
    'scripts/Start-LocalMySql.ps1', 'scripts/Use-LocalEnvironment.ps1',
    'scripts/Start-LocalApp.ps1', 'scripts/Test-LocalApi.ps1', 'scripts/Build-Distribution.ps1'
)
foreach ($relative in $fixedFiles) { $files[$relative] = Join-Path $root $relative }
$sourceRoot = Join-Path $root 'src'
foreach ($item in Get-ChildItem -LiteralPath $sourceRoot -Recurse -Force) {
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked source path is not allowed: $($item.Name)" }
    if ($item.PSIsContainer) { continue }
    $relative = $item.FullName.Substring($root.Length + 1).Replace('\', '/')
    if ($relative -notmatch '^src/(main|test)/(java/.+\.java|resources/(application(?:-test|-mysqltest)?\.yml|db/migration/V[0-9_]+__[^/]+\.sql))$') {
        throw "Unapproved source input: $relative. Update the explicit allowlist after checking that it is safe to distribute."
    }
    $files[$relative] = $item.FullName
}
$files['app/movie-booking.jar'] = Join-Path $root 'target\movie-booking-0.0.1-SNAPSHOT.jar'
$hashes = [ordered]@{}
foreach ($relative in $files.Keys) {
    $path = $files[$relative]
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required package input missing: $relative" }
    $item = Get-Item -LiteralPath $path -Force
    while ($null -ne $item -and $item.FullName -ne $root) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked package input is not allowed: $relative" }
        if ($item -is [IO.FileInfo]) { $item = $item.Directory } else { $item = $item.Parent }
    }
    $hashes[$relative] = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}
$manifest = [ordered]@{
    application = 'Movie Ticket Booking Backend'; version = '0.0.1-SNAPSHOT'
    builtAtUtc = [DateTime]::UtcNow.ToString('o'); java = '21'; database = 'MySQL 8+'
    verification = [ordered]@{ localTests = $localTests; mysqlTests = $mysqlTests; formatting = 'passed' }
    excluded = @('credentials', 'database files', 'logs', 'Git metadata', 'dependency caches', 'test-report XML')
    files = $hashes
} | ConvertTo-Json -Depth 6

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$zipPath = Join-Path $dist ("movie-booking-0.0.1-SNAPSHOT-{0}.zip" -f (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
$zipStream = [IO.File]::Open($zipPath, [IO.FileMode]::CreateNew)
try {
    $archive = [IO.Compression.ZipArchive]::new($zipStream, [IO.Compression.ZipArchiveMode]::Create, $true)
    try {
        foreach ($relative in $files.Keys) {
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $archive, $files[$relative], "movie-booking/$relative", [IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
        $entry = $archive.CreateEntry('movie-booking/DISTRIBUTION-MANIFEST.json')
        $writer = [IO.StreamWriter]::new($entry.Open(), [Text.UTF8Encoding]::new($false))
        try { $writer.Write($manifest) } finally { $writer.Dispose() }
    } finally { $archive.Dispose() }
} finally { $zipStream.Dispose() }

# Reopen and verify the exact entry set and every payload hash before reporting success.
$archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    if ($archive.Entries.Count -ne $files.Count + 1) { throw 'ZIP entry count mismatch. Do not distribute this archive.' }
    $seen = @{}
    foreach ($entry in $archive.Entries) {
        if (-not $entry.FullName.StartsWith('movie-booking/')) { throw 'ZIP contains an unexpected root.' }
        $relative = $entry.FullName.Substring('movie-booking/'.Length)
        if ($seen.ContainsKey($relative)) { throw 'ZIP contains duplicate entries.' }
        $seen[$relative] = $true
        if ($relative -eq 'DISTRIBUTION-MANIFEST.json') { continue }
        if (-not $files.Contains($relative)) { throw "ZIP contains unapproved entry: $relative" }
        $stream = $entry.Open()
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $actual = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-', '').ToLowerInvariant() }
        finally { $sha.Dispose(); $stream.Dispose() }
        if ($actual -ne $hashes[$relative]) { throw "ZIP payload hash mismatch: $relative" }
    }
    $reader = [IO.StreamReader]::new($archive.GetEntry('movie-booking/DISTRIBUTION-MANIFEST.json').Open())
    try { if ($reader.ReadToEnd() -ne $manifest) { throw 'ZIP manifest mismatch.' } } finally { $reader.Dispose() }
} finally { $archive.Dispose() }
$zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
"$zipHash  $([IO.Path]::GetFileName($zipPath))" | Set-Content -LiteralPath "$zipPath.sha256" -Encoding ASCII
Write-Host "PASS: $($localTests.tests) local tests and $($mysqlTests.tests) MySQL tests; formatting passed."
Write-Host "PASS: $($files.Count + 1) ZIP entries verified; private local data excluded."
[pscustomobject]@{ Zip = $zipPath; Checksum = "$zipPath.sha256"; SHA256 = $zipHash; SizeMB = [math]::Round((Get-Item $zipPath).Length / 1MB, 2) }
