export type SearchFilters = {
  fec_ini: string;
  fec_fin: string;
  cliente: string;
  oficial: string;
  gerente: string;
  intermediario: string;
};

export type TransactionRow = {
  id_transaccion: number;
  fec_tra: string;
  cliente: number;
  tipo_documento: string | null;
  num_documento: string | null;
  compania: number;
  ramo: number;
  secuencial: number;
  monto: number;
  estado: string;
  codigo_rechazo: string | null;
  descripcion_rechazo: string | null;
  respuesta_banco: string | null;
  num_autoriza: string | null;
  lote_id: number | null;
  oficial: number | null;
  gerente: number | null;
  intermediario: number | null;
  nombre_oficial: string | null;
  nombre_gerente: string | null;
  nombre_intermediario: string | null;
  nombre_director: string | null;
  grupo: string | null;
  user_crea: string | null;
  fecha_crea: string | null;
  user_actualiza: string | null;
  fecha_actualiza: string | null;
  telefono_1: string | null;
  telefono_2: string | null;
  telefono_3: string | null;
  cliente_poliza: string | null;
  estatus_poliza: string | null;
  frecuencia_pago: string | null;
  seleccion: "S" | "N";
};

export type SearchResult = {
  items: TransactionRow[];
  hasMore?: boolean;
  limit?: number;
  offset?: number;
};

export type LovItem = {
  codigo: number;
  nombre: string;
};

export type LovListResponse = {
  items?: LovItem[];
};

export type LookupResponse = {
  codigo: number;
  nombre: string;
};

export type SelectionResponse = {
  status: string;
  rows_affected: number;
  action: string;
};

export type ExportResponse = {
  status: string;
  report_type: string;
  message: string;
  selected_rows?: number;
  rows_in_range?: number;
  rows?: number;
  from_date?: string;
  to_date?: string;
  items?: TransactionRow[];
};
