# Sprint 3 Progress Tracker

Sprint: Sprint 3 - Certificacion ORDS vs Jasper  
Periodo: 2026-06-16 a 2026-06-18  
Branch: `feature/sprint-3-certificacion-jasper`  
Owner: Remy

---

## Estado general

| # | Tarea | Owner | Esfuerzo | Estado | Bloqueo |
|---|---|---|---|---|---|
| T-01 | Baseline Jasper normalizado | Sage | 0.5d | 🔄 EN EJECUCION (75%) | — |
| T-02 | Identificar filtro Jasper exacto | Sage | 1.0d | 🔄 EN EJECUCION (analisis inicial) | Necesita .jrxml para cierre exacto |
| T-03 | Matriz equivalencia campo a campo | Sage + Nova | 1.0d | ⏳ PENDIENTE | T-01, T-02 |
| T-04 | Correcciones de datos (si aplica) | Sage / Nova | 0.5d max | ⏳ PENDIENTE | T-03 |
| T-05 | Lazy enrichment frontend | Nova | 0.5d | 🔄 EN EJECUCION (paralelo) | — |
| T-06 | QA sign-off final | Ivy | 0.5d | 🔄 EN EJECUCION (subinvestigacion N/D) | Validacion DB requerida |
| T-07 | Cierre y PR Sprint 3 | Remy | 0.25d | ⏳ PENDIENTE | T-06 |

**Estado de sprint:** EN EJECUCION (inicio formal 2026-06-16).  
**Riesgo principal:** Filtro Jasper desconocido (diferencia 3913 vs 39284).  
**Prerequisito inmediato:** Sage ejecuta T-01 primero para desbloquear toda la cadena.
**Gate de continuidad:** BLOQUEADO por bug ALTA abierto `#1` hasta pasar a correccion validada.

---

## Daily Standup + Retro (2026-06-15, cierre Sprint 2 / arranque Sprint 3)

| Miembro | Hizo hoy | Hara manana | Bloqueador |
|---|---|---|---|
| Remy | Cierre doc Sprint 2, commit+push 36 archivos, PR abierto | Kickoff Sprint 3: asignar owners WS | Ninguno |
| Sage | SQL extendido, fix ORA-01722, validacion cobertura DB | WS2: filtro exacto Jasper para alinear conteo | Necesita `.jrxml` o SQL Jasper |
| Nova | Enrichment pipeline, token lock, batch limit | WS3: conectar query certificacion a UI | Enrichment all-at-once → migrar a lazy |
| Ivy | Validacion flujo en localhost:4177, sign-off borrador | Casos de prueba equivalencia por id_transaccion | Necesita id_transaccion de muestra Jasper |
| Milo | Benchmarking visual completado | Standby hasta siguiente pantalla | Ninguno |
| Dash | Sin tareas activas | Instalar GitHub CLI | CLI no instalado |
| Kira | Intake PBI-202787 definido | Priorizar Wave 1 post-certificacion | Ninguno |

---

## Validacion del daily anterior (2026-06-16)

Resultado: **VALIDADO**

- [x] Compromiso Remy cumplido: kickoff y asignacion por workstream documentados.
- [x] Compromiso Sage activado: T-01 en ejecucion como prerequisito oficial.
- [x] Compromiso Nova activado: T-05 en paralelo para remover enrichment all-at-once.
- [x] Compromiso Ivy confirmado: casos para equivalencia listos, pendientes de insumos de T-03.
- [x] Bloqueadores registrados en tracker (filtro Jasper/.jrxml, GitHub CLI).

Conclusion operativa: el daily previo era consistente y se ejecuta segun plan.

---

## Simulacion en caliente UI (2026-06-16)

Escenario ejecutado en `http://localhost:4177`:

- Filtros usados:
	- `fecha_desde`: 2026-01-01
	- `fecha_hasta`: 2026-02-17
	- `gerente/intermediario`: Todos

Resultado de corrida:

- [x] Consulta principal completa sin quedarse en `Consultando...`.
- [x] Grilla renderiza `Resultados (100)`.
- [x] LOVs de Gerente e Intermediario cargadas en UI.
- [x] `Exportar Jasper` habilitado despues de la busqueda.
- [ ] Paginado incremental no avanza: al presionar `Siguiente pagina` aparece mensaje:
	- `No se pudieron cargar mas registros porque el servicio repitio la misma pagina.`
	- `Registros acumulados` permanece en 100.

Decision operativa:

