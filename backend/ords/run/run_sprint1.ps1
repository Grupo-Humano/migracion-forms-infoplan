param(
  [Parameter(Mandatory = $true)]
  [string]$ConnectionString
)

$ErrorActionPreference = 'Stop'

Write-Host "[Sprint1] Running ORDS mock setup..." -ForegroundColor Cyan

$sqlFiles = @(
  "../sql/01_mock_schema.sql",
  "../sql/02_pkg_rep_aprobarechazo_mock.sql",
  "../sql/03_ords_rep_aprobarechazo_mock.sql",
  "../sql/04_smoke_tests.sql"
)

Push-Location $PSScriptRoot
try {
  foreach ($sqlFile in $sqlFiles) {
    $resolved = Resolve-Path $sqlFile
    Write-Host "[Sprint1] Executing $resolved" -ForegroundColor Yellow
    sqlplus -L $ConnectionString "@$resolved"
    if ($LASTEXITCODE -ne 0) {
      throw "sqlplus failed for $resolved with code $LASTEXITCODE"
    }
  }

  Write-Host "[Sprint1] Completed successfully." -ForegroundColor Green
  Write-Host "[Sprint1] Next: execute requests in backend/ords/tests/rep_aprobarechazo_mock.http" -ForegroundColor Green
}
finally {
  Pop-Location
}
