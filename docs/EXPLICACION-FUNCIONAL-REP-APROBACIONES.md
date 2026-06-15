# EXPLICACIÓN FUNCIONAL
## Módulo: Reporte de Aprobaciones y Rechazos de Pólizas

**Documento:** Explicación Funcional para Business Analyst  
**Fuente:** Video de usuario + Análisis de forma XML  
**Fecha:** 2026-06-12  
**Forma Legacy:** `rep_aprobarechazo_fmb`

---

## 1. RESUMEN EJECUTIVO

El módulo de **"Consulta de Aprobación y Rechazo"** es parte del sistema de **Finanzas/Cobros** de InfoPlan. Permite a los usuarios autorizado consultar y generar reportes detallados sobre pólizas/tarjetas que fueron **aprobadas o rechazadas** en un rango de fechas, con filtros opcionales por cliente, ejecutivo (oficial) e intermediario.

**Propósito:** Análisis y auditoría de transacciones de pólizas para toma de decisiones comerciales y operacionales.

---

## 2. ACTORES (USUARIOS)

| Actor | Rol | Responsabilidades |
|-------|-----|-------------------|
| **Ejecutivo de Cobros** | Operacional | Consulta aprobaciones/rechazos de sus clientes |
| **Gerente de Negocio** | Supervisión | Audita desempeño por intermediario, ejecutivo |
| **Analista Finanzas** | Análisis | Genera reportes para auditoría, toma de decisiones |
| **Administrador Sistema** | TI | Mantiene datos, valida integridad |

**Acceso:** Usuario debe estar autorizado en el módulo de Cobros/Finanzas.

---

## 3. FLUJO DEL PROCESO (WORKFLOW)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USUARIO ACCEDE AL FORMULARIO                             │
│    Pantalla: "Consulta de Aprobación y Rechazo"             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. USUARIO COMPLETA FILTROS (BLOQUE: CONSULTA)             │
│                                                              │
│    Entrada Obligatoria:                                      │
│    - Fecha Inicio (FEC_INI)                                 │
│    - Fecha Fin (FEC_FIN)                                    │
│                                                              │
│    Entrada Opcional:                                         │
│    - Código Cliente (opcional = todos)                      │
│    - Código Oficial/Ejecutivo (opcional = todos)            │
│    - Código Gerente (opcional = todos)                      │
│    - Código Intermediario (opcional = todos)                │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. VALIDACIÓN DE FILTROS                                    │
│                                                              │
│    Reglas:                                                   │
│    ✓ FEC_INI y FEC_FIN obligatorios                         │
│    ✓ FEC_INI <= FEC_FIN (error si invierte)                 │
│    ✓ Si ambas vacías AND sin otros filtros → error          │
│    ✓ Al menos UN criterio debe estar completo              │
└──────────────────────────────┬──────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
              VÁLIDO│                 INVÁLIDO
                    │                     │
                    ▼                     ▼
            ┌──────────────┐      ┌──────────────┐
            │ 4A. EJECUTAR │      │ 4B. MOSTRAR  │
            │   BÚSQUEDA   │      │ MENSAJE ERROR│
            └──────┬───────┘      └──────────────┘
                   │
        ┌──────────┴──────────┐
        │ Confirmar acción    │
        │ "¿Seguro procesar?" │
        └──────────┬──────────┘
           Sí (continua) / No (cancela)
                   │
        ┌──────────┴─────────────────────┐
        │                                │
     "SÍ"│                           "NO"│
        │                                │
        ▼                                ▼
   ┌─────────────┐            ┌──────────────────┐
   │ 5. EJECUTAR │            │ Proceso cancelado│
   │   CONSULTA  │            │ (Sin cambios)    │
   │             │            └──────────────────┘
   │ Llamar SP:  │
   │ BUSCA_      │
   │ TRANSACCIONES│
   └─────┬───────┘
         │
         ▼
   ┌──────────────────────────────┐
   │ 6. CARGAR RESULTADOS         │
   │    (Bloque: TRANS)           │
   │                              │
   │    - Fecha Transacción       │
   │    - Cliente                 │
   │    - Monto                   │
   │    - Estado (Aprobado/Rech.) │
   │    - Respuesta Banco         │
   │    - 18 columnas más...      │
   │    (Total: 22 columnas)      │
   │                              │
   │    Display: 16 filas visible │
   │    Scroll: si > 16 registros │
   └─────┬───────────────────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
