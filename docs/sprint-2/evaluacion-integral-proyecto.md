# Evaluacion Integral del Proyecto (No solo estructura)

Fecha: 2026-06-15  
Coordinacion: Remy  
Equipo: Nova, Sage, Milo, Dash, Ivy

## 1. Objetivo

Validar estado real del proyecto extremo a extremo (funcional, tecnico, calidad, seguridad, operacion y orquestacion), no solo la estructura de carpetas.

## 2. Cobertura evaluada

- Gobierno y orquestacion (brief, runbooks, gate de intake).
- Backend ORDS (modulos, scripts, cobertura de handlers, smoke).
- Frontend React (integracion ORDS real, build, UX base).
- QA (checklist de equivalencia, sign-off sprint 2).
- Seguridad y operacion (secretos, ACL, ambientes, trazabilidad).
- Documentacion y consistencia entre artefactos.

## 3. Hallazgos por dominio

### 3.1 Gobierno y orquestacion

Estado: PARCIALMENTE CERRADO

Fortalezas:
- `PROJECT_BRIEF.md` actualizado con estado sprint, policy reuse-first y gate de intake por plantilla.
- `docs/governance/process/orquestacion-pbi-ords-react.md` actualizado con modo reinicio y GO/NO-GO por insumos.
- Plantilla de intake creada en `docs/templates/plantilla-intake-migracion.md`.

Brechas:
- No existe aun un "mensaje de arranque estandar" para solicitar insumos cuando CEO diga "migrar plantilla X".
- Falta evidenciar en cada nueva migracion el resultado del gate (`GO_INTAKE_COMPLETO` o `NO_GO_FALTAN_INSUMOS`).

### 3.2 Backend ORDS

Estado: PARCIALMENTE CERRADO

Fortalezas:
- Existe modulo ORDS publicado para flujo principal (`facturacion-aprobaciones-rechazos-v1`).
- Flujo core validado en UI: `gerentes`, `intermediarios`, `transacciones/search`.
- Scripts de despliegue y checklist disponibles en `backend/ords/scripts`.

Brechas:
- Inconsistencia documental: README/plan indican endpoints bajo `/facturacion/api/v1/aprobaciones-rechazos`, mientras runtime validado actual usa `/ords/infoplan/aprobaciones-rechazos`.
- Falta evidencia consolidada de `oficiales`, `seleccion` y `exportaciones` en matriz final sprint 2.
- Referencias a rutas/artefactos que no existen actualmente en repo (`backend/ords/tests/sprint-2/**`, `backend/ords/modules/**`).

### 3.3 Frontend React

Estado: CERRADO PARA FLUJO CORE

Fortalezas:
- Build de frontend pasa.
- Integracion ORDS real con OAuth/Bearer operativa en flujo principal.
- UI restilizada alineada con lenguaje visual observado de Infoplan.

Brechas:
- Falta reporte formal versionado en `docs/sprint-2/frontend-integration.md` (referenciado en plan/progress, no existe).
- `npm run dev` en raiz del repo falla (esperable por monorepo sin script global), pero falta instruccion operativa clara para evitar confusion.

### 3.4 QA

Estado: EN CURSO

Fortalezas:
- Checklist de equivalencia existe y tiene base de criterios.
- `docs/qa/sprint-2-deployment-signoff.md` creado (draft).

Brechas:
- Sign-off sprint 2 sigue condicional (no final).
- Falta tabla cerrada endpoint por endpoint con evidencia y resultado final.

### 3.5 Seguridad y operacion

Estado: RIESGO ABIERTO

Hallazgos:
- Hubo uso de credenciales locales en `.env` durante la sesion.
- Validaciones desde DB a ORDS via `UTL_HTTP` bloqueadas por ACL (`ORA-24247`), aun requieren resolucion DBA estable.
- Falta un runbook corto de seguridad operativa para manejo de secretos y rotacion en este proyecto.

## 4. Riesgos priorizados

1. Riesgo documental: decisiones y rutas inconsistentes entre runbooks y runtime real.  
Impacto: alto en onboarding y soporte.

2. Riesgo de cierre QA incompleto: sign-off final no emitido.  
Impacto: alto para cierre formal de sprint.

3. Riesgo operativo de seguridad: secretos y ACL sin estandar cerrado.  
Impacto: alto para ambientes compartidos.

## 5. Plan de cierre (accionable)

### 5.1 Remy (coordinacion)

- Emitir estandar "mensaje de arranque" obligatorio por plantilla (tomando la plantilla de intake).
- Unificar narrativa de base path ORDS en brief, README y sprint docs.
- Crear `docs/sprint-2/done.md` al cierre con evidencia consolidada.

### 5.2 Sage + Dash (backend/devops)

- Cerrar matriz de handlers sprint 2 con estado real por endpoint:
  - gerentes
  - intermediarios
  - transacciones/search
  - oficiales
  - seleccion
  - exportaciones
- Documentar diferencia entre ruta historica y ruta efectiva actual.
- Publicar guia ACL/UTL_HTTP para DBAPER (si aplica a pruebas de DB-side HTTP).

### 5.3 Nova + Milo (frontend)

- Crear `docs/sprint-2/frontend-integration.md` con:
  - evidencia de smoke,
  - URL/variables usadas,
  - limitaciones conocidas.
- Agregar nota operativa en README para ejecutar frontend desde `frontend/`.

### 5.4 Ivy (QA)

- Convertir `docs/qa/sprint-2-deployment-signoff.md` de draft a final.
- Incluir recomendacion definitiva GO/NO-GO con criterios de equivalencia.

## 6. Criterio de "evaluado todo"

La evaluacion integral se considera completa cuando:
- El sign-off QA pasa a final.
- Existe `docs/sprint-2/done.md` con evidencia cerrada.
- Se eliminan inconsistencias de ruta/artefactos en documentacion.
- Se deja protocolo de seguridad operativa (secretos/ACL) documentado.

Estado actual global: EN CURSO (base fuerte, cierre documental y operativo pendiente).
