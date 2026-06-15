import type {
  ExportResponse,
  LookupResponse,
  LovItem,
  LovListResponse,
  SearchResult,
  SearchFilters,
  SelectionResponse,
  TransactionRow
} from "../types";

const defaultBaseUrls = [
  "http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos",
  "http://localhost:8080/ords/infoplan/aprobaciones-rechazos"
];

const configuredBaseUrl = import.meta.env.VITE_ORDS_BASE_URL as string | undefined;

const baseUrls = [configuredBaseUrl, ...defaultBaseUrls]
  .filter((value): value is string => Boolean(value?.trim()))
  .map((value) => value.replace(/\/+$/, ""))
  .filter((value, index, values) => values.indexOf(value) === index);

const tokenUrl = import.meta.env.VITE_ORDS_TOKEN_URL as string | undefined;
const basicAuth = import.meta.env.VITE_ORDS_BASIC_AUTH as string | undefined;

function sanitizeJasperBaseUrl(rawUrl: string): string {
  try {
    const url = new URL(rawUrl);

    // Some environments carried a placeholder query like ?null=null.
    // Remove it to avoid polluting the report request contract.
    url.searchParams.delete("null");

    return url.toString();
  } catch {
    return rawUrl.replace(/\?null=null$/i, "");
  }
}

const jasperXmlBaseUrl =
  sanitizeJasperBaseUrl(
    (import.meta.env.VITE_JASPER_XML_BASE_URL as string | undefined) ??
      "http://172.24.208.208:31522/api/report"
  );
const jasperXmlCompania =
  (import.meta.env.VITE_JASPER_XML_COD_COMPANIA as string | undefined) ??
  "30";
const FETCH_TIMEOUT_MS = 12000;
const MAX_ERROR_DETAIL_CHARS = 280;

type TokenCache = {
  accessToken: string;
  expiresAt: number;
};

type EndpointProbeResult = {
  exists: boolean;
  reason: "not_found" | "unreachable";
};

type PolizaIntermediarioData = {
  compania?: number;
  ramo?: number;
  secuencial?: number;
  codGerente?: number;
  nombreGerente?: string;
  codSupervisor?: number;
  nombreSupervisor?: string;
  codInt?: number;
  frePag?: number;
};

type PolizaIntermediarioResponse = {
  data?: PolizaIntermediarioData;
};

type ClientePolizaItem = {
  compania?: number;
  ramo?: number;
  secuencial?: number;
  descripcionEstatus?: string;
};

type ClientePolizasResponse = {
  data?: {
    polizas?: ClientePolizaItem[];
  };
};

type FrecuenciaPagoItem = {
  codigo: number;
  description: string;
};

type FrecuenciasPagoResponse = {
  data?: FrecuenciaPagoItem[];
};

let tokenCache: TokenCache | null = null;
let tokenRefreshPromise: Promise<void> | null = null;

function toErrorMessage(err: unknown): string {
  if (err instanceof Error) {
    return err.message;
  }
  return String(err);
}

function formatHttpDetail(detail: string): string {
  const compact = detail.replace(/\s+/g, " ").trim();
  if (!compact) {
    return "";
  }

  // ORDS/Apache can return full HTML pages on 404/403; keep diagnostics readable.
  const withoutHtml = compact.replace(/<[^>]*>/g, "").trim();
  const safe = withoutHtml || compact;
  if (safe.length <= MAX_ERROR_DETAIL_CHARS) {
    return safe;
  }
  return `${safe.slice(0, MAX_ERROR_DETAIL_CHARS)}...`;
}

async function fetchWithTimeout(url: string, init: RequestInit): Promise<Response> {
  const controller = new AbortController();
  const timeoutId = globalThis.setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);

  try {
    return await fetch(url, {
      ...init,
      signal: controller.signal
    });
  } catch (err) {
    if (err instanceof Error && err.name === "AbortError") {
      throw new Error(`Timeout de ${FETCH_TIMEOUT_MS}ms`);
    }
    throw err;
  } finally {
    globalThis.clearTimeout(timeoutId);
  }
}

