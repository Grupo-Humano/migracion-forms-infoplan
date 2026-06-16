# Sprint 1 - Database Connect with .env Configuration
# Usage: .\backend\ords\run\connect_with_env.ps1
# 
# Prerequisites:
#   1. Copy .env.template to .env
#   2. Fill in your database credentials in .env
#   3. Save and run this script

param(
  [string]$EnvFile = ".\.env",
  [switch]$SkipValidation = $false
)

function Write-SageLog {
  param($message, $level = "INFO")
  $timestamp = Get-Date -Format "HH:mm:ss"
  $prefix = switch($level) {
    "INFO" { "[Sage]" }
    "WARN" { "[Sage-WARN]" }
    "ERROR" { "[Sage-ERROR]" }
    "SUCCESS" { "[Sage-SUCCESS]" }
    default { "[Sage]" }
  }
  $color = @{ "ERROR" = "Red"; "SUCCESS" = "Green"; "WARN" = "Yellow" }
  $fgColor = if ($color[$level]) { $color[$level] } else { "Cyan" }
  Write-Host "$prefix $message" -ForegroundColor $fgColor
}

# Load .env file
if (-not (Test-Path $EnvFile)) {
  Write-SageLog ".env file not found at: $EnvFile" "ERROR"
  Write-SageLog "Crear desde template: copy .env.template .env" "WARN"
  exit 1
}

Write-SageLog "Cargando configuración desde: $EnvFile"

$envVars = @{}
Get-Content $EnvFile | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
  $line = $_.Trim()
  if ($line -match "^([A-Z_]+)=(.*)$") {
    $envVars[$Matches[1]] = $Matches[2]
  }
}

# Validate required fields
$requiredFields = @("DB_USER", "DB_PASSWORD", "DB_HOST", "DB_PORT", "DB_SERVICE")
$missingFields = @()

foreach ($field in $requiredFields) {
  if (-not $envVars[$field]) {
    $missingFields += $field
  }
}

if ($missingFields) {
  Write-SageLog "Campos faltantes en .env: $($missingFields -join ', ')" "ERROR"
  Write-SageLog "Edita .env y completa todos los valores" "WARN"
  exit 1
}

if (-not $SkipValidation) {
  Write-SageLog "Configuración validada:" "SUCCESS"
  Write-SageLog "  Usuario: $($envVars['DB_USER'])"
  Write-SageLog "  Host: $($envVars['DB_HOST'])"
  Write-SageLog "  Puerto: $($envVars['DB_PORT'])"
  Write-SageLog "  Service: $($envVars['DB_SERVICE'])"
}

# Build connection string
$connString = "$($envVars['DB_USER'])/$($envVars['DB_PASSWORD'])@//$($envVars['DB_HOST']):$($envVars['DB_PORT'])/$($envVars['DB_SERVICE'])"

# Create temporary SQL script for validation
$tempSql = "$env:TEMP\ords_check_$(Get-Random).sql"

$sqlScript = @"
-- Sprint 1: Quick ORDS Status Check
SET HEADING ON FEEDBACK OFF PAGESIZE 0 LINESIZE 200

PROMPT ===== Connected =====
SHOW USER;

PROMPT ===== Database Version =====
SELECT banner FROM v`$version WHERE ROWNUM = 1;

PROMPT ===== Mock Tables Count =====
SELECT COUNT(*) as mock_tables FROM user_tables WHERE table_name LIKE 'MOCK_%';

PROMPT ===== ORDS Modules Count =====
SELECT COUNT(*) as ords_modules FROM user_ords_modules;

PROMPT ===== ORDS Handlers Count =====
SELECT COUNT(*) as ords_handlers FROM user_ords_handlers;

PROMPT ===== Done =====
EXIT;
"@

Write-SageLog ""
Write-SageLog "Conectando a ORDS en $($envVars['DB_SERVICE'])..."
Write-SageLog ""

# Execute SQLcl with credentials
try {
  # Use SQLcl with connection string
  $sqlclPath = if ($envVars['SQLCL_PATH']) { $envVars['SQLCL_PATH'] } else { "sqlcl" }
  
  # Persist only the validation statements; connection is passed as CLI argument.
  $sqlScript | Out-File -FilePath $tempSql -Encoding ASCII -Force
  
  Write-SageLog "Ejecutando validación..."
  & $sqlclPath "$connString" "@$tempSql"
  
  if ($LASTEXITCODE -eq 0) {
    Write-SageLog "" 
    Write-SageLog "Conexión exitosa! ORDS validado." "SUCCESS"
    Write-SageLog ""
    Write-SageLog "Próximos pasos:"
    Write-SageLog "  1. Si módulos/handlers = 0, ejecuta: .\run_sprint1_with_mcp.ps1"
    Write-SageLog "  2. Si módulos/handlers > 0, ORDS ya está configurado"
  } else {
    Write-SageLog "SQLcl error (code: $($LASTEXITCODE))" "ERROR"
  }
}
catch {
  Write-SageLog "Error: $_" "ERROR"
  exit 1
}
finally {
  Remove-Item -Path $tempSql -ErrorAction SilentlyContinue
}
