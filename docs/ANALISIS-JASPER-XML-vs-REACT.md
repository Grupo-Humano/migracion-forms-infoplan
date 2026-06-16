# Análisis: Diferencia de lógica en URL Jasper (XML Forms vs React)

## Problema Identificado

El reporte Jasper genera reportes vacíos en React a pesar de que:
1. La URL está bien formada
2. Los parámetros obligatorios (fechas) son correctos
3. El endpoint Jasper responde con HTTP 200

## Root Cause: Parámetros Opcionales

En el Forms original (`P_JASPER_A_EXCEL`), los parámetros opcionales se construían así:

```sql
V_SERVICIO:= '"'||V_RUT_SER
    ||'&name=rep_aprobaciones_rechazos&documentType=XLS'
    ||'&PCODIGO_COMPANIA='    ||:GLOBAL.COD_COMPANIA
    ||'&PDESDE='    ||V_DESDE
    ||'&PHAS='    ||V_HASTA
    ||'&POFICIAL='    ||:CONSULTA.OFICIAL      -- Estos son NUMBER
    ||'&PGERENTE='    ||:CONSULTA.GERENTE      -- Si son NULL...
    ||'&PINTERMEDIARIO='    ||:CONSULTA.INTERMEDIARIO  -- ...no aparecen en URL
```

**Comportamiento Oracle PL/SQL:**
- Si `:CONSULTA.OFICIAL` es NULL, la concatenación `||'&POFICIAL='||NULL` resulta en NULL
- El parámetro simplemente NO aparece en la URL final
- Jasper recibe: `?...&PHAS=01-JUN-2026` (sin POFICIAL, PGERENTE, PINTERMEDIARIO)

**En React (antes):**
```javascript
searchParams.set("POFICIAL", toLegacyJasperFilter(filters.oficial));
// toLegacyJasperFilter("") retorna "0"
// URL resultante: ?...&POFICIAL=0&PGERENTE=0&PINTERMEDIARIO=0
```

## La Diferencia Crítica

| Aspecto | Forms Original | React (antes) | Significado |
|---------|----------------|---------------|-------------|
| Parámetro ausente | `POFICIAL` no en URL | `POFICIAL=0` en URL | Forms = "sin filtro", React = "oficial con ID 0" |
| Jasper interpreta | Traer todos los oficiales | Traer solo oficial ID 0 | El oficial 0 no existe → reporte vacío |
| Datos retornados | Múltiples registros (si existen) | Cero registros | Por eso el reporte está vacío |

## Solución Implementada

**Cambio en `buildXmlJasperUrl` (ordsClient.ts):**

```javascript
// ANTES (INCORRECTO):
searchParams.set("POFICIAL", toLegacyJasperFilter(filters.oficial));
// Resultado: ?...&POFICIAL=0

// DESPUÉS (CORRECTO):
const oficial = filters.oficial?.trim();
if (oficial) {
  searchParams.set("POFICIAL", oficial);
}
// Si vacío: no se agrega el parámetro
// Si tiene valor: se agrega con ese valor
```

**Comportamiento ahora:**
- Si usuario NO selecciona oficial: no se envía `POFICIAL` en la URL (como Forms original)
- Si usuario SÍ selecciona oficial: se envía `POFICIAL=123` con el valor correcto
- Jasper interpreta la ausencia como "sin filtro" y retorna todos los registros

## Por qué esto es equivalente a Forms

En Forms original:
1. Usuario no selecciona oficial → campo NULL
2. Concatenación: `||'&POFICIAL='||NULL` → NULL
3. Parámetro no aparece en URL

En React ahora:
1. Usuario no selecciona oficial → campo ""
2. Validación: if (oficial) → false
3. Parámetro no se agrega a URL

**Resultado: URL idéntica en ambos casos**

## Parámetros Afectados

Esta lógica se aplica a:
- `POFICIAL` (Ejecutivo de Cobros)
- `PGERENTE` (Gerente de Negocio)  
- `PINTERMEDIARIO` (Intermediario)

Estos son campos opcionales que permiten filtrar el reporte.

## Validación de Fechas

Las fechas SÍ se convierten (formato requerido por Jasper):
- Entrada React: `"2026-06-01"` (YYYY-MM-DD)
- Conversión: `toJasperDate()` → `"01-JUN-2026"` (dd-MON-yyyy)
- Este formato es correcto según Forms original

## Próximos Pasos para Verificación

1. ✅ Código compilado sin errores
2. [ ] Probar con usuario que NO selecciona filtros opcionales
3. [ ] Verificar que reporte contiene datos ahora
4. [ ] Probar con filtros opcionales seleccionados
5. [ ] Comparar cantidad de registros vs Forms original
