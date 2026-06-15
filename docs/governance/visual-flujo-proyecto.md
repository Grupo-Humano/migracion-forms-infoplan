# Visual - Flujo Integral del Proyecto

Owner: Remy
Estado: ACTIVO
Objetivo: Material visual explicito para presentar el flujo completo del proyecto de punta a punta.

## 1) Etapas Macro (End-to-End)

```mermaid
flowchart LR
    A[0. Intake PBI<br/>Owner: Remy] --> B[1. Analisis funcional y tecnico<br/>Owner: Kira]
    B --> C[2. Analisis ORDS existente<br/>Owner: Sage<br/>SQL Developer MCP + comparativa]
    C --> CH{Checkpoint humano<br/>Reutilizable vs nuevo}
    CH -- Aprobado --> D[3. Diseno de solucion<br/>Owners: Kira + Nova + Sage]
    CH -- No aprobado --> C
    D --> E[4. Construccion<br/>Owners: Nova Front + Sage Back]
    E --> F[5. Validacion<br/>Owner: Ivy]
    F --> G{GO/NO-GO}
    G -- GO --> H[6. Cierre<br/>Owner: Remy<br/>done.md + sign-off]
    G -- NO-GO --> D
    H --> I[7. Handoff Sprint<br/>Owner: Remy<br/>update PROJECT_BRIEF]
```

## 2) Flujo Operativo por PBI (Estructura de Carpetas)

```mermaid
flowchart TD
    P[PBI-ID] --> E1[entradas/NOMBRE_PANTALLA]
    P --> S1[salidas/NOMBRE_PANTALLA]
    P --> O1[orquestacion]

    E1 --> E11[descripcion-criterios.md]
    E1 --> E12[transcripcion-funcionales.md]
    E1 --> E13[FORMA.xml]

    O1 --> O11[plan.md]
    O1 --> O12[progress.md]
    O1 --> O13[done.md]

    E1 --> A1[Analisis tecnico]
    A1 --> S1
    S1 --> Q1[QA evidencia]
    Q1 --> O13
```

## 3) Flujo por Roles (Orquestacion AI Team)

```mermaid
flowchart LR
    subgraph COORD[Coordinacion y control]
        R[Remy<br/>Producer]
        K[Kira<br/>Product Designer]
        I[Ivy<br/>QA]
        D[Dash<br/>DevOps]
    end

    subgraph FRONT[Lane Frontend]
        F1[Nova<br/>UI componentes]
        F2[Nova<br/>estado + integracion]
    end

    subgraph BACK[Lane Backend]
        B1[Sage<br/>ORDS endpoints]
        B2[Sage<br/>SQL/PLSQL y seguridad]
    end

    R --> K
    K --> F1
    K --> B1
    F1 --> F2
    B1 --> B2
    F2 --> I
    B2 --> I
    D --> F2
    D --> B2
    I --> R
    R --> G[Decision GO/NO-GO]
```

## 4) Mapa Etapa -> Agente Responsable

```mermaid
flowchart TD
    E0[Etapa 0 Intake] --> O0[Remy]
    E1[Etapa 1 Analisis funcional] --> O1[Kira]
    E2[Etapa 2 Analisis ORDS] --> O2[Sage]
    E25[Etapa 2.5 Checkpoint humano] --> O25[Remy + CEO]
    E3F[Etapa 3 Frontend] --> O3F[Nova]
    E3B[Etapa 3 Backend] --> O3B[Sage]
    E4[Etapa 4 QA equivalencia] --> O4[Ivy]
    E5[Etapa 5 CI/CD y release] --> O5[Dash]
    E6[Etapa 6 Cierre y handoff] --> O6[Remy]
```

## 5) Gates de Control (Obligatorios)

```mermaid
flowchart TD
    G1[Gate 1 - Inicio<br/>Entradas completas] --> G2[Gate 2 - Construccion<br/>Contratos + UI mapeada]
    G2 --> G25[Gate 2.5 - Checkpoint humano ORDS<br/>Reutilizable vs nuevo aprobado]
    G25 --> G3[Gate 3 - Validacion<br/>Smoke + QA equivalencia]
    G3 --> G4[Gate 4 - Cierre<br/>Sign-off + done.md]

    G1 -. falla .-> R1[No avanza]
    G2 -. falla .-> R1
    G25 -. falla .-> R1
    G3 -. falla .-> R1
    R1 --> A1[Correccion en salidas]
    A1 --> G2
```

## 6) Uso en Presentacion

1. Abrir este archivo en VS Code para render Mermaid.
2. Presentar en este orden: Macro -> PBI -> Roles Front/Back -> Etapa/Agente -> Gates.
3. Cerrar con estado actual del sprint y proximo hito.

## 7) Referencias

- `PROJECT_BRIEF.md`
- `docs/intake/README.md`
- `docs/intake/guia-arranque-pbi.md`
- `docs/governance/plan-accion-anti-ahogo.md`
