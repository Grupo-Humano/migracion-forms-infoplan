@REM Sprint 1 - ORDS Validation Script (Sage)
@REM Usage: run_ords_validation.bat
@REM Requires: SQLcl in PATH, HUMANO_DESA connection with saved password

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO.
ECHO [Sage-ORDS-Validation] Iniciando validacion de ORDS...
ECHO.

REM Crear script SQL temporal
SET TEMP_SQL=%TEMP%\ords_validation_%RANDOM%.sql

(
  ECHO -- Sprint 1: ORDS Validation Script
  ECHO -- Connected to: HUMANO_DESA
  ECHO.
  ECHO CONNECT HUMANO_DESA
  ECHO.
  ECHO PROMPT ===== Database Version =====
  ECHO SELECT banner FROM v$version WHERE ROWNUM = 1;
  ECHO.
  ECHO PROMPT ===== ORDS Installation Status =====
  ECHO SELECT comp_id, version, status FROM dba_registry WHERE comp_id = 'ORDS';
  ECHO.
  ECHO PROMPT ===== ORDS Modules (Schema Context) =====
  ECHO SELECT module_name, base_path, status FROM user_ords_modules;
  ECHO.
  ECHO PROMPT ===== ORDS Handlers (Endpoints) =====
  ECHO SELECT pattern, method, status FROM user_ords_handlers;
  ECHO.
  ECHO PROMPT ===== Mock Tables =====
  ECHO SELECT table_name FROM user_tables WHERE table_name LIKE 'MOCK_%%' ORDER BY 1;
  ECHO.
  ECHO PROMPT ===== Mock Packages =====
  ECHO SELECT object_name FROM user_procedures WHERE object_type = 'PACKAGE' AND object_name LIKE 'PKG_%%' ORDER BY 1;
  ECHO.
  ECHO PROMPT ===== Validation Complete =====
  ECHO EXIT;
) > "%TEMP_SQL%"

ECHO [Sage-ORDS-Validation] Ejecutando validation script via SQLcl...
ECHO.

sqlcl @"%TEMP_SQL%"

IF %ERRORLEVEL% EQU 0 (
  ECHO.
  ECHO [Sage-ORDS-Validation] SUCCESS - ORDS validation completed
) ELSE (
  ECHO.
  ECHO [Sage-ORDS-Validation] ERROR - SQLcl returned exit code %ERRORLEVEL%
  ECHO [Sage-ORDS-Validation] Verify:
  ECHO   1. SQLcl is in PATH: sqlcl -version
  ECHO   2. HUMANO_DESA password is saved in SQL Developer
  ECHO   3. Database is accessible: ping ^<hostname^>
)

REM Cleanup
DEL /Q "%TEMP_SQL%" >NUL 2>&1

PAUSE