┌─────────┐ ┌──────────────┐
│7A.MARCAR│ │7B. EXPORTAR  │
│DESMARCAR│ │A EXCEL       │
└────┬────┘ └──────┬───────┘
     │             │
     │      ┌──────┴───────────┐
     │      │                  │
     │      ▼                  ▼
     │  ┌─────────────────┐ ┌──────────────────┐
     │  │ Opción 1: OLE   │ │ Opción 2: Jasper │
     │  │ (GENERA_REPORTE)│ │(P_JASPER_A_EXCEL)│
     │  └────────┬────────┘ └─────────┬────────┘
     │           │                    │
     │           ▼                    ▼
     │    ┌────────────────────────────────┐
     │    │ 8. GENERAR ARCHIVO EXCEL       │
     │    │    - Descargar en PC usuario   │
     │    │    - 22 columnas (todas)       │
     │    └───────┬────────────────────────┘
     │            │
     └────┬───────┘
          │
          ▼
   ┌─────────────────────┐
   │ 9. USUARIO LIMPIA   │
   │    EXCEL MANUAL     │
   │    (OFFLINE)        │
   │                     │
   │ - Elimina columnas  │
   │   innecesarias      │
   │ - Mantiene: Póliza, │
   │   Monto, Rechazo,   │
   │   Cliente, Afiliado │
   │                     │
   │ - Guarda versión    │
   │   limpia (.xlsx)    │
   └─────────────────────┘
```

---

## 4. DATOS DE ENTRADA (FILTROS)

### **Bloque: CONSULTA**

| Campo | Tipo | Rango | Obligatorio | Validación | Valor Defecto |
|-------|------|-------|-------------|-----------|---------------|
| **FEC_INI** | Date | 01/01/2000 a Hoy | **SÍ*** | > FEC_FIN → Error | Vacío |
| **FEC_FIN** | Date | 01/01/2000 a Hoy | **SÍ*** | < FEC_INI → Error | Vacío |
| **OFICIAL** | Number | LOV (0-999) | NO | Must exist en tabla MOFICIAL | Vacío (todos) |
| **GERENTE** | Number | LOV (0-999) | NO | Must exist en INT_GER_DIR01_V | Vacío (todos) |
| **INTERMEDIARIO** | Number | LOV (0-999) | NO | Must exist en INT_GER_DIR01_V | Vacío (todos) |
| **CLIENTE** | Number | LOV (1-999999) | NO | Must exist en tabla CLIENTE | Vacío (todos) |

**\* Obligatorio:** Al menos estos dos campos deben estar completos para ejecutar búsqueda.

### **Validaciones Implementadas**

```plsql
-- FEC_INI validation trigger
IF :consulta.fec_ini > :consulta.fec_fin THEN
  ERROR: "Fecha Desde no puede ser mayor que Fecha Hasta"
  RAISE FORM_TRIGGER_FAILURE
END IF;

-- FEC_FIN validation trigger  
IF :consulta.fec_fin < :consulta.fec_ini THEN
  ERROR: "Fecha Hasta no puede ser menor que Fecha Desde"
  RAISE FORM_TRIGGER_FAILURE
END IF;

-- B_BUSCAR trigger (CUANDO-BUTTON-PRESSED)
IF :consulta.fec_ini IS NULL OR :consulta.fec_fin IS NULL THEN
  ERROR: "Fechas requeridas"
  RAISE FORM_TRIGGER_FAILURE
END IF;

IF ALL campos vacíos THEN
  ERROR: "Debe especificarse algún criterio de búsqueda"
  RAISE FORM_TRIGGER_FAILURE
