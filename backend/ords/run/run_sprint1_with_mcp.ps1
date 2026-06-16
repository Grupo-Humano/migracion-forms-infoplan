# Sprint 1 - ORDS Mock Setup via SQLcl + MCP (Remy-coordinated execution)
# Usage: .\run_sprint1_with_mcp.ps1 -ConnectionName "HUMANO_DESA"
# Alternative: .\run_sprint1_with_mcp.ps1 -ConnectionString "user/password@host:port/service"

param(
  [Parameter(ParameterSetName = "ConnectionName")]
  [string]$ConnectionName = "HUMANO_DESA",
  
  [Parameter(ParameterSetName = "ConnectionString", Mandatory = $true)]
  [string]$ConnectionString
)

$ErrorActionPreference = 'Stop'

Write-Host "[Sprint1-MCP] Initializing ORDS mock setup via SQLcl..." -ForegroundColor Cyan
Write-Host "[Sprint1-MCP] Connection: $(if($ConnectionString) { 'Custom' } else { $ConnectionName })" -ForegroundColor Yellow

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlDir = Join-Path (Join-Path $scriptRoot "..") "sql"

# Validate SQL files exist
$sqlFiles = @(
  "$sqlDir\01_mock_schema.sql",
  "$sqlDir\02_pkg_rep_aprobarechazo_mock.sql",
  "$sqlDir\03_ords_rep_aprobarechazo_mock.sql",
  "$sqlDir\04_smoke_tests.sql"
)

foreach ($file in $sqlFiles) {
  if (-not (Test-Path $file)) {
    throw "[Sprint1-MCP] Missing SQL file: $file"
  }
  Write-Host "[Sprint1-MCP] Found: $(Split-Path $file -Leaf)" -ForegroundColor Green
}

# Generate connection command
if ($ConnectionString) {
  $connCmd = "CONNECT $ConnectionString"
} else {
  $connCmd = "CONNECT $ConnectionName"
}

# Create temp script with connection + mock setup
$tempScript = "$env:TEMP\sprint1_setup_$((Get-Date).Ticks).sql"

$sqlLines = @(
  "WHENEVER SQLERROR EXIT SQL.SQLCODE",
  $connCmd,
  "SHOW user",
  "SELECT 'Oracle Version:' label, banner FROM v`$version WHERE ROWNUM = 1;",
  "",
  "-- Mock schema",
  "SET ECHO ON",
  "@$sqlDir\01_mock_schema.sql",
  "SET ECHO OFF",
  "",
  "-- Package",
  "SET ECHO ON",
  "@$sqlDir\02_pkg_rep_aprobarechazo_mock.sql",
  "SET ECHO OFF",
  "",
  "-- ORDS publication",
  "SET ECHO ON",
  "@$sqlDir\03_ords_rep_aprobarechazo_mock.sql",
  "SET ECHO OFF",
  "",
  "-- Smoke tests",
  "SET ECHO ON",
  "@$sqlDir\04_smoke_tests.sql",
  "SET ECHO OFF",
  "",
  "-- Summary",
  "PROMPT",
  "PROMPT ===== Sprint 1 Setup Summary =====",
  "SELECT COUNT(*) mock_tables FROM user_tables WHERE table_name LIKE 'MOCK_%';",
  "SELECT COUNT(*) mock_pkg_objects FROM user_objects WHERE object_name = 'PKG_REP_APROBARECHAZO_MOCK' AND object_type IN ('PACKAGE', 'PACKAGE BODY');",
  "SELECT COUNT(*) ords_modules FROM user_ords_modules;",
  "SELECT COUNT(*) ords_handlers FROM user_ords_handlers;",
  "",
  "EXIT;"
)

($sqlLines -join "`r`n") | Out-File -FilePath $tempScript -Encoding ASCII

Write-Host ""
Write-Host "[Sprint1-MCP] Executing setup script via sqlcl..." -ForegroundColor Cyan

try {
  # Resolve SQL executable from .env when available.
  $sqlExe = "sqlcl"
  if (Test-Path ".env") {
    $envLine = Get-Content ".env" | Where-Object { $_ -match '^SQLCL_PATH=' } | Select-Object -First 1
    if ($envLine) {
      $parts = $envLine -split '=', 2
      if ($parts.Count -eq 2 -and $parts[1]) {
        $sqlExe = $parts[1].Trim()
      }
    }
  }

  # Execute via SQLcl/SQL with explicit connection to avoid interactive prompts.
  if ($ConnectionString) {
    & $sqlExe "$ConnectionString" "@$tempScript"
  } else {
    & $sqlExe "@$tempScript"
  }
  
  if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[Sprint1-MCP] Setup completed successfully." -ForegroundColor Green
    Write-Host "[Sprint1-MCP] Next steps:" -ForegroundColor Green
    Write-Host "  1. Validate ORDS endpoints: http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/transacciones/search" -ForegroundColor Gray
    Write-Host "  2. Run E2E tests: npm run test:e2e in frontend/" -ForegroundColor Gray
    Write-Host "  3. Merge to main after QA sign-off" -ForegroundColor Gray
  } else {
    throw "[Sprint1-MCP] sqlcl failed with exit code $LASTEXITCODE"
  }
}
catch {
  Write-Host "[Sprint1-MCP] Setup failed: $_" -ForegroundColor Red
  exit 1
}
finally {
  Remove-Item -Path $tempScript -ErrorAction SilentlyContinue
}