async function fetchFirstOk(
  paths: string[],
  init: RequestInit
): Promise<Response> {
  const attempts: string[] = [];
  let networkFailures = 0;

  for (const baseUrl of baseUrls) {
    for (const path of paths) {
      const endpoint = `${baseUrl}${path}`;
      try {
        const response = await fetchWithTimeout(endpoint, init);
        if (response.ok) {
          return response;
        }

        const detail = formatHttpDetail(await response.text());
        const suffix = detail ? `: ${detail}` : "";
        attempts.push(`${endpoint} -> HTTP ${response.status}${suffix}`);
      } catch (err) {
        networkFailures += 1;
        attempts.push(`${endpoint} -> NETWORK ${toErrorMessage(err)}`);
      }
    }
  }

  if (networkFailures === baseUrls.length * paths.length) {
    throw new Error(
      "ORDS no disponible en este momento. Verifique conectividad (VPN/red) e intente de nuevo."
    );
  }

  const firstAttempt = attempts[0] ?? "Error de servicio ORDS.";
  throw new Error(`Error de servicio ORDS. ${firstAttempt}`);
}

async function endpointExists(
  paths: string[],
  headers: Record<string, string>
): Promise<EndpointProbeResult> {
  let unreachableDetected = false;

  for (const baseUrl of baseUrls) {
    for (const path of paths) {
      try {
        const response = await fetchWithTimeout(`${baseUrl}${path}`, {
          method: "POST",
          headers: {
            ...headers,
            "Content-Type": "application/json"
          },
          // Probe payload: endpoint should reject invalid data with non-404 when it exists.
          body: JSON.stringify({})
        });

        if (response.status !== 404) {
          return {
            exists: true,
            reason: "not_found"
          };
        }
      } catch {
        // Ignore transport errors per path and continue with alternatives.
        unreachableDetected = true;
      }
    }
  }

  return {
    exists: false,
    reason: unreachableDetected ? "unreachable" : "not_found"
  };
}

async function getAuthHeaders(contentType?: string): Promise<Record<string, string>> {
  const headers: Record<string, string> = {};
  if (contentType) {
    headers["Content-Type"] = contentType;
  }

  // If OAuth env vars are not configured, keep previous behavior.
  if (!tokenUrl || !basicAuth) {
    return headers;
  }

  const now = Date.now();
  if (!tokenCache || now >= tokenCache.expiresAt - 30_000) {
    tokenRefreshPromise ??= (async () => {
      const response = await fetchWithTimeout(tokenUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          Authorization: `Basic ${basicAuth}`
        },
        body: new URLSearchParams({ grant_type: "client_credentials" })
      });

      const tokenPayload = await parseJson<{
        access_token: string;
        expires_in?: number;
      }>(response);

      tokenCache = {
        accessToken: tokenPayload.access_token,
        expiresAt: Date.now() + (tokenPayload.expires_in ?? 3600) * 1000
      };
    })().finally(() => {
      tokenRefreshPromise = null;
    });

    await tokenRefreshPromise;
  }

  headers.Authorization = `Bearer ${tokenCache.accessToken}`;
  return headers;
}

async function fetchAbsolutePath<T>(path: string): Promise<T> {
  const headers = await getAuthHeaders();
  const response = await fetchWithTimeout(path, { headers });
  return parseJson<T>(response);
}

function cleanNullableNumber(value: string): number | null {
  if (!value.trim()) {
    return null;
  }
  return Number(value);
}

function toJasperDate(dateText: string): string {
  const [year, month, day] = dateText.split("-").map(Number);
  if (!year || !month || !day) {
    throw new Error("Fecha invalida para generar Jasper real.");
  }

  const monthMap = [
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
  ];

  const dayText = String(day).padStart(2, "0");
  return `${dayText}-${monthMap[month - 1]}-${year}`;
}

