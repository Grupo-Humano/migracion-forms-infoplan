// Tipos para el flujo MVP de reemb_pago - contrato v1
// PBI-203844 | Sprint 6

export type CriterioBusqueda = "AFILIADO" | "CARNET" | "DOCUMENTO" | "NOMBRE";

export type AfiliadoItem = {
  idAfiliado: string;
  nombreCompleto: string;
  identificacion: string;
  numeroCarnet: string;
  estadoAfiliado: string;
};

export type BusquedaAfiliadoRequest = {
  criterio: {
    tipo: CriterioBusqueda;
    valor: string;
  };
  paginacion: {
    offset: number;
    limit: number;
  };
};

export type BusquedaAfiliadoResponse = {
  meta: {
    total: number;
    offset: number;
    limit: number;
  };
  items: AfiliadoItem[];
};

export type ReembPasoId =
  | "busqueda"
  | "datos-reembolso"
  | "solicitud"
  | "coberturas"
  | "confirmacion";

export type ReembStep = {
  id: ReembPasoId;
  label: string;
  numero: number;
};

export const REEMB_STEPS: ReembStep[] = [
  { id: "busqueda", label: "Buscar Afiliado", numero: 1 },
  { id: "datos-reembolso", label: "Datos Reembolso", numero: 2 },
  { id: "solicitud", label: "Solicitud Servicio", numero: 3 },
  { id: "coberturas", label: "Coberturas", numero: 4 },
  { id: "confirmacion", label: "Confirmación", numero: 5 },
];