END IF;
```

---

## 5. DATOS DE SALIDA (RESULTADOS)

### **Bloque: TRANS (Results Table)**

**Display:** 16 rows visible, scrollable si hay más resultados

| Columna | Tipo | Ancho | Formato | Descripción |
|---------|------|-------|---------|-------------|
| **Fec. Trans.** | Date | 62px | dd/mm/yyyy | Fecha de transacción |
| **Cliente** | Number | 54px | 11 dígitos | Código de cliente |
| **Cia** | Number | 26px | 4 dígitos | Compañía (empresa) |
| **Ramo** | Number | 27px | 4 dígitos | Ramo de seguros |
| **Secuencial** | Number | 60px | 9 dígitos | Número secuencial póliza |
| **Monto** | Number | 76px | 99,999,990.90 | Monto de la póliza |
| **Estado** | Char | 24px | APROBADO/RECHAZADO | Status transacción |
| **Respuesta Banco** | Char | 218px | Texto 100 char | Descripción banco |
| **Número Tarjeta** | Char | 129px | Masked | Último 4 dígitos |
| **Fecha Vence** | Char | 72px | MM/YY | Vigencia tarjeta |
| **Cliente Póliza** | Char | 190px | Texto 100 char | Nombre cliente |
| **Intermediario** | Number | 58px | 10 dígitos | Código intermediario |
| **Nombre Intermediario** | Char | 167px | Texto 100 char | Nombre intermediario |
| **Gerente Negocio** | Char | 167px | Texto 100 char | Gerente asignado |
| **Dirección Negocio** | Char | 167px | Texto 100 char | Director asignado |
| **Frecuencia Pago** | Char | 102px | Texto 50 char | Mensuales, Anuales, etc. |
| **Fecha Tokeniza** | DateTime | 120px | dd-Mon-yyyy hh:mi:ss | Fecha de tokenización |
| **Ejecutivo Cobro** | Char | 119px | Texto 100 char | Oficial de cobros |
| **Grupo** | Char | 148px | Texto 100 char | Grupo cliente |
| **Selección** | Checkbox | 10px | S/N | Para multi-select |
| **Tipo Rechazo** | Char | 26px | Texto 20 char | Código tipo rechazo |
| Plus 2 más (audit fields) | | | | USER_CREA, FECHA_CREA, etc. |

**Total: 22+ columnas**

---

## 6. REGLAS DE NEGOCIO

### **R01: Filtración por Rango de Fechas**

```
Premisa: Usuario desea ver transacciones entre 01/11/2026 y 12/11/2026
Resultado: Sistema retorna TODAS las transacciones en ese rango
Condición: Ambas fechas obligatorias. Menor debe ser FEC_INI.
```

### **R02: Filtración por Cliente**

```
Si CLIENTE código está completo:
  → Filtrar resultados por ese cliente solamente
Else:
  → Retornar TODOS los clientes en el rango
```

### **R03: Filtración por Ejecutivo (Oficial)**

```
Si OFICIAL código está completo:
  → Filtrar transacciones de ese ejecutivo
Else:
  → Retornar TODOS los ejecutivos
  
NOTA: Base de datos es "ampliada" (muchos registros)
      Por eso permite dejar en blanco (retorna todos)
```

### **R04: Filtración por Intermediario**

```
Si INTERMEDIARIO código está completo:
  → Filtrar solo transacciones de ese intermediario
Else:
  → Retornar TODOS los intermediarios
  
NOTA: Puede coexistir con OFICIAL (AND logic)
```

### **R05: Filtración por Gerente**

```
Si GERENTE código está completo:
  → Filtrar por gerente de negocio
Else:
  → Sin filtro por gerente
```

### **R06: Estados de Transacción**

```
Valores posibles en campo "Estado":
  - APROBADA / APPROVED: Póliza aprobada sin problemas
  - RECHAZADA / DECLINED: Póliza rechazada por:
    ✗ Banco rechazó (llamada bank decline)
    ✗ Sin fondos en cuenta
    ✗ Otros motivos (ver "Respuesta Banco")
```

### **R07: Filtro "Ninguno" Retorna Todos**

```
Si usuario:
  - NO ingresa cliente
  - NO ingresa oficial
  - NO ingresa gerente  
  - NO ingresa intermediario
  
Resultado: Búsqueda retorna registros de TODO EL SISTEMA
           en el rango de fechas especificado.
           
NOTA: Puede retornar 10,000+ registros en un mes
      → Performance concern para React migration
