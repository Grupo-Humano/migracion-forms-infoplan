# Descripcion y Criterios - PBI-ID

## Metadatos

- PBI: 203844
- Pantalla: reemb_pago
- Owner: Remy
- Estado: BORRADOR | VALIDADO
- Fuente oficial: https://dev.azure.com/humanoseguros/Infoplan-Web/_workitems/edit/203844
- Titulo oficial: *Reclamos |  Gestión de Autorizaciones Médicas | Registro de Reembolso Pago | reemb_pago
- Fecha actualizacion: YYYY-MM-DD

## Description

Como usuario autorizado para gestionar reembolsos,
quiero registrar y administrar una solicitud de reembolso para un afiliado (incluyendo datos del reembolso, prestador, diagnósticos, coberturas, cartas y acciones de aprobación/rechazo/anulación),
para procesar el reclamo conforme a reglas del plan/póliza y dejar evidencia documental (cartas, comentarios, reportes) del trámite.

## Acceptance Criteria

CA-01: Búsqueda de afiliado y precarga de información (Pantalla principal)
El sistema permite buscar afiliado por número de afiliado / carnet / identificación; al ejecutar la búsqueda, se muestran resultados y se precarga la información del afiliado (planes vigentes y, si aplica, plan dental).

El sistema muestra secciones/pestañas informativas asociadas al afiliado (ej., endosos, dependientes, límites, contactos) como información de consulta (base fija del afiliado).

En Endosos, el sistema visualiza endosos locales y, si existen, endosos internacionales.

En Dependientes, el sistema muestra los dependientes del núcleo y soporta marcar/desmarcar un dependiente como fallecido, afectando su estado “en todas las demás pantallas”; al desmarcar, el sistema requiere una razón/comentario de modificación.

CA-02: Búsqueda avanzada de afiliado (Subpantalla 2)
El sistema expone una búsqueda avanzada que permite buscar por cédula, pasaporte, carnet, número asegurado, nombre y/o apellido.

Cuando se busca por nombre/apellido, el sistema permite completar primer/segundo nombre y primer/segundo apellido sin obligar todos los campos, y lista coincidencias para seleccionar el afiliado correcto.

El sistema muestra un contador de resultados (p. ej., “100 resultados”) para la búsqueda avanzada.

CA-03: Consulta de Detalle de Afiliado y gestión de contactos (Subpantalla 3)
El sistema muestra “Detalle afiliado” con datos generales (nombre, identificación, sexo, edad, número afiliado, estado, número/estado de carnet, tipo titular/dependiente) y los planes actuales del afiliado; si existe plan dental, muestra vigencia/porcentaje/proveedor.

El sistema muestra endosos asociados a póliza (incluyendo internacionales si aplica).

El sistema muestra dependientes del titular y, si el plan es internacional, límites por subgrupos, deducible (contratado/pendiente/consumido) y límites de medicamentos (contratado/disponible y adicional).

El sistema permite agregar teléfonos y correos de contacto del afiliado y marcar preferido por tipo (teléfono/correo).

CA-04: Captura de “Datos del reembolso” y validaciones (Pantalla principal)
Antes de guardar, los campos Número de solicitud, Estado y Fecha de apertura se mantienen vacíos; al guardar el reembolso, el sistema asigna número automático, estado inicial (referenciado como pendiente) y fecha de apertura (fecha de registro).

El sistema registra el usuario que captura y la sucursal asociada al usuario.

El sistema permite capturar Fecha de recepción con valor por defecto “hoy” y permite seleccionar hasta 60 días hacia atrás.

El sistema soporta un indicador de Completivo:

Si está desmarcado, el campo asociado a completivo no es requerido y no permite captura.

Si está marcado, el campo asociado se vuelve obligatorio.

El sistema permite capturar Monto solicitado y Vía de entrada (App / Digital intermediarios-correo / Presencial / Web – oficinas virtuales, kiosco, Sara).

El sistema muestra Correo de notificación del asegurado precargado si existe; permite registrar uno nuevo o editar el existente.

El sistema permite capturar una observación/comentario general de la solicitud.

CA-05: Medio de pago y datos bancarios (Pantalla principal)
El sistema permite seleccionar medio de pago:

Cheque: habilita selección de sucursal (autocompleta) y “a quién será entregado”.

Transferencia bancaria: habilita sección de datos bancarios.

En transferencia, el sistema permite seleccionar una cuenta existente del afiliado (desplegable) y, al seleccionar, autocompleta: tipo de cuenta, tipo/propietario, documento, sexo, nacionalidad, banco/código/nombre y correo asociado a la cuenta.

