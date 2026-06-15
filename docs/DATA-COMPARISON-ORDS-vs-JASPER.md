# Comparación de Datos: ORDS vs Jasper Excel
**Fecha:** 2026-06-15  
**Rango:** 2026-01-01 a 2026-06-15  
**Usuario:** Cesar Ricardo  

---


**Columnas (20 total):**
- #
- ID
- Compania
- Ramo
- Secuencial
- Monto
- Estado
- Estatus Poliza
- Cod. Rechazo
- Respuesta Banco
- Num. Autoriza
- Lote ID
- Frecuencia Pago
- Oficial
- Gerente
- Intermediario
- Sel.

**Primeros 30 registros extraídos de React/ORDS:**

[Se están extrayendo los datos... revisar archivo de salida]

**Tamaño:** 1.8 MB  
**Rango de fechas:** 01-JAN-2026 a 15-JUN-2026  

[Se necesita extraer datos del XLS...]

---

## Análisis Requerido


1. **¿Tienen los mismos IDs de transacción?**
   - ORDS IDs: ?
   - Jasper IDs: ?
   - Solapamiento: ?

2. **¿Diferencias en columnas de valores (no de días)?**
   - Monto: ¿Diferente?
   - Estado (APR/RECH/PEN): ¿Diferente?
   - Códigos de Rechazo: ¿Diferentes?
   - Oficiales/Gerentes/Intermediarios: ¿Diferentes?

3. **¿Qué registros están en Jasper pero NO en ORDS?**
   - Contar diferencias

4. **¿Qué registros están en ORDS pero NO en Jasper?**
   - Contar diferencias

---

## Instrucciones para Completar

```bash
# Desde React/navegador:
# 1. ✅ Búsqueda ejecutada: 2026-01-01 a 2026-06-15
# 2. ✅ Datos ORDS extraídos

# Desde Excel:
# 3. Abrir report6.xls en C:\Projects\migracion-forms-infoplan\
# 4. Listar primeros 30 registros
# 5. Comparar IDs, Montos, Estados, Códigos Rechazo

```