export function buildXmlJasperUrl(filters: SearchFilters): string {
  if (!filters.fec_ini || !filters.fec_fin) {
    throw new Error("Debe completar fec_ini y fec_fin para exportar Jasper.");
  }

  const url = new URL(jasperXmlBaseUrl);
  const searchParams = url.searchParams;

  // XML legacy contract from P_JASPER_A_EXCEL
  searchParams.set("name", "rep_aprobaciones_rechazos");
  searchParams.set("documentType", "XLS");
  searchParams.set("PCODIGO_COMPANIA", jasperXmlCompania);
  searchParams.set("PDESDE", toJasperDate(filters.fec_ini));
  searchParams.set("PHAS", toJasperDate(filters.fec_fin));
  
  // Jasper behavior: OMIT optional filters when not set.
  // When filters are empty, Jasper expects the parameter to NOT exist in the URL.
  // Only include them if they have a value.
  const oficial = filters.oficial?.trim();
  if (oficial) {
    searchParams.set("POFICIAL", oficial);
  }
  
  const gerente = filters.gerente?.trim();
  if (gerente) {
    searchParams.set("PGERENTE", gerente);
  }
  
  const intermediario = filters.intermediario?.trim();
  if (intermediario) {
    searchParams.set("PINTERMEDIARIO", intermediario);
  }

  return url.toString();
}

export async function exportJasper(
  fec_ini: string,
  fec_fin: string
): Promise<ExportResponse | null> {
  const headers = await getAuthHeaders("application/json");

  try {
    const response = await fetchFirstOk(
      ["/exportaciones/jasper"],
      {
        method: "POST",
        headers,
        body: JSON.stringify({ fec_ini, fec_fin })
      }
    );

    return parseJson<ExportResponse>(response);
  } catch (err) {
    const message = toErrorMessage(err).toLowerCase();

    // Legacy-compatible fallback: if ORDS export handler is not published,
    // use direct Jasper URL launch flow.
    if (message.includes("http 404")) {
      return null;
    }

    throw err;
  }
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
  const headers = await getAuthHeaders();
  const response = await fetchFirstOk(
    [`/oficiales/${codigo}`, `/oficial/${codigo}`],
    { headers }
  );
  return parseJson<LookupResponse>(response);
}

export async function searchTransacciones(
  filters: SearchFilters,
  pageOptions?: { offset?: number; limit?: number }
): Promise<SearchResult> {
  const body = {
    fec_ini: filters.fec_ini,
    fec_fin: filters.fec_fin,
    cliente: cleanNullableNumber(filters.cliente),
    oficial: cleanNullableNumber(filters.oficial),
    gerente: cleanNullableNumber(filters.gerente),
    intermediario: cleanNullableNumber(filters.intermediario),
    offset: pageOptions?.offset,
    limit: pageOptions?.limit
  };

  // Use pg_offset/pg_limit to avoid collisions with ORDS-reserved :offset/:limit
  // in json/collection POST handlers — ORDS ignores native ?offset= for POST.
  const paginationParams = new URLSearchParams();
  if (typeof pageOptions?.offset === "number") {
    paginationParams.set("pg_offset", String(pageOptions.offset));
  }
  if (typeof pageOptions?.limit === "number") {
    paginationParams.set("pg_limit", String(pageOptions.limit));
  }
  const paginationSuffix = paginationParams.toString()
    ? `?${paginationParams.toString()}`
    : "";

  const headers = await getAuthHeaders("application/json");
  const response = await fetchFirstOk(
    [`/transacciones/search${paginationSuffix}`, `/search${paginationSuffix}`],
    {
      method: "POST",
      headers,
      body: JSON.stringify(body)
    }
  );

  const payload = await parseJson<
    { items?: TransactionRow[]; hasMore?: boolean; limit?: number; offset?: number } | TransactionRow[]
  >(
    response
  );

  if (Array.isArray(payload)) {
    return {
      items: payload,
      hasMore: false,
      limit: payload.length,
      offset: 0
    };
  }

  return {
    items: payload.items ?? [],
    hasMore: payload.hasMore,
    limit: payload.limit,
    offset: payload.offset
  };
}