El sistema diferencia Correo de notificación del reembolso (Humano) vs Correo asociado a la cuenta (notificación bancaria).

El sistema permite capturar una nueva cuenta, habilitando todos los campos requeridos para registrar manualmente la información.

Al seleccionar en Tipo de Propietario “Dependiente”, el sistema permite capturar manualmente los datos del propietario; al seleccionar “Asegurado”, autocompleta datos desde Infoplan.

El sistema permite el cambio del "medio de pago"; cuando se realiza este cambio, el sistema requiere un motivo del cambio (ej. cuenta inválida) y no permite completar el cambio sin motivo.

CA-06: Registro de servicio (recibo), prestador, diagnóstico y validaciones de fechas (Pantalla principal)
El sistema permite capturar Fecha de servicio con validación:

No permite fechas futuras.

Si la fecha excede un rango parametrizado,muestra alerta indicando que excede el rango según el plan seleccionado (para internacionales el rango puede ser diferente).

El sistema permite seleccionar Plan del afiliado (lista de planes del núcleo) y seleccionar titular o dependientes del núcleo.

El sistema muestra un “correo notificación” asociado al intermediario (puede venir en blanco si no existe).

El sistema soporta “Motivo del reembolso”: no obligatorio en planes con beneficio de reembolso, pero obligatorio en planes específicos sin el beneficio.

El sistema permite seleccionar Tipo de servicio y seleccionar prestador desde listado general; al seleccionar prestador, autocompleta especialidad, permitiendo elegir otra si el prestador tiene múltiples.

El sistema permite eliminar el prestador seleccionado y registrar prestador fuera de red mediante la subpantalla de alta.

El sistema requiere al menos 1 diagnóstico por reembolso; permite buscar diagnóstico por código o nombre (búsqueda por texto) y aplicar el seleccionado.

El sistema soporta prestador de tipo médico o centro con campos dinámicos según selección; muestra estado dentro/fuera de red y subtipo de centro cuando aplica.

El sistema permite seleccionar el tipo de moneda a utilizar.

CA-07: Subpantalla Agregar prestador , para prestadores fuera de red (Subpantallas 4 y 5)
Al dar click en pantalla agregar prestador se abrira una subpantalla.

El sistema requiere al menos: primer nombre, primer apellido (segundo nombre/apellido según disponibilidad en pantalla), localidad (local/internacional) y una especialidad; “centro donde labora” es opcional.

Al Agregar, el sistema registra el prestador, lo deja seleccionado para el reclamo actual y lo incorpora al catálogo para futuros reembolsos (no limitado al afiliado).

En alta de prestador (centro), el sistema solicita datos del centro con obligatoriedad declarada: localidad, nombre del centro y tipo de centro; permite capturar datos de contacto/dirección y vínculos asociados cuando aplique (internacional).

“Cancelar” cierra sin cambios; “Agregar” registra para reutilización.

CA-08: Registro de coberturas, reglas automáticas y fuera de cobertura (Pantalla principal)
El sistema permite buscar y seleccionar cobertura por código o por palabra clave; al seleccionar cobertura, autocompleta nombre/texto y asocia la información del prestador seleccionado.

El sistema permite capturar frecuencia (por defecto 1), monto reclamado, calcula monto total y determina monto a pagar aplicando reglas según plan/tarifa; calcula monto no reembolsado y asigna estatus de cobertura (ej. “aprobada” cuando aplica).

El sistema valida límites de frecuencia configurados por plan/cobertura (ej. frecuencia mensual máxima); si se excede, el sistema impide que la solicitud exceda el límite permitido.

El sistema permite agregar múltiples coberturas (sin límite explícito).

El sistema soporta marcar “Fuera de cobertura” para capturar un monto no cubierto y una descripción obligatoria; si no está marcado, el campo no se puede editar.

El sistema muestra un contador/resumen de cantidad de coberturas agregadas y montos del detalle.

CA-09: Acciones sobre coberturas (Pantalla principal)
El sistema permite eliminar una cobertura agregada.

El sistema permite “Modificar monto a pagar / Aplicar endoso” solicitando selección de endoso y aplicando el monto resultante.

El sistema permite consultar “Detalle de la cobertura” mostrando información de tarifa cuando el plan está atado a tarifario (y puede no mostrarla en planes sin tarifario).

El monto a pagar de una cobertura se considera protegido (no editable directamente) y solo se modifica mediante acciones específicas:

Cobro indebido: exige monto cobrado (no mayor al total), monto a pagar y razón obligatoria.

Excepción de negocio: permite definir monto a pagar con razón obligatoria.

