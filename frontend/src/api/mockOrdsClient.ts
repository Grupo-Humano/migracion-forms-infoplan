import { mockTransactions } from "../mockData";
import type {
  ExportResponse,
  LovItem,
  LookupResponse,
  SearchFilters,
  SearchResult,
  SelectionResponse
} from "../types";

const MOCK_DELAY = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const MOCK_OFICIALES: Record<string, string> = {
  "501": "Juan Perez",
  "502": "Maria Garcia",
  "503": "Luis Martinez",
  "504": "Rosa Sanchez"
};

const MOCK_GERENTES: LovItem[] = [
  { codigo: 301, nombre: "Ana Fernandez" },
  { codigo: 302, nombre: "Roberto Diaz" },
  { codigo: 303, nombre: "Carmen Herrera" },
  { codigo: 304, nombre: "Luis Valdez" }
];

const MOCK_INTERMEDIARIOS: LovItem[] = [
  { codigo: 401, nombre: "Seguros del Norte S.A." },
  { codigo: 402, nombre: "Grupo Asegurador Central" },
  { codigo: 403, nombre: "Asesores del Este S.R.L." },
  { codigo: 404, nombre: "Cobertura Total RD" }
];

export async function getOficial(codigo: string): Promise<LookupResponse> {
  if (!codigo.trim()) {
    throw new Error("Debe indicar codigo de oficial");
  }
  await MOCK_DELAY(300);
  const nombre = MOCK_OFICIALES[codigo];
  if (!nombre) {
    throw new Error(`Oficial ${codigo} no encontrado`);
  }
  return { codigo: Number(codigo), nombre };
}

export async function searchTransacciones(
  filters: SearchFilters,
  _pageOptions?: { offset?: number; limit?: number }
): Promise<SearchResult> {
  await MOCK_DELAY(500);

  const filtered = mockTransactions.filter((row) => {
    if (filters.fec_ini && row.fec_tra < filters.fec_ini) return false;
    if (filters.fec_fin && row.fec_tra > filters.fec_fin) return false;
    if (filters.cliente && row.cliente !== Number(filters.cliente)) return false;
    if (filters.oficial && row.oficial !== Number(filters.oficial)) return false;
    if (filters.gerente && row.gerente !== Number(filters.gerente)) return false;
    if (filters.intermediario && row.intermediario !== Number(filters.intermediario)) return false;
    return true;
  });

  return {
    items: filtered,
    hasMore: false,
    limit: filtered.length,
    offset: 0
  };
}

export async function marcarTodas(): Promise<SelectionResponse> {
  await MOCK_DELAY(200);
  return { status: "success", rows_affected: mockTransactions.length, action: "marcar" };
}

export async function desmarcarTodas(): Promise<SelectionResponse> {
  await MOCK_DELAY(200);
  return { status: "success", rows_affected: mockTransactions.length, action: "desmarcar" };
}

export async function exportOle(): Promise<ExportResponse> {
  await MOCK_DELAY(800);
  return {
    status: "success",
    report_type: "OLE",
    message: "[DEMO] Export OLE simulado: archivo generado exitosamente",
    selected_rows: 3
  };
}

export async function exportJasper(
  fec_ini: string,
  fec_fin: string
): Promise<ExportResponse> {
  await MOCK_DELAY(1000);
  return {
    status: "success",
    report_type: "JASPER",
    message: "[DEMO] Export Jasper simulado: reporte generado exitosamente",
    from_date: fec_ini,
    to_date: fec_fin,
    rows_in_range: 5
  };
}

export function buildXmlJasperUrl(filters: SearchFilters): string {
  return `#demo-jasper?fec_ini=${filters.fec_ini}&fec_fin=${filters.fec_fin}`;
}

export async function hasJasperExport(): Promise<boolean> {
  return true;
}

export async function getJasperAvailability(): Promise<{
  available: boolean;
  reason: "not_found" | "unreachable";
}> {
  return { available: true, reason: "not_found" };
}

export async function getGerentes(): Promise<LovItem[]> {
  await MOCK_DELAY(150);
  return MOCK_GERENTES;
}

export async function getIntermediarios(): Promise<LovItem[]> {
  await MOCK_DELAY(150);
  return MOCK_INTERMEDIARIOS;
}

export async function getPolizaIntermediario(
  _compania: number,
  _ramo: number,
  _secuencial: number
): Promise<null> {
  await MOCK_DELAY(100);
  return null;
}

export async function getClientePolizas(_cliente: number): Promise<[]> {
  await MOCK_DELAY(100);
  return [];
}

export async function getFrecuenciasPago(): Promise<
  Array<{ codigo: number; description: string }>
> {
  await MOCK_DELAY(100);
  return [
    { codigo: 1, description: "MENSUAL" },
    { codigo: 3, description: "TRIMESTRAL" },
    { codigo: 6, description: "SEMESTRAL" },
    { codigo: 12, description: "ANUAL" }
  ];
}