```

### **R08: Marcar/Desmarcar Registros**

```
Propósito (del transcript): Seleccionar qué filas exportar
Implementación: Checkbox en cada fila (columna: SELECCION)
Comportamiento: 
  - Botón MARCAR → Marcar todas las filas S/N = 'S'
  - Botón DESMARCAR → Marcar todas S/N = 'N'
  - Usuario puede marcar manualmente cada fila
  
NOTA: Actualmente en Forms, pero NO está clara la lógica
      (¿exporta solo marcadas o todas?)
      Clarificar en Sprint 0
```

---

## 7. EXPORTACIÓN A EXCEL

### **Problema Actual (Known Issue)**

```
El transcript menciona: "En estos momentos tenemos un pequeño inconveniente 
que no lo está exportando"

Status: BROKEN ❌
Last working: Versión anterior del sistema
Current: No genera Excel correctamente
```

### **Opción 1: GENERA_REPORTE (OLE - Windows specific)**

```
Trigger: B_REPORTE button (WHEN-BUTTON-PRESSED)
Process:
  1. Verifica que user haya seleccionado al menos 1 fila
  2. Confirma: "¿Seguro de generar reporte?"
  3. Llamar: GENERA_REPORTE() stored procedure
  4. Output: Archivo Excel descargado al PC
  
File format: Excel 2003/2007
Columns: 22 (TODAS las del resultado)
```

**Pseudocódigo Trigger:**
```plsql
IF NOT registro_seleccionado('trans') THEN
  ERROR: "Debe hacer una selección para poder generar el reporte"
  RAISE FORM_TRIGGER_FAILURE
END IF;

al_id := Find_Alert('ALERTA_SI_NO');
Set_Alert_Property(al_id, alert_message_text, 'Seguro de generar reporte?');
v_eleccion := Show_Alert(al_id);

IF v_eleccion = ALERT_BUTTON1 THEN  -- User clicked SÍ
  set_application_property(cursor_style, 'busy');
  genera_reporte();  -- ← TRUNCATED PROCEDURE (must reverse-engineer)
ELSE
  alerta_mensaje('Proceso cancelado.!', 'N');
END IF;
```

### **Opción 2: P_JASPER_A_EXCEL (REST - Modern)**

```
Trigger: PUSH_BUTTON331 ("Exportar Excel Jasper")
Process:
  1. Confirma: "¿Seguro de generar los datos en la fecha seleccionada?"
  2. Validar FEC_INI y FEC_FIN completos
  3. Llamar: P_JASPER_A_EXCEL(:FEC_INI, :FEC_FIN)
  4. Output: Archivo Excel (presumably via Jasper Report)
  
Status: "Proceso Terminó Exitosamente"
```

**Pseudocódigo Trigger:**
```plsql
IF (:CONSULTA.FEC_INI IS NULL AND :CONSULTA.FEC_FIN IS NULL) THEN
  ERROR: "Debe seleccionar fechas..."
  RAISE FORM_TRIGGER_FAILURE
END IF;

set_application_property(cursor_style, 'busy');
P_JASPER_A_EXCEL(:CONSULTA.FEC_INI, :CONSULTA.FEC_FIN);
set_application_property(cursor_style, 'default');
alerta_mensaje('Proceso Terminó Exitosamente.', 'N');
```

### **Problema: DOS Botones Export (UX Confusión)**

```
Usuario ve:
  [Exportar Excel] (OLE - Broken)
  [Exportar Excel Jasper] (Jasper - Unknown status)
  
