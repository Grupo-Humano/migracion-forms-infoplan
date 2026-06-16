# Sprint 1 - ORDS Validation Script (Sage)
# Usage: .\run_ords_validation.ps1
# Requires: SQLcl in PATH with HUMANO_DESA connection (password saved in SQL Developer)

param(
  [switch]$QuietMode = $false
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
  Write-Host "$prefix $message" -ForegroundColor $(if($level -eq "ERROR") { "Red" } elseif($level -eq "SUCCESS") { "Green" } else { "Cyan" })
}

Write-SageLog "Iniciando validación de ORDS en HUMANO_DESA..."
Write-SageLog "Verificando SQLcl disponible..."

# Check SQLcl
try {
  $sqlclVersion = & sqlcl -version 2>&1 | Select-Object -First 1
  Write-SageLog "SQLcl found: $sqlclVersion" "SUCCESS"
} catch {
  Write-SageLog "SQLcl not found in PATH. Install Oracle Instant Client or add to PATH." "ERROR"
  exit 1
}

# Create validation SQL script
$tempSql = "$env:TEMP\ords_validation_$(Get-Random).sql"
$validationScript = @"
-- Sprint 1: ORDS Validation
-- Connection: HUMANO_DESA

CONNECT HUMANO_DESA

-- 1. Database version
SET HEADING ON FEEDBACK OFF PAGESIZE 0 LINESIZE 200

PROMPT ===== 1. Database Version =====
SELECT banner FROM v`$version WHERE ROWNUM = 1;

-- 2. ORDS installation status (if SYSDBA access)
PROMPT ===== 2. ORDS Installation Status (requires SYSDBA) =====
BEGIN
  FOR rec IN (SELECT comp_id, version, status FROM dba_registry WHERE comp_id = 'ORDS') LOOP
    DBMS_OUTPUT.PUT_LINE('ORDS: ' || rec.comp_id || ' | Version: ' || rec.version || ' | Status: ' || rec.status);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('(ORDS not accessible - normal if connected as non-SYSDBA)');
END;
/

-- 3. ORDS Modules
PROMPT ===== 3. ORDS Modules in User Schema =====
SELECT COUNT(*) module_count FROM user_ords_modules;
SELECT module_name, base_path FROM user_ords_modules ORDER BY 1;

-- 4. ORDS Handlers
PROMPT ===== 4. ORDS Handlers (Endpoints) =====
SELECT COUNT(*) handler_count FROM user_ords_handlers;
SELECT pattern, method, status FROM user_ords_handlers ORDER BY 1, 2;

-- 5. Mock Tables
PROMPT ===== 5. Mock Tables =====
SELECT COUNT(*) table_count FROM user_tables WHERE table_name LIKE 'MOCK_%';
SELECT table_name, num_rows FROM user_tables WHERE table_name LIKE 'MOCK_%' ORDER BY 1;

-- 6. Mock Packages
PROMPT ===== 6. Mock Packages =====
SELECT COUNT(*) package_count FROM user_procedures WHERE object_type = 'PACKAGE' AND object_name LIKE 'PKG_%';
SELECT object_name, status FROM user_procedures WHERE object_type = 'PACKAGE' AND object_name LIKE 'PKG_%' ORDER BY 1;

-- 7. Mock Package Bodies
PROMPT ===== 7. Package Bodies =====
SELECT COUNT(*) body_count FROM user_procedures WHERE object_type = 'PACKAGE BODY' AND object_name LIKE 'PKG_%';

PROMPT ===== Validation Complete =====
EXIT;
"@

$validationScript | Out-File -FilePath $tempSql -Encoding UTF8

Write-SageLog "Ejecutando validación SQL..."
Write-SageLog "Script: $tempSql"
Write-SageLog ""

try {
  & sqlcl @$tempSql
  $exitCode = $LASTEXITCODE
  
  Write-SageLog ""
  
  if ($exitCode -eq 0) {
    Write-SageLog "ORDS validation completed successfully!" "SUCCESS"
  } else {
    Write-SageLog "SQLcl returned exit code: $exitCode" "WARN"
    Write-SageLog "Check if:"
    Write-SageLog "  1. HUMANO_DESA password is saved in SQL Developer"
    Write-SageLog "  2. Database is running and accessible"
    Write-SageLog "  3. Network connectivity to database host is OK"
  }
}
catch {
  Write-SageLog "Error executing sqlcl: $_" "ERROR"
  exit 1
}
finally {
  Remove-Item -Path $tempSql -ErrorAction SilentlyContinue
}

Write-SageLog ""
Write-SageLog "If modules/handlers show 0 count, execute:"
Write-SageLog "  .\run_sprint1_with_mcp.ps1 -ConnectionName 'HUMANO_DESA'"
