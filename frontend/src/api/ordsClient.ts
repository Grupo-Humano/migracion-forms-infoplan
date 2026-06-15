import type {
  ExportResponse,
  LookupResponse,
  LovItem,
  LovListResponse,
  SearchFilters,
  SelectionResponse,
  TransactionRow
} from "../types";

const baseUrl =
  import.meta.env.VITE_ORDS_BASE_URL ??
  "http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos";

function cleanNullableNumber(value: string): number | null {
  if (!value.trim()) {
    return null;
  }
  return Number(value);
}

async function parseJson<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(errorBody || `HTTP ${response.status}`);
  }
  return (await response.json()) as T;
}

export async function getOficial(codigo: string): Promise<LookupResponse> {
  if (!codigo.trim()) {
    throw new Error("Debe indicar codigo de oficial");
  }
  const response = await fetch(`${baseUrl}/oficiales/${codigo}`);
  return parseJson<LookupResponse>(response);
}

export async function searchTransacciones(
  filters: SearchFilters
): Promise<TransactionRow[]> {
  const body = {
    fec_ini: filters.fec_ini,
    fec_fin: filters.fec_fin,
    cliente: cleanNullableNumber(filters.cliente),
    oficial: cleanNullableNumber(filters.oficial),
    gerente: cleanNullableNumber(filters.gerente),
    intermediario: cleanNullableNumber(filters.intermediario)
  };

  const response = await fetch(`${baseUrl}/transacciones/search`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });

  const payload = await parseJson<{ items?: TransactionRow[] } | TransactionRow[]>(
    response
  );

  if (Array.isArray(payload)) {
    return payload;
  }

  return payload.items ?? [];
}

export async function marcarTodas(): Promise<SelectionResponse> {
  const response = await fetch(`${baseUrl}/transacciones/seleccion/M`, { method: "POST" });
  return parseJson<SelectionResponse>(response);
}

export async function desmarcarTodas(): Promise<SelectionResponse> {
  const response = await fetch(`${baseUrl}/transacciones/seleccion/D`, { method: "POST" });
  return parseJson<SelectionResponse>(response);
}

export async function exportOle(): Promise<ExportResponse> {
  const response = await fetch(`${baseUrl}/exportaciones/ole`, { method: "POST" });
  return parseJson<ExportResponse>(response);
}

export async function exportJasper(
  fec_ini: string,
  fec_fin: string
): Promise<ExportResponse> {
  const response = await fetch(`${baseUrl}/exportaciones/jasper`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ fec_ini, fec_fin })
  });

  return parseJson<ExportResponse>(response);
}

async function fetchLovList(path: string): Promise<LovItem[]> {
  const response = await fetch(`${baseUrl}/${path}`);
  const payload = await parseJson<LovListResponse | LovItem[]>(response);
  if (Array.isArray(payload)) return payload;
  return payload.items ?? [];
}

export async function getGerentes(): Promise<LovItem[]> {
  return fetchLovList("gerentes");
}

export async function getIntermediarios(): Promise<LovItem[]> {
  return fetchLovList("intermediarios");
}
