# Salida Sprint 5 - Contrato de datos MVP

PBI: 203844
Pantalla: reemb_pago
Autores: Sage, Nova, Ivy
Estado: APROBADO PARA SPRINT 6
Fecha: 2026-06-16
Version: v1

## Objetivo

Definir contrato minimo estable para soportar flujo MVP de reemb_pago con validaciones de negocio y testabilidad QA.

## Flujo MVP cubierto

1. Buscar afiliado.
2. Cargar datos base (planes, dependientes, contactos, limites).
3. Capturar datos de reembolso.
4. Capturar solicitud de servicio y coberturas.
5. Guardar y consultar resumen.

## Request canonico de busqueda afiliado

{
  "criterio": {
    "tipo": "AFILIADO|CARNET|DOCUMENTO|NOMBRE",
    "valor": "string"
  },
  "paginacion": {
    "offset": 0,
    "limit": 20
  }
}

## Response canonico de busqueda afiliado

{
  "meta": {
    "total": 0,
    "offset": 0,
    "limit": 20
  },
  "items": [
    {
      "idAfiliado": "string",
      "nombreCompleto": "string",
      "identificacion": "string",
      "numeroCarnet": "string",
      "estadoAfiliado": "string"
    }
  ]
}

## Request canonico para crear/actualizar solicitud servicio

{
  "idSolicitudServicio": null,
  "idAfiliado": "string",
  "plan": {
    "codigo": "string",
    "tipo": "LOCAL|INTERNACIONAL|DENTAL"
  },
  "datosReembolso": {
    "fechaRecepcion": "YYYY-MM-DD",
    "fechaServicio": "YYYY-MM-DD",
    "viaEntrada": "APP|DIGITAL_INTERMEDIARIO|PRESENCIAL|WEB",
    "montoSolicitado": 0,
    "medioPago": "CHEQUE|TRANSFERENCIA",
    "motivoCambioMedioPago": null,
    "observacion": null
  },
  "prestador": {
    "tipo": "MEDICO|CENTRO",
    "id": null,
    "nombre": null,
    "especialidad": null,
    "fueraRed": false
  },
  "diagnosticos": [
    {
      "codigo": "string",
      "descripcion": "string"
    }
  ],
  "coberturas": [
    {
      "codigoCobertura": "string",
      "descripcion": "string",
      "frecuencia": 1,
      "montoReclamado": 0,
      "fueraCobertura": false,
      "montoNoCubierto": null,
      "descripcionNoCubierto": null
    }
  ]
}

## Response canonico de guardado

{
  "resultado": {
    "idSolicitudServicio": "number",
    "numeroSolicitud": "string",
    "estado": "PENDIENTE|APROBADA|RECHAZADA|ANULADA",
    "fechaApertura": "YYYY-MM-DD",
    "montoReclamado": 0,
    "montoPagar": 0,
    "montoNoCubierto": 0
  },
  "mensajes": [
    {
      "tipo": "INFO|WARN|ERROR",
      "codigo": "string",
      "detalle": "string"
    }
  ]
}

## Reglas de validacion minimas

1. Debe existir al menos un diagnostico.
2. Fecha servicio no puede ser futura.
3. Fecha recepcion no puede exceder ventana definida (ejemplo: 60 dias).
4. Si medio pago cambia, motivo es obligatorio.
5. Si fueraCobertura es true, descripcion y montoNoCubierto son obligatorios.

## Reglas de nullability acordadas

1. motivoCambioMedioPago: nullable si no hay cambio.
2. descripcionNoCubierto: nullable si no aplica fuera cobertura.
3. prestador.id: nullable cuando se crea prestador nuevo.
4. observacion: nullable.

## Criterios de testabilidad QA

1. Contratos con meta de paginacion consistente.
2. Mensajes de validacion normalizados por codigo.
3. Respuesta de guardado incluye estado y numero de solicitud para trazabilidad.

## Decision

Contrato v1 aprobado por equipo tecnico y QA para iniciar construccion Sprint 6.
