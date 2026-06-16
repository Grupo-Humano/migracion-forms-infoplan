import { mockTransactions } from "../mockData";
import type {
  ExportResponse,
  LovItem,
  LookupResponse,
  SearchFilters,
  SelectionResponse,
  TransactionRow
} from "../types";

// Mock implementation for offline testing
export async function getOficial(codigo: string): Promise<LookupResponse> {
  if (!codigo.trim()) {
    throw new Error("Debe indicar codigo de oficial");
  }
  // Simulate network delay
  await new Promise((resolve) => setTimeout(resolve, 300));

  const oficiales: Record<string, string> = {
    "501": "Juan Perez",
    "502": "Maria Garcia",
    "503": "Luis Martinez",
    "504": "Rosa Sanchez"
  };

  const nombre = oficiales[codigo];
  if (!nombre) {
    throw new Error(`Oficial ${codigo} no encontrado`);
  }

  return { codigo: Number(codigo), nombre };
}

export async function searchTransacciones(
  filters: SearchFilters
): Promise<TransactionRow[]> {
  // Simulate network delay
  await new Promise((resolve) => setTimeout(resolve, 500));

  // Filter mock data by date range
  const filtered = mockTransactions.filter((row) => {
    if (filters.fec_ini && row.fec_tra < filters.fec_ini) return false;
    if (filters.fec_fin && row.fec_tra > filters.fec_fin) return false;

    if (filters.cliente && row.cliente !== Number(filters.cliente))
      return false;
    if (filters.oficial && row.oficial !== Number(filters.oficial))
      return false;
    if (filters.gerente && row.gerente !== Number(filters.gerente))
      return false;
    if (filters.intermediario && row.intermediario !== Number(filters.intermediario))
      return false;

    return true;
  });

  return filtered;
}

export async function marcarTodas(): Promise<SelectionResponse> {
  await new Promise((resolve) => setTimeout(resolve, 200));
  return {
    status: "success",
    rows_affected: mockTransactions.length,
    action: "marcar"
  };
}

export async function desmarcarTodas(): Promise<SelectionResponse> {
  await new Promise((resolve) => setTimeout(resolve, 200));
  return {
    status: "success",
    rows_affected: mockTransactions.length,
    action: "desmarcar"
  };
}

export async function exportOle(): Promise<ExportResponse> {
  await new Promise((resolve) => setTimeout(resolve, 800));
  return {
    status: "success",
    report_type: "OLE",
    message: "Export OLE simulado: archivo generado exitosamente",
    selected_rows: 3
  };
}

export async function exportJasper(
  fec_ini: string,
  fec_fin: string
): Promise<ExportResponse> {
  await new Promise((resolve) => setTimeout(resolve, 1000));
  return {
    status: "success",
    report_type: "JASPER",
    message: "Export Jasper simulado: reporte generado exitosamente",
    from_date: fec_ini,
    to_date: fec_fin,
    rows_in_range: 5
  };
}

export async function getGerentes(): Promise<LovItem[]> {
  await new Promise((resolve) => setTimeout(resolve, 150));
  return [
    { codigo: 301, nombre: "Gerente 301" },
    { codigo: 302, nombre: "Gerente 302" },
    { codigo: 303, nombre: "Gerente 303" }
  ];
}

export async function getIntermediarios(): Promise<LovItem[]> {
  await new Promise((resolve) => setTimeout(resolve, 150));
  return [
    { codigo: 401, nombre: "Intermediario 401" },
    { codigo: 402, nombre: "Intermediario 402" },
    { codigo: 403, nombre: "Intermediario 403" }
  ];
}
