# Sprint 1 - SQLcl Installation Helper
# Descarga e instala SQLcl desde Oracle
# Usage: .\backend\ords\run\install_sqlcl.ps1

param(
  [string]$InstallPath = "C:\sqlcl",
  [switch]$SkipDownload = $false
)

function Write-SageLog {
  param($message, $level = "INFO")
  $prefix = switch($level) {
    "INFO" { "[Sage]" }
    "WARN" { "[Sage-WARN]" }
    "ERROR" { "[Sage-ERROR]" }
    "SUCCESS" { "[Sage-SUCCESS]" }
    default { "[Sage]" }
  }
  $fgColor = if ($level -eq "ERROR") { "Red" } elseif ($level -eq "SUCCESS") { "Green" } elseif ($level -eq "WARN") { "Yellow" } else { "Cyan" }
  Write-Host "$prefix $message" -ForegroundColor $fgColor
}

Write-SageLog "SQLcl Installation Helper"
Write-SageLog ""

# Check if directory exists
if (Test-Path $InstallPath) {
  Write-SageLog "Directorio $InstallPath ya existe" "WARN"
  if (Test-Path "$InstallPath\bin\sqlcl.exe") {
    Write-SageLog "sqlcl.exe encontrado! Ya está instalado." "SUCCESS"
    $sqlclExe = "$InstallPath\bin\sqlcl.exe"
    Write-SageLog "Ruta: $sqlclExe"
    Write-SageLog ""
    Write-SageLog "Actualiza .env con:"
    Write-SageLog "  SQLCL_PATH=$sqlclExe"
    exit 0
  }
}

Write-SageLog "Instalando SQLcl..."
Write-SageLog ""
Write-SageLog "Opción 1 - Descarga manual (RECOMENDADO):" "WARN"
Write-SageLog "  1. Ve a: https://www.oracle.com/tools/downloads/sqlcl-downloads.html"
Write-SageLog "  2. Descarga: sqlcl-latest.zip"
Write-SageLog "  3. Extrae a: $InstallPath"
Write-SageLog "  4. Ejecuta: .\backend\ords\run\install_sqlcl.ps1 -SkipDownload"
Write-SageLog ""
Write-SageLog "Opción 2 - Instalación automática con wget:"
Write-SageLog ""

# Check if wget is available
$wgetAvailable = $false
try {
  $null = & wget --version 2>&1
  $wgetAvailable = $true
} catch {
  Write-SageLog "wget no disponible - continuando con descarga manual" "WARN"
}

if ($wgetAvailable) {
  Write-SageLog "Descargando SQLcl..." "INFO"
  
  # Create temp directory
  $tempDir = "$env:TEMP\sqlcl_download"
  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  
  $downloadUrl = "https://download.oracle.com/otn_software/java/sqlcl/sqlcl-latest.zip"
  $zipFile = "$tempDir\sqlcl-latest.zip"
  
  Write-SageLog "URL: $downloadUrl"
  Write-SageLog "Destino: $zipFile"
  
  # Download
  & wget --quiet "$downloadUrl" -O "$zipFile"
  
  if (Test-Path $zipFile) {
    Write-SageLog "Descarga exitosa!" "SUCCESS"
    Write-SageLog "Extrayendo..."
    
    # Extract
    Expand-Archive -Path $zipFile -DestinationPath $InstallPath -Force
    
    Write-SageLog "Instalación completada!" "SUCCESS"
    Write-SageLog "Ruta: $InstallPath"
    
    # Cleanup
    Remove-Item -Path $tempDir -Recurse -Force
    
    # Update .env
    $envFile = ".env"
    if (Test-Path $envFile) {
      $envContent = Get-Content $envFile -Raw
      $envContent = $envContent -replace 'SQLCL_PATH=.*', "SQLCL_PATH=$InstallPath\bin\sqlcl.exe"
      $envContent | Out-File -FilePath $envFile -Encoding UTF8
      Write-SageLog "Actualizado .env con ruta de SQLcl" "SUCCESS"
    }
    
    exit 0
  } else {
    Write-SageLog "Descarga falló" "ERROR"
    exit 1
  }
}

Write-SageLog "INSTRUCCIONES MANUALES:" "WARN"
Write-SageLog ""
Write-SageLog "1. Abre navegador y ve a:"
Write-SageLog "   https://www.oracle.com/tools/downloads/sqlcl-downloads.html"
Write-SageLog ""
Write-SageLog "2. Descarga: sqlcl-latest.zip"
Write-SageLog ""
Write-SageLog "3. Extrae el archivo a:"
Write-SageLog "   $InstallPath"
Write-SageLog ""
Write-SageLog "4. Verifica que exista:"
Write-SageLog "   $InstallPath\bin\sqlcl.exe"
Write-SageLog ""
Write-SageLog "5. Edita .env y actualiza:"
Write-SageLog "   SQLCL_PATH=$InstallPath\bin\sqlcl.exe"
Write-SageLog ""
Write-SageLog "6. Ejecuta de nuevo:"
Write-SageLog "   .\backend\ords\run\connect_with_env.ps1"