- Se mantiene T-05 en ejecucion.
- Se abre linea de investigacion conjunta Nova+Sage para paginacion ORDS (offset/cursor repetido).
- No bloquear T-02/T-03 por este punto, pero documentarlo en sign-off tecnico.

---

## Investigacion QA: `N/D` en telefonos y datos de oficial (2026-06-16)

Solicitud CEO: validar contra DB si los `N/D` en UI reflejan realidad de datos.

### Evidencia en caliente (UI, primera pagina renderizada)

Muestra: 100 filas (consulta 2026-01-01..2026-02-17)

- `Oficial`: 95/100 en `N/D`
- `Gerente`: 95/100 en `N/D`
- `Director`: 100/100 en `N/D`
- `Intermediario`: 95/100 en `N/D`
- `Telefono 1`: 100/100 en `N/D`
- `Telefono 2`: 100/100 en `N/D`
- `Telefono 3`: 100/100 en `N/D`

### Evidencia baseline Jasper (3913 filas)

- `NOMBRE_OFICIAL`: 0% en blanco
- `NOMBRE_GERENTE`: 0% en blanco
- `NOMBRE_DIRECTOR`: 0% en blanco
- `NOMBRE_INTERMEDIARIO`: 0% en blanco
- `TELEFONO_1`: 0% en blanco
- `TELEFONO_2`: 90.21% en blanco
- `TELEFONO_3`: 99.72% en blanco

### Evidencia DB historica documentada (sprint-2 checklist)

- `con_telefono_1`: 32424
- `con_telefono_2`: 12302
- `con_telefono_3`: 0

### Diagnostico preliminar

Hay brecha significativa entre UI y baseline Jasper en campos de oficial/gerencia/director/intermediario y `telefono_1`.
Esto apunta a problema de enriquecimiento/paginado o mapeo de endpoint, no a ausencia real de datos en DB para todos los casos.

### Accion QA requerida (Ivy + Sage)

1. Ejecutar validacion DB con muestra de `id_transaccion` mostrados en UI (top 100).
2. Comparar por `id_transaccion` los campos:
	 - `nombre_oficial`, `nombre_gerente`, `nombre_director`, `nombre_intermediario`
	 - `telefono_1`, `telefono_2`, `telefono_3`
3. Clasificar diferencia por tipo:
	 - `faltante_db`, `faltante_ords`, `faltante_enrichment_ui`, `mapeo_incorrecto`

SQL objetivo minimo (a ejecutar en DB de desarrollo):

```sql
-- Reemplazar por lista real de IDs observados en UI
WITH ids AS (
	SELECT 1759616 AS id_transaccion FROM dual
)
SELECT
	t.id_transaccion,
	t.cliente,
	t.intermediario,
	igd.nombre_intermediario,
	igd.nombre_gerente,
	igd.nombre_director,
	c.oficial AS cod_oficial,
	mo.nombre_oficial,
	tel.telefono_1,
	tel.telefono_2,
	tel.telefono_3
FROM transacciones_cobro_recurrente t
LEFT JOIN cliente c
	ON c.codigo = t.cliente
LEFT JOIN moficial mo
	ON mo.codigo = c.oficial
LEFT JOIN int_ger_dir01_v igd
	ON igd.intermediario = t.intermediario
LEFT JOIN (
	SELECT
		x.codigo_cliente,
		MAX(CASE WHEN x.rn = 1 THEN x.telefono END) AS telefono_1,
		MAX(CASE WHEN x.rn = 2 THEN x.telefono END) AS telefono_2,
		MAX(CASE WHEN x.rn = 3 THEN x.telefono END) AS telefono_3
	FROM (
		SELECT
			p.codigo AS codigo_cliente,
			t2.numero AS telefono,
			ROW_NUMBER() OVER (
				PARTITION BY p.codigo
				ORDER BY t2.codigo
			) AS rn
		FROM cliente p
		LEFT JOIN telefono t2
			ON t2.codigo = p.codigo
	) x
	GROUP BY x.codigo_cliente
) tel
	ON tel.codigo_cliente = t.cliente
WHERE t.id_transaccion IN (SELECT id_transaccion FROM ids);
```

Gate QA para cerrar esta investigacion:

- [ ] Si DB/Jasper tienen valor y UI muestra `N/D`: abrir bug `enrichment-ui` con severidad ALTA.
- [ ] Si DB realmente no tiene valor: documentar `N/D` como esperado por campo.
- [ ] Publicar tabla de hallazgos en este tracker antes de sign-off final.

### Validacion puntual 10 IDs aleatorios (UI vs DB)

IDs muestreados desde pantalla:

