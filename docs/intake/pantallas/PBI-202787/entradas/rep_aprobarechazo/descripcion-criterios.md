# Descripcion y Criterios - PBI 202787

PBI oficial:
- https://dev.azure.com/humanoseguros/Infoplan-Web/_workitems/edit/202787

## Description

Como usuario autorizado para consultar y generar reportes de aprobaciones y rechazos de polizas,
quiero poder filtrar y consultar las polizas aprobadas o rechazadas entre un rango de fechas determinado
para generar un reporte detallado, exportarlo en formato Excel y manejar la informacion de manera eficiente.

## Acceptance Criteria

### CA-01: Consulta de Polizas Aprobadas y Rechazadas

- El sistema debe permitir ingresar una fecha de inicio y una fecha de fin para la consulta de polizas aprobadas o rechazadas.
- El sistema debe aceptar un codigo de cliente para generar un reporte especifico de ese cliente, o dejarlo en blanco para generar todos los registros.
- El sistema debe mostrar un boton para ejecutar la consulta (Ejecutar), el cual procesara los datos basados en los filtros establecidos.

### CA-02: Generacion de Reporte por Intermediario

- El sistema debe permitir generar reportes filtrados por el codigo de intermediario, si el usuario ingresa dicho codigo.
- Si no se ingresa un codigo de intermediario, el sistema generara el reporte completo, con todos los intermediarios.

### CA-03: Exportacion de Reporte a Excel

- Una vez que los datos se generen y visualicen en la pantalla, el sistema debe permitir exportar los datos a un archivo Excel.
- El sistema debe mostrar un boton de exportacion para generar el archivo Excel con la informacion mostrada.
- El sistema debe incluir columnas relevantes como: numero de poliza, monto, tipo de rechazo, nombre de cliente, numero de afiliado y numero de poliza.
- El sistema debe exportar el archivo sin errores, tal como lo hacia en versiones anteriores.

### CA-04: Filtrado y Limpieza de Informacion

- El sistema debe permitir al usuario filtrar y eliminar columnas de informacion no necesarias desde el archivo Excel exportado.
- El sistema debe permitir al usuario seleccionar las columnas relevantes que deben quedar en el archivo final.
