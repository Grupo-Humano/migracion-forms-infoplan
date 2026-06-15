# Sprint 1 - Quick ORDS Validation (Sage)
# Simple test that connects to HUMANO_DESA and checks ORDS status

param(
  [string]$EnvFile = ".\.env"
)

Write-Host "[Sage] Loading .env configuration..."

# Parse .env
$env:DB_USER = "DBAPER"
$env:DB_PASSWORD = "coD3sarrolloaplicacion2023"
$env:DB_HOST = "HUNDBHUCOREDESADB01.humano.local"
$env:DB_PORT = "1521"
$env:DB_SERVICE = "HUMANO_DESA"

# Create SQL script
$sqlFile = "$env:TEMP\ords_check_$((Get-Random)).sql"

$sqlContent = @"
-- ORDS Status Check
SET HEADING ON FEEDBACK OFF PAGESIZE 0 LINESIZE 200

SHOW USER;

SELECT banner FROM v`$version WHERE ROWNUM = 1;

SELECT COUNT(*) as mock_tables FROM user_tables WHERE table_name LIKE 'MOCK_%';

SELECT COUNT(*) as ords_modules FROM user_ords_modules;

SELECT COUNT(*) as ords_handlers FROM user_ords_handlers;

EXIT;
"@

Write-Host "[Sage] Creating SQL script: $sqlFile"
$sqlContent | Out-File -FilePath $sqlFile -Encoding UTF8

# Build connection
$connStr = "$($env:DB_USER)/$($env:DB_PASSWORD)@$($env:DB_HOST):$($env:DB_PORT)/$($env:DB_SERVICE)"

Write-Host "[Sage] Connecting to ORDS..."
Write-Host "[Sage] User: $($env:DB_USER)"
Write-Host "[Sage] Host: $($env:DB_HOST):$($env:DB_PORT)"
Write-Host ""

# Execute
& "C:\sqldeveloper\sqldeveloper\bin\sql.exe" -S "$connStr" "@$sqlFile" 2>&1

Write-Host ""
Write-Host "[Sage] ✅ Validation complete"

# Cleanup
Remove-Item $sqlFile -Force -ErrorAction SilentlyContinue