- 50671, 50683, 50694, 50705, 50708, 50732, 50743, 50749, 50783, 50810

Resultado de contraste contra DB (consulta directa en HUMANO_DESA):

| id_transaccion | UI Oficial | DB nombre_oficial | UI Gerente | DB nombre_gerente | UI Director | DB nombre_director | UI Intermediario | DB cod_intermediario | UI Tel 1 | DB telefono_1 |
|---|---|---|---|---|---|---|---|---|---|---|
| 50671 | SUSANA MARLEYNI SOTO REYES | (vacio) | LUIS H. CARRENO W. | SUSANA MARLEYNI SOTO REYES | N/D | LUIS H. CARRENO W. | 74293 | 74293 | N/D | (vacio) |
| 50683 | N/D | (vacio) | N/D | IRIS ARACELIS SOTO TURVI | N/D | LAURA MABEL ARIAS CAPELLAN | N/D | 77223 | N/D | 8299898946 |
| 50694 | N/D | (vacio) | N/D | CAROLINA GITTE MEJIA | N/D | LAURA MABEL ARIAS CAPELLAN | N/D | 71547 | N/D | 8092564610 |
| 50705 | N/D | (vacio) | N/D | JOSE MANUEL FEBRIER GARCIA | N/D | MIQUEAS SALVADOR SOLIS CUEVAS | N/D | 71019 | N/D | (vacio) |
| 50708 | N/D | (vacio) | N/D | JOSE MANUEL FEBRIER GARCIA | N/D | MIQUEAS SALVADOR SOLIS CUEVAS | N/D | 72886 | N/D | 8497654561 |
| 50732 | N/D | (vacio) | N/D | ESTHER TAVERAS PREA | N/D | LUIS H. CARRENO W. | N/D | 72895 | N/D | (vacio) |
| 50743 | N/D | (vacio) | N/D | SANDRA YVELISSE JIMINIAN SOSA | N/D | LUIS H. CARRENO W. | N/D | 73541 | N/D | (vacio) |
| 50749 | N/D | (vacio) | N/D | ANYAURY STEPHANY VALDEZ ROCHET | N/D | ANDRES ALBERTO LOSADA GUERRERO | N/D | 74323 | N/D | 8294996460 |
| 50783 | N/D | (vacio) | N/D | MARTIN ALFONSO HIERRO BALBUENA | N/D | LUIS H. CARRENO W. | N/D | 73361 | N/D | 8294700721 |
| 50810 | N/D | (vacio) | N/D | DENIS ALEXANDRA PEREZ JIMENEZ | N/D | LAURA MABEL ARIAS CAPELLAN | N/D | 73054 | N/D | (vacio) |

Conclusion QA de esta muestra:

- [x] Los 10 IDs existen en DB (no son datos fantasma de UI).
- [x] UI muestra `N/D` en campos donde DB si tiene valor (gerente/director/intermediario y parte de telefono_1).
- [x] Hay evidencia de mapeo cruzado en al menos 1 fila (50671: UI `Oficial` coincide con DB `nombre_gerente`; UI `Gerente` coincide con DB `nombre_director`).
- [x] Abrir bug ALTA `enrichment-ui-mapping-nd` y asignar a Nova+Sage.

Estado de apertura de bug (2026-06-16):

- Issue creado y abierto: `https://github.com/Grupo-Humano/migracion-forms-infoplan/issues/1`
- Titulo: `BUG ALTA: N/D masivo y mapeo cruzado en Oficial/Gerente/Director/Intermediario`
- Estado: `OPEN` (severidad ALTA)

Politica aplicada desde este punto:

- `NO_GO_BUGS_MAYORES_ABIERTOS`: no iniciar actividades pendientes mientras este bug ALTA no este creado y en correccion.
- QA (Ivy) es responsable de crear siempre el issue y adjuntar enlace en este tracker.

Accion inmediata de continuidad:

- Nova+Sage deben mover Issue `#1` a estado `en correccion` antes de retomar tareas pendientes fuera de remediacion.

---

## Detalle de tareas

### T-01 · Baseline Jasper normalizado
**Owner:** Sage | **ETA:** 2026-06-16 AM | **Estado:** 🔄 EN EJECUCION

- [x] `python scripts/inspect_report_xls.py` sobre `data/jasper-reference/report6.xls`
- [x] `data/jasper-reference/baseline_normalizado.csv` generado (3913 filas)
- [ ] Mapeo columnas XLS→ORDS en `docs/sprint-3/mapeo-columnas-xls-ords.md`
- [x] Conteo verificado: `len(df) == 3913`