Tarifa incorrecta: disponible solo para algunos usuarios/asegurados según reglas de acceso.

Negociación con prestador: permite definir monto a reembolsar con razón obligatoria.

El sistema permite “Solicitar exgratia” únicamente para la cobertura correspondiente (ej. código 1145), abriendo el flujo de aprobación.

CA-10: Solicitud de Exgratia (Subpantalla 7)
El sistema permite seleccionar el usuario aprobador y requiere un comentario para enviar la solicitud.

Al solicitar, el sistema envía un correo automático al aprobador con número de asignación/detalle y un link a Approvals para aprobar o declinar.

CA-11: Guardado y generación de “Solicitud de servicio” en el resumen (Pantalla principal)
Al guardar, el sistema confirma “cambios guardados”, limpia campos de captura para permitir registrar otra solicitud, y actualiza el encabezado con número/estatus/fecha de la solicitud de reembolso.

El sistema incorpora la solicitud capturada al Resumen del reclamo como una solicitud de servicio con número automático y muestra: plan, afiliado, estado (pendiente), recomendación del sistema, monto reclamado (incluye “no cubierto”), monto a pagar, fecha de servicio y tipo de servicio.

El sistema permite Editar solicitud mientras el estatus sea pendiente, habilitando ajustes de cobertura/prestador/asegurado/fecha servicio y recalculando montos.

CA-12: Generación de cartas (Devolución y Declinación) (Subpantalla 6)
El sistema permite generar Carta de solicitud de información / devolución seleccionando concepto(s) y documento(s) requerido(s) y capturando una observación para ser visible al cliente.

El sistema evita duplicidad: si se intenta agregar el mismo motivo o concepto dos veces, informa que ya fue agregado.

El sistema permite “Descargar carta” (genera documento); el botón “Enviar carta” existe pero no ejecuta funcionalidad actualmente.

El sistema permite generar Carta de declinación con flujo equivalente, usando mantenimiento distinto de motivos (devolución vs declinación), compartiendo el mantenimiento de conceptos.

En el modal de cartas, el sistema muestra información de intermediario y gerente asociados a la póliza.

El documento generado (de devolución) contiene datos dinámicos: titular, plan/póliza, vía/intermediario/gerente, fecha de recepción, concepto, documentos requeridos, observación, y un cálculo de plazo (referido como 60 días) para completar el proceso.

CA-13: Comentarios y documentos pendientes (Pantalla principal)
El sistema permite agregar comentarios a la solicitud, registrándolos en cascada con usuario, comentario, fecha y hora; sin límite explícito.

El sistema soporta “Recibir documentos pendientes” cuando la solicitud está en estatus “devuelta/vuelta”: muestra los documentos solicitados para marcarlos como recibidos y permite imprimir/descargar histórico de carta.

El sistema muestra un contador de comentarios asociado a la solicitud.

CA-14: Acciones por estatus sobre la solicitud de servicio (Pantalla principal)
El sistema expone acciones condicionadas por estatus:

Aprobar disponible en estatus pendiente; si está aprobada, se deshabilita.

Duplicar disponible solo en pendiente.

Rechazar disponible en múltiples estatus, excepto cuando ya está pagado (en pagado no se permite rechazar ni editar).

Anular aplicable según reglas descritas (pendiente/rechazada/aprobada) y restringida cuando el reclamo está pagado (según la regla mencionada).

El sistema muestra un panel/área con motivos de rechazo por cobertura, listando solicitud de servicio, cobertura y motivo.

CA-15: Descargas y vínculo a generación de pago (Pantalla principal)
El sistema permite descargar voucher (equivalente al voucher generado en radicación) a modo de consulta.

El sistema permite descargar un reporte de apertura/resumen con datos del asegurado, diagnósticos y coberturas; si no está aperturado (pendiente), ciertos campos (número de reclamación/fecha apertura/usuario apertura) pueden venir en blanco.

El sistema habilita Generar pago únicamente cuando el reclamo está en estatus aprobado y redirige a la pantalla “Solicitud de pago de reclamaciones” precargando el reclamo seleccionado.

CA-16: Campos informativos de auditoría médica (Pantalla principal)
El sistema muestra campos informativos relacionados a revisión/auditoría médica (p. ej., ticket/número y comentario), los cuales son completados por auditoría médica y no bloquean el registro/proceso por parte del oficial/gestor de reembolso.

El sistema muestra fecha de renovación del asegurado.


Image
Image

## Criterios de completitud del documento

- [ ] URL del PBI cargada
- [ ] Titulo oficial cargado
- [ ] Description completa
- [ ] Acceptance Criteria completos
- [ ] Owner y fecha actualizados
