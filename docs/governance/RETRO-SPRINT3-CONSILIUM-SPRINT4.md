# Retro-Consilium Sprint 3 -> Sprint 4

Fecha propuesta: 2026-06-17
Duracion objetivo: 60-90 minutos
Facilitador: Remy

## Objetivo

Alinear al equipo completo sobre como ejecutar la siguiente pantalla aplicando lo aprendido en estas sesiones y cerrar un acuerdo operativo unico.

## Agenda sugerida

1. Contexto de cierre del PBI anterior (10 min)
2. Vision por rol (25 min)
3. Desacuerdos explicitos y resolucion (20 min)
4. Acuerdos finales y decisiones D-01..D-05 (20 min)
5. Plan inmediato Sprint 4 (10 min)

## Vision por miembro

### Remy (Producer)

- Necesidad: gates claros y cierre documental por fase.
- Propuesta: no iniciar desarrollo sin D-01 (pantalla objetivo) y D-02 (alcance MVP).

### Kira (Product)

- Necesidad: criterios funcionales exactos antes de construir.
- Propuesta: definir casos de aceptacion por flujo critico en kickoff.

### Milo (Visual)

- Necesidad: consistencia visual sin retrabajo final.
- Propuesta: checklist de estados visuales (cargando, error, vacio, datos).

### Nova (Frontend)

- Necesidad: contrato estable para evitar mapeos fragiles.
- Propuesta: validar payload real antes de cerrar modelo de UI.

### Sage (Backend)

- Necesidad: SQL/ORDS canonico y medible.
- Propuesta: baseline de datos y query certificable antes de exponer endpoint final.

### Ivy (QA)

- Necesidad: evidencia reproducible en caliente, no solo resultados narrativos.
- Propuesta: matriz de pruebas por severidad + sign-off formal obligatorio.

### Dash (DevOps)

- Necesidad: entorno y comandos estables de ejecucion.
- Propuesta: smoke checks basicos y trazabilidad en pipeline.

## Desacuerdos esperados (forzados para evitar groupthink)

1. Rapidez de UI vs formalidad de contrato de datos.
2. Tiempo invertido en comparativa analitica vs entrega funcional temprana.

## Acuerdos finales a firmar

- D-01 Pantalla objetivo seleccionada.
- D-02 Alcance MVP de la pantalla (incluye exclusiones).
- D-03 Contrato ORDS minimo aceptado (campos, nullability, filtros).
- D-04 Criterio QA GO/NO-GO para esta pantalla.
- D-05 Criterio de cierre documental (progress + done + brief).

## Plantilla de acta (llenar en sesion)

- Pantalla objetivo (D-01):
- Alcance MVP (D-02):
- Endpoint(s) ORDS objetivo (D-03):
- Casos QA criticos (D-04):
- Fecha objetivo de sign-off:
- Riesgos aceptados:
- Owner por riesgo:

## Criterio de salida de la retro

La sesion solo se considera completa cuando D-01..D-05 quedan resueltas y publicadas en `docs/sprint-4/progress.md`.