Evidencia de ejecucion (2026-06-16):
- `row_count`: 3913
- `col_count`: 28
- `fecha_min`: 2026-01-01
- `fecha_max`: 2026-02-17
- `estado_counts`: R=2134, C=1779
- `baseline_csv`: `data/jasper-reference/baseline_normalizado.csv`

---

### T-02 · Identificar filtro Jasper exacto
**Owner:** Sage | **ETA:** 2026-06-16 PM | **Estado:** 🔄 EN EJECUCION (analisis inicial)

- [ ] Inspeccionar columnas XLS para inferir filtros (compania, ramo, tipo)
- [ ] Ejecutar variaciones SQL en DB hasta convergencia a ~3913
- [ ] `backend/ords/sql/certif_query_jasper_equiv.sql` creado
- [ ] Checklist `docs/sprint-2/checklist-equivalencia-ords-jasper.md` actualizado

Evidencia de inferencia inicial (desde baseline CSV):
- `COMPANIA`: 30 en 3913/3913 filas.
- `RAMO`: 95 en 3897 filas; 93 en 16 filas.
- `ESTADO`: R=2134, C=1779.
- `GRUPO` dominante: SALUD INDIVIDUAL LOCAL (3758).
- Hipotesis fuerte: Jasper aplica filtro por compania 30 y universo salud (ramo 95 primario, 93 residual).

---

### T-03 · Matriz equivalencia campo a campo
**Owner:** Sage + Nova | **ETA:** 2026-06-17 PM | **Estado:** ⏳ PENDIENTE (espera T-01, T-02)

- [ ] JOIN baseline_normalizado.csv vs payload ORDS por `id_transaccion`
- [ ] % match calculado por campo con clasificacion de diferencia
- [ ] `data/sprint-3/matriz-diff-ords-jasper.csv` generado
- [ ] `docs/sprint-3/resultado-equivalencia.md` con tabla resumen
- [ ] Criticos >= 99.5% | Alta >= 99.0%

---

### T-04 · Correcciones de datos (timebox 0.5d)
**Owner:** Sage / Nova | **ETA:** 2026-06-17 fin | **Estado:** ⏳ PENDIENTE (espera T-03)

- [ ] Aplicar solo correcciones con causa raiz identificada
- [ ] Commit individual por campo corregido
- [ ] Re-ejecutar T-03 post-correcciones

---

### T-05 · Lazy enrichment frontend
**Owner:** Nova | **ETA:** 2026-06-17 | **Estado:** 🔄 EN EJECUCION (paralelo)

- [ ] IntersectionObserver o enrichment por pagina cargada
- [ ] Eliminar `MAX_ENRICHMENT_BATCH` hardcoded
- [ ] Prueba en `localhost:4177` con 100+ filas sin cuelgue

Evidencia de kickoff tecnico (2026-06-16):
- `frontend/src/App.tsx`: `MAX_ENRICHMENT_BATCH = 5` (linea 9).
- `frontend/src/App.tsx`: recortes por batch en enrich (`slice(0, MAX_ENRICHMENT_BATCH)`).
- `frontend/src/App.tsx`: llamadas a `enrichRows` confirmadas en flujo de busqueda y load-more.

---

### T-06 · QA sign-off final
**Owner:** Ivy | **ETA:** 2026-06-18 PM | **Estado:** ⏳ PENDIENTE (espera T-03, T-04)

- [ ] Revisar `resultado-equivalencia.md`: umbrales cumplidos
- [ ] Validar UI con ventana 2026-01-01..2026-02-17
- [ ] `docs/qa/sprint-3-signoff.md` redactado con GO/NO-GO
- [ ] `telefono_3 = N/D` documentado como limitacion aceptada

---

### T-07 · Cierre y PR Sprint 3
**Owner:** Remy | **ETA:** 2026-06-18 fin | **Estado:** ⏳ PENDIENTE (espera T-06)

- [ ] `docs/sprint-3/done.md` → CERRADO
- [ ] `PROJECT_BRIEF.md` secciones 7+8 actualizadas para Sprint 4
- [ ] PR `feature/sprint-3-certificacion-jasper` → `develop` abierto

---

## Gate de cierre

- [ ] Conteo equivalente validado.
- [ ] Match >=99.5% campos criticos.
- [ ] Match >=99.0% campos alta prioridad.
- [ ] Diferencias residuales con owner/fecha.
- [ ] QA sign-off final publicado.

---

## Notas

- Regla mandatoria: no duplicar servicios. Toda resolucion debe partir de exploracion ORDS (`metadata-catalog`, `open-api-catalog`).
