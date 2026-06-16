# Sprint 2 - Enriquecimiento de Datos: Estrategia Reuse-First

**Fecha**: 2026-06-15  
**Estado**: Cerrado - Reuse-First Architecture Documentado  
**Decisión**: Campos NULL mantienen compatibilidad con endpoints ORDS existentes

---

## 📊 Análisis: Dónde Viven los Datos

### Tabla Fuente: `transacciones_cobro_recurrente`

**Campos poblados por JOIN a CLIENTE** ✅:
- `grupo` (← cliente.sec_eco)
- `cliente_poliza` (← cliente.nom_emp)
- `tipo_documento` (← cliente.cdtipide)
- `num_documento` (← cliente.cdideper)
- `frecuencia_pago` (← cliente.fre_sal)

**Campos SIN relación directa en tabla (NULL por diseño)** ⏳:
- `oficial`, `nombre_oficial`
- `gerente`, `nombre_gerente`
- `intermediario`, `nombre_intermediario`
- `nombre_director`, `estatus_poliza`, `telefonos`

**Motivo**: Estas relaciones NO existen como campos en `transacciones_cobro_recurrente`. Para traerlas, se necesitaría:
1. Buscar póliza asociada a transacción
2. Buscar intermediario de póliza
3. Buscar gerente/oficial por estructura org

---

## 🏗️ Arquitectura Reuse-First (Sprint 2 + Sprint 3)

### Sprint 2 (ACTUAL - Cierre)
✅ **Handler retorna transacciones con datos CLIENTE**  
✅ **Campos de personal quedan NULL**  
✅ **Frontend renderiza tabla sin errores**  

Ejemplo fila:
```json
{
  "id_transaccion": 50776,
  "cliente": 2165575,
  "monto": 39140.60,
  "estado": "R",
  "codigo_rechazo": "51",
  "grupo": "P",                    // ← del CLIENTE
  "cliente_poliza": "",            // ← del CLIENTE (vacío en BD)
  "tipo_documento": "1",           // ← del CLIENTE
  "num_documento": "02800054039",  // ← del CLIENTE
  "oficial": null,                 // ← Will enrich from /oficiales endpoint
  "gerente": null,                 // ← Will enrich from /gerentes endpoint
  "intermediario": null            // ← Will enrich from /intermediarios endpoint
}
```

### Sprint 3 (PENDIENTE)

**Opción A: Client-side Enrichment** ✅ Recomendado
```
Frontend:
1. Recibe array de transacciones (con NULL para oficial/gerente)
2. En paralelo, llama a:
   - GET /oficiales/:codigo (para lookup por transacción.cliente?)
   - GET /gerentes (para LOV)
   - GET /intermediarios (para LOV)
3. Denormaliza antes de renderizar
4. Muestra nombres junto a IDs

Ventajas:
- Reutiliza 100% endpoints existentes
- Backend simplificado
- No duplica query logic
```

**Opción B: Backend Orchestration** (Si se necesita)
```
Oracle PL/SQL function: fn_enrich_transacciones()
  - Itera transacciones
  - Para cada transacción, busca oficial/gerente/intermediario
  - Retorna enriquecida
  
Ventajas:
- Single round-trip
- Backend coordina todo

Desventajas:
- Requiere función nueva
- Posible duplicación de lookup logic
```

---

## 📋 Checklist Sprint 2 - COMPLETO

- [x] Handler retorna datos reales de transacciones_cobro_recurrente (39,283 registros)
- [x] JOINs a CLIENTE poblados (grupo, cliente_poliza, tipo_documento, num_documento, frecuencia_pago)
- [x] Campos de personal (oficial, gerente, intermediario) documentados como NULL
- [x] Frontend renderiza tabla completa sin errores
- [x] Endpoints reutilizables documentados para Sprint 3:
  - `GET /oficiales/:codigo`
  - `GET /gerentes`
  - `GET /intermediarios`
- [x] Decisión arquitectónica documentada: Reuse-First (no duplicar queries)

---

## 🚀 Sprint 2 → Sprint 3 Handoff

**Sprint 3 Owner** (si aplica):
- [ ] Elegir Opción A (client-side) o B (backend)
- [ ] Implementar enriquecimiento según decisión
- [ ] Agregar tests E2E para lookup paralelo
- [ ] Validar performance con 1000+ registros

**Documentación existente**:
- Módulos ORDS: [ORDS Modules Exploration](./ORDS-MODULES-EXPLORATION.md) ← crear en Sprint 3
- API Reference: `/oficiales`, `/gerentes`, `/intermediarios` handlers ya publicados

---

## 📌 Principios Aplicados

✅ **Reuse-First**: No crear handlers nuevos si existen  
✅ **Zero Duplication**: Un solo query per entidad (lookup endpoints)  
✅ **Documentation First**: Decisiones arquitectónicas claras para Sprint 3  
✅ **Pragmatic**: No bloquear Sprint 2 por datos que viven fuera de transacciones_cobro_recurrente

---

**SPRINT 2 CERRADO EXITOSAMENTE**  
Datos reales fluyendo, arquitectura documentada, sin duplicación.
