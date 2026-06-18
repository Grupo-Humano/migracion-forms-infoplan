# Salida Sprint 5 - Extraccion funcional consolidada

PBI: 203844
Pantalla: reemb_pago
Owner: Remy
Estado: VALIDADO PARA SPRINT 5
Fecha: 2026-06-16

## Resumen ejecutivo

La pantalla reemb_pago concentra alta complejidad y alta interdependencia. La recomendacion tecnica y funcional es reingenieria orientada a flujo por pasos, separando informacion de contexto (solo consulta) de componentes transaccionales (captura y acciones).

## Fuentes analizadas

1. descripcion-criterios.md
2. Levantamiento de Logica - reemb_pago.txt
3. Registro de Reembolso reemb_pago-es-ES.vtt
4. reemb_pago_fmb.xml
5. foto_pantalla_1.png
6. foto_pantalla_2.png

## Bloques funcionales priorizados (MVP)

1. Busqueda afiliado y precarga.
2. Tabs informativos: endosos, dependientes, limites, contactos.
3. Datos del reembolso: fecha recepcion, via de entrada, monto solicitado, observacion.
4. Medio de pago: cheque o transferencia con datos bancarios.
5. Solicitud de servicio: plan, asegurado/dependiente, fecha servicio, tipo servicio, prestador, diagnostico.
6. Coberturas: calculo de montos, fuera de cobertura, acciones controladas.
7. Guardado y resumen de solicitud.

## Reglas criticas extraidas

1. Antes de guardar, numero solicitud, estado y fecha apertura no deben estar fijos; se asignan al guardar.
2. Fecha de recepcion por defecto hoy, con limite de hasta 60 dias hacia atras.
3. Dependiente fallecido impacta estado global; desmarque requiere comentario obligatorio.
4. Al menos 1 diagnostico por reembolso.
5. Medio de pago puede cambiar, pero exige motivo obligatorio del cambio.
6. Fecha de servicio no permite futuro y valida rango parametrizado por plan.
7. Cobertura calcula monto total, monto a pagar y no reembolsado con reglas de plan/tarifa.
8. Monto a pagar protegido: solo editable via acciones autorizadas (cobro indebido, excepcion de negocio, negociacion, tarifa incorrecta por permisos).
9. Solicitar exgratia aplica a coberturas puntuales y requiere aprobador + comentario.
10. Generar pago solo para estado aprobado.

## Hallazgos de complejidad

1. Se identificaron procedimientos de consulta, creacion y CRUD altamente acoplados.
2. Existen dependencias de tablas temporales y paquetes auxiliares.
3. Se requiere evitar migracion literal 1:1 de la forma legacy.
4. La busqueda avanzada y paneles de detalle incrementan cardinalidad de datos y carga.

## Ambiguedades abiertas para decision

1. Politica exacta de estatus permitidos para anular en todos los escenarios.
2. Regla final para enviar carta (boton existe pero funcionalidad reportada como no activa).
3. Alcance de flujo exgratia en MVP: solo solicitud o ciclo completo.

## Decision de diseño para Sprint 6

1. Implementar flujo guiado por pasos, no pantalla monolitica.
2. Mantener tabs informativos desacoplados del formulario transaccional.
3. Aplicar validaciones criticas en backend y frontend.
4. Priorizar operacion estable con evidencia sobre completitud total de casos borde.

## Criterio de salida cumplido

- Inventario funcional priorizado: SI
- Reglas criticas documentadas: SI
- Ambiguedades identificadas: SI
- Apto para contrato de datos MVP: SI
