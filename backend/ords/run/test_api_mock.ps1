param(
  [Parameter(Mandatory = $false)]
  [string]$BaseUrl = "http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos"
)

$ErrorActionPreference = 'Stop'

function Invoke-ApiJson {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Method,
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [Parameter(Mandatory = $false)]
    [object]$Body
  )

  if ($null -ne $Body) {
    $payload = $Body | ConvertTo-Json -Depth 10
    return Invoke-RestMethod -Method $Method -Uri $Url -ContentType "application/json" -Body $payload
  }

  return Invoke-RestMethod -Method $Method -Uri $Url
}

Write-Host "[API-TEST] Base URL: $BaseUrl" -ForegroundColor Cyan

try {
  Write-Host "[API-TEST] 1) GET /oficiales/101" -ForegroundColor Yellow
  $r1 = Invoke-ApiJson -Method GET -Url "$BaseUrl/oficiales/101"
  Write-Host "  -> OK" -ForegroundColor Green
  $r1 | ConvertTo-Json -Depth 5

  Write-Host "[API-TEST] 2) POST /transacciones/search (all filters null)" -ForegroundColor Yellow
  $r2 = Invoke-ApiJson -Method POST -Url "$BaseUrl/transacciones/search" -Body @{
    fec_ini = "2026-06-01"
    fec_fin = "2026-06-30"
    cliente = $null
    oficial = $null
    gerente = $null
    intermediario = $null
  }
  Write-Host "  -> OK" -ForegroundColor Green
  $r2 | ConvertTo-Json -Depth 7

  Write-Host "[API-TEST] 3) POST /transacciones/seleccion/M" -ForegroundColor Yellow
  $r3 = Invoke-ApiJson -Method POST -Url "$BaseUrl/transacciones/seleccion/M"
  Write-Host "  -> OK" -ForegroundColor Green
  $r3 | ConvertTo-Json -Depth 5

  Write-Host "[API-TEST] 4) POST /exportaciones/ole" -ForegroundColor Yellow
  $r4 = Invoke-ApiJson -Method POST -Url "$BaseUrl/exportaciones/ole"
  Write-Host "  -> OK" -ForegroundColor Green
  $r4 | ConvertTo-Json -Depth 5

  Write-Host "[API-TEST] 5) POST /transacciones/seleccion/D" -ForegroundColor Yellow
  $r5 = Invoke-ApiJson -Method POST -Url "$BaseUrl/transacciones/seleccion/D"
  Write-Host "  -> OK" -ForegroundColor Green
  $r5 | ConvertTo-Json -Depth 5

  Write-Host "[API-TEST] 6) POST /exportaciones/jasper" -ForegroundColor Yellow
  $r6 = Invoke-ApiJson -Method POST -Url "$BaseUrl/exportaciones/jasper" -Body @{
    fec_ini = "2026-06-01"
    fec_fin = "2026-06-30"
  }
  Write-Host "  -> OK" -ForegroundColor Green
  $r6 | ConvertTo-Json -Depth 5

  Write-Host "[API-TEST] Smoke API tests completed successfully." -ForegroundColor Green
}
catch {
  Write-Host "[API-TEST] Failed: $($_.Exception.Message)" -ForegroundColor Red
  throw
}
