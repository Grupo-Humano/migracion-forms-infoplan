# Plan Operativo - PBI-202787

## Roles

- Remy (Producer): priorizacion, handoff, control de alcance.
- Kira (Product Designer): criterios funcionales y UX objetivo.
- Nova (Frontend): implementacion React UI/estado/componentes.
- Sage (Backend): ORDS, contratos API, reglas de negocio.
- Ivy (QA): plan de pruebas y sign-off.

## Objetivo

Completar migracion controlada de `rep_aprobarechazo` con trazabilidad de entradas y salidas.

## Trabajo inicial

1. Validar consistencia entre `descripcion-criterios.md`, `transcripcion-funcionales.md` y XML.
2. Consultar SQL Developer MCP para listar modulos ORDS disponibles.
3. Comparar logica extraida con endpoints existentes (GET/POST/PUT/DELETE).
4. Publicar matriz reutilizable vs adaptable vs nuevo en `salidas/rep_aprobarechazo/`.
5. Ejecutar checkpoint humano y esperar aprobacion explicita antes de continuar.
6. Actualizar `salidas/rep_aprobarechazo/analisis-pbi.md` con gaps y decisiones.
7. Definir criterio de salida para QA.