export async function marcarTodas(): Promise<SelectionResponse> {
  const headers = await getAuthHeaders();
  const response = await fetchFirstOk(
    ["/transacciones/seleccion/M", "/seleccion/M"],
    {
      method: "POST",
      headers
    }
  );
  return parseJson<SelectionResponse>(response);
}

export async function desmarcarTodas(): Promise<SelectionResponse> {
  const headers = await getAuthHeaders();
  const response = await fetchFirstOk(
    ["/transacciones/seleccion/D", "/seleccion/D"],
    {
      method: "POST",
      headers
    }
  );
  return parseJson<SelectionResponse>(response);
}

export async function exportOle(): Promise<ExportResponse> {
  const headers = await getAuthHeaders();
  const response = await fetchFirstOk(
    ["/exportaciones/ole", "/export/ole"],
    {
      method: "POST",
      headers
    }
  );
  return parseJson<ExportResponse>(response);
}

export async function hasJasperExport(): Promise<boolean> {
  const availability = await getJasperAvailability();
  return availability.available;
}

export async function getJasperAvailability(): Promise<{
  available: boolean;
  reason: "not_found" | "unreachable";
}> {
  const headers = await getAuthHeaders();
  const result = await endpointExists(["/exportaciones/jasper", "/export/jasper"], headers);
  return {
    available: result.exists,
    reason: result.reason
  };
}

async function fetchLovList(path: string): Promise<LovItem[]> {
  const headers = await getAuthHeaders();
  const attempts: string[] = [];

  for (const baseUrl of baseUrls) {
    try {
      const response = await fetchWithTimeout(`${baseUrl}/${path}`, { headers });
      if (response.ok) {
        const payload = (await response.json()) as LovListResponse | LovItem[];
        if (Array.isArray(payload)) return payload;
        return payload.items ?? [];
      }

      const detail = formatHttpDetail(await response.text());
      const suffix = detail ? `: ${detail}` : "";
      attempts.push(`${baseUrl}/${path} -> HTTP ${response.status}${suffix}`);
    } catch (err) {
      attempts.push(`${baseUrl}/${path} -> NETWORK ${toErrorMessage(err)}`);
    }
  }

  throw new Error(attempts.join(" | "));
}

export async function getGerentes(): Promise<LovItem[]> {
  return fetchLovList("gerentes");
}

export async function getIntermediarios(): Promise<LovItem[]> {
  return fetchLovList("intermediarios");
}

export async function getPolizaIntermediario(
  compania: number,
  ramo: number,
  secuencial: number
): Promise<PolizaIntermediarioData | null> {
  const query = new URLSearchParams({
    compania: String(compania),
    ramo: String(ramo),
    secuencial: String(secuencial)
  });

  const payload = await fetchAbsolutePath<PolizaIntermediarioResponse>(
    `/ords/infoplan/api/v1/gestion-poliza/poliza-intermediario?${query.toString()}`
  );

  return payload.data ?? null;
}

export async function getClientePolizas(cliente: number): Promise<ClientePolizaItem[]> {
  const payload = await fetchAbsolutePath<ClientePolizasResponse>(
    `/ords/infoplan/api/v1/clientes-polizas/${cliente}/polizas?pagina=1&tamanio=200`
  );

  return payload.data?.polizas ?? [];
}

export async function getFrecuenciasPago(): Promise<FrecuenciaPagoItem[]> {
  const payload = await fetchAbsolutePath<FrecuenciasPagoResponse>(
    "/ords/infoplan/api/v1/gestion-poliza/catalogo/frecuenciasPagos"
  );

  return payload.data ?? [];
}
