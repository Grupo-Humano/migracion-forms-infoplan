# Progress - PBI-202787

## Estado actual

- Estructura madre aplicada: SI
- Entradas organizadas: SI
- Salidas iniciales organizadas: SI
- Orquestacion creada: SI
- Analisis ORDS por SQL Developer MCP: SI
- Checkpoint humano ORDS: EN_ESPERA_APROBACION_HUMANA
- Incidencia Jasper en runtime real: ACTIVA (404 en `/exportaciones/jasper` y `/export/jasper`)
- Tarea obligatoria Jasper creada: SI (`salidas/rep_aprobarechazo/tarea-obligatoria-jasper.md`)
- Frontend contingencia aplicada: SI (OLE habilitado solo cuando Jasper no esta disponible)
- Hotfix backend urgente preparado: SI (`backend/ords/scripts/06_sage_ords_validation_publish_checklist.sql` ahora republica `transacciones/seleccion/{accion}`, `exportaciones/ole` y `exportaciones/jasper`)
- Jasper Web Call con datos completos: PREPARADO_EN_SCRIPT (retorna `rows` + `items` filtrados por `fec_ini` y `fec_fin`)
- Verificacion UI en vivo (2026-06-15): ORDS local `localhost:8080` no accesible (`ERR_CONNECTION_REFUSED`), por lo que Jasper no puede validarse aun en runtime
- Validador Oracle para Jasper full-data: SI (`backend/ords/sql/07_validate_jasper_button_logic.sql` incluye `validate_jasper_full_data_call` + `probe_jasper_http_get` con UTL_HTTP)
- Boton Jasper real en frontend: SI (`frontend/src/App.tsx` + `frontend/src/api/ordsClient.ts` ahora usan URL full-data legacy por fila seleccionada)
- Ajuste final requerido por owner aplicado: SI (boton Jasper replica logica XML `P_JASPER_A_EXCEL`: confirmacion + validacion de fechas + URL con `PCODIGO_COMPANIA/PDESDE/PHAS/POFICIAL/PGERENTE/PINTERMEDIARIO`)

## Proximo paso

- Presentar matriz reutilizable/adaptable/nuevo a owner y esperar aprobacion explicita.
- Si se aprueba, continuar iteracion funcional-tecnica sobre `rep_aprobarechazo`.
- Ejecutar script hotfix en BD objetivo (owner Sage) y adjuntar evidencia HTTP 200 + payload con `items` para cierre QA.