Confusión: ¿Cuál usar? ¿Cuál funciona?
Recomendación: UNIFICAR en React (1 botón, backend elige mejor ruta)
```

---

## 8. POST-EXPORT MANUAL CLEANUP (Offline Process)

### **Workflow Manual que Usuario Hace FUERA del Sistema**

```
1. Usuario descarga Excel desde Forms
2. Abre en Excel desktop
3. ELIMINA manualmente columnas innecesarias
   (Deja: #Póliza, Monto, Tipo Rechazo, Nombre Cliente, Afiliado)
4. GUARDA versión limpia como XXX-cleaned.xlsx
5. Envía o comparte con stakeholders
```

### **Razón (del transcript):**

> "El archivo es demasiado amplio. Tomamos la información más relevante 
> que nosotros entendemos que vamos a necesitar."

### **Columnas que Usuario MANTIENE (Essentials)**

| # | Columna | Por qué |
|---|---------|--------|
| 1 | Número de Póliza | Identificación única |
| 2 | Monto | Valor transacción |
| 3 | Tipo de Rechazo | Causa (rechazo o aprobado) |
| 4 | Nombre de Cliente | Referencia comercial |
| 5 | Número de Afiliado | Identificación cliente secundaria |
| 6 | (?) | Posible columna adicional no clara en transcript |

### **Columnas que Usuario ELIMINA**

- Frecuencia de Pago
- Fecha Tokeniza
- Número Tarjeta (sensible)
- Dirección Negocio
- Ejecutivo Cobro
- Y ~15 más

---

## 9. INTEGRACIONES EXTERNAS

### **Tablas de Datos**

| Tabla | Propósito | Integración |
|-------|-----------|-------------|
| **CLIENTE** | Master cliente | Validación LOV + filtro |
| **MOFICIAL** | Master oficial/ejecutor | LOV filtro OFICIAL |
| **INT_GER_DIR01_V** | Vista gerentes/intermediarios | LOV GERENTE + INTERMEDIARIO |
| **(Unknown)** | Transacciones pólizas | Main resultados (reverse-engineer needed) |

### **Stored Procedures (Truncated)**

| Proc | Purpose | Status |
|------|---------|--------|
| **BUSCA_TRANSACCIONES** | Main search query | ❌ Truncated |
| **GENERA_REPORTE** | Generate OLE Excel | ❌ Truncated |
| **P_JASPER_A_EXCEL** | Generate Jasper Excel | ✅ Visible (2 lines) |

### **External Libraries (Attached)**

```
- HOJA_EXCEL    (Custom Excel library)
- PAQ_EXCEL     (Excel package)
- WEBUTIL       (Oracle Web utilities - OLE automation)
- ERRORES       (Error handling library)
```

---

## 10. PROBLEMAS CONOCIDOS (Known Issues)

| # | Issue | Severity | Status | Impact |
|---|-------|----------|--------|--------|
| **P01** | Excel export broken (OLE) | 🔴 CRITICAL | Open | Users can't export reports |
| **P02** | Unclear when to use OLE vs Jasper | 🟡 MEDIUM | Open | User confusion |
| **P03** | Marcar/Desmarcar logic unclear | 🟡 MEDIUM | Open | Unclear if affects export |
| **P04** | No progress indicator on search | 🟡 MEDIUM | Open | UX: User thinks form hung |
| **P05** | Manual Excel cleanup offline | 🟡 MEDIUM | Design | Time waste, error-prone |
| **P06** | 22-column table hard to read | 🟡 MEDIUM | Design | Mobile unusable |
| **P07** | No column hiding/filtering | 🟡 MEDIUM | Open | Users must export to analyze |
| **P08** | Procedures truncated in XML | 🔴 CRITICAL | Blocker | Can't migrate until recovered |

---

## 11. PERFORMANCE CONSIDERATIONS

### **Potential Performance Issues**

```
Scenario: User searches without filters (just date range, whole month)
Result set: Could be 10,000 - 100,000+ records
Problem: 
  - Oracle: Query slow if no indexes on FEC_TRA
  - Forms: Rendering 16 rows at a time is OK, but LOVs = slow
  - React: Must implement pagination/virtualization
```

### **Metrics to Establish (Sprint 0)**

```
- Typical result set size per month: _____ records
- Current Forms query time: ____ ms
- Current Forms LOV load time: ____ ms
- Current Forms export time: ____ ms (when it works)
- Acceptable React performance: ≤ 2X Forms (2X multiplier)
```

---

## 12. SECURITY CONSIDERATIONS

### **Access Control**

```
✓ User must be authorized in COBROS/FINANZAS module
✓ Can only see transacciones for their assigned region/office/intermediary?
  (NOT CLEAR - must verify in Sprint 0)
```

### **Data Sensitivity**

```
⚠️ Contains PII: Customer names, account info (tarjeta numbers)
   Mitigation: Mask tarjeta in UI (show last 4 only)
⚠️ Contains financial data: Montos, aprobaciones
   Mitigation: Access logs, audit trail required
```

---

## 13. REQUIREMENTS PARA MIGRACIÓN A REACT

### **Funcional Completo**

- ✅ Date range filtration
- ✅ Client code filtration
- ✅ Official/Executive filtration
- ✅ Intermediary filtration
- ✅ Manager filtration
- ✅ Real-time validation (feedback on date errors)
- ✅ Results table (virtualized for 10K+ rows)
- ⚠️ Marcar/Desmarcar (clarify UX first)
- ⚠️ Excel export (decide: OLE vs Jasper vs native React export)

### **Non-Functional Requirements**

- Performance: Search < 2X Forms time
- Accessibility: WCAG 2.1 AA minimum
- Responsive: Desktop + tablet (mobile TBD)
- Availability: Same SLA as current system
- Data integrity: 100% accuracy of exported data

---

## 14. UNKNOWNS PARA CLARIFICAR EN SPRINT 0

### **Critical Unknowns**

| # | Unknown | Owner | Impact |
|----|---------|-------|--------|
| U01 | What is main transaction table name? | Sage + DBA | BLOCKER - must reverse-engineer |
| U02 | BUSCA_TRANSACCIONES full source code | Sage + DBA | BLOCKER - procedures truncated |
| U03 | GENERA_REPORTE full source code | Sage + DBA | BLOCKER - export logic hidden |
| U04 | How does Marcar/Desmarcar affect export? | BA + User | Clarify UX before coding |
| U05 | Is export filtering by selected rows? | BA + User | Clarify logic |
| U06 | Expected result set size per month? | DBA | Performance planning |
| U07 | Access control: by region/office/intermediary? | BA + Security | Authorization rules |
| U08 | Mobile support required? | BA + PM | Component architecture |
| U09 | Keep OLE export or switch to Jasper/native? | BA + PM | Export strategy |
| U10 | Filter combinations allowed? (e.g., both OFICIAL + INTERMEDIARIO?) | BA + User | Business logic validation |

---

## 15. ROADMAP RECOMENDADO PARA MIGRACIÓN

### **Sprint 0 (Semana 1): Archaeology + Requirements**

```
- [ ] Sage + DBA recover truncated procedures (2-3 days)
- [ ] BA clarify Marcar/Desmarcar logic (1 day)
- [ ] BA clarify access control rules (1 day)
- [ ] BA establish performance baselines (1 day)
- [ ] Kira: UX research on export button (1 day)
- [ ] Documentar unknown queries, formatos Excel
- [ ] Deliverable: Architecture Decision + Requirements Doc
```

### **Sprint 1: Piloto Form (NOT RECOMENDADO - too complex)**

```
⚠️ Recomendación: Usar forma más simple como piloto
   Esta forma = "Wave 2" (después de 1-2 formas exitosas)
   
Razón: 3 procedures truncadas + many unknowns = high risk
       Mejor: Start con form < 5 campos, 1 LOV, sin export
```

### **Wave 2 (Sprints 2-3): THIS FORM**

```
- Sage: Design ORDS endpoints
  - GET /api/cliente/{id}
  - GET /api/oficial
  - GET /api/gerente
  - GET /api/intermediario
  - POST /api/transacciones/search (main query)
  - POST /api/transacciones/export (Excel)

- Nova: React components
  - DateRangeFilter
  - SelectFilters
  - ResultsTable (virtualized)
  - ExportActions

- Ivy: Test cases
  - Filter validations
  - Result set accuracy
  - Export file format

- Milo: Design system
  - Table component with sorting/filtering
  - Modal dialogs
  - Loading indicators
```

---

## DOCUMENTOS RELACIONADOS

- [case-study-rep-aprobarechazo.md](./case-study-rep-aprobarechazo.md) — Análisis técnico profundo
- [DECISION-rep-aprobarechazo-piloto.md](./DECISION-rep-aprobarechazo-piloto.md) — Go/No-Go decision
- [RUNBOOK-archaeology-sprint.md](./RUNBOOK-archaeology-sprint.md) — Paso a paso Sprint 0

---

**Documento preparado por:** GitHub Copilot (AI Business Analyst)  
**Para:** Cesar (CEO) + Business Analyst Team  
**Fecha:** 2026-06-12
