import { useEffect, useMemo, useState } from "react";
import * as ordsClient from "./api/ordsClient";
import { FiltersPanel } from "./components/FiltersPanel";
import { ResultsTable } from "./components/ResultsTable";
import type { LovItem, SearchFilters, TransactionRow } from "./types";

const apiClient = ordsClient;
const DEFAULT_PAGE_SIZE = 100;

type LoadMoreResult = {
  loaded: number;
  exhausted: boolean;
  failed: boolean;
  duplicated: boolean;
};

type LoadMoreOptions = {
  suppressUiError?: boolean;
};

const initialFilters: SearchFilters = {
  fec_ini: "",
  fec_fin: "",
  cliente: "",
  oficial: "",
  gerente: "",
  intermediario: ""
};

function validateFilters(filters: SearchFilters): string | null {
  if (!filters.fec_ini || !filters.fec_fin) {
    return "Dato Fecha es requerido para poder ejecutar la busqueda.";
  }
  if (filters.fec_ini > filters.fec_fin) {
    return "Fecha Desde no puede ser mayor que Fecha Hasta, favor verificar..!";
  }
  return null;
}

function getDateCrossError(filters: SearchFilters): string {
  if (filters.fec_ini && filters.fec_fin && filters.fec_ini > filters.fec_fin) {
    return "Fecha Desde no puede ser mayor que Fecha Hasta, favor verificar..!";
  }
  return "";
}

export default function App() {
  const [filters, setFilters] = useState<SearchFilters>(initialFilters);
  const [rows, setRows] = useState<TransactionRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string>("");
  const [error, setError] = useState<string>("");
  const [oficialName, setOficialName] = useState<string>("");
  const [gerentes, setGerentes] = useState<LovItem[]>([]);
  const [intermediarios, setIntermediarios] = useState<LovItem[]>([]);
  const [page, setPage] = useState(1);
  const [viewPage, setViewPage] = useState(1);
  const [pageJumpInput, setPageJumpInput] = useState("1");
  const [pageSize, setPageSize] = useState(DEFAULT_PAGE_SIZE);
  const [hasMoreServerRows, setHasMoreServerRows] = useState(false);
  const [serverLimit, setServerLimit] = useState<number | null>(null);
  const [serverOffset, setServerOffset] = useState<number | null>(null);
  const [serverPagingBusy, setServerPagingBusy] = useState(false);

  // Load LOV lists on mount
  useEffect(() => {
    apiClient.getGerentes().then(setGerentes).catch(() => setGerentes([]));
    apiClient.getIntermediarios().then(setIntermediarios).catch(() => setIntermediarios([]));
  }, []);

  const dateCrossError = getDateCrossError(filters);

  const canExportJasper = useMemo(
    () => Boolean(filters.fec_ini && filters.fec_fin && !dateCrossError),
    [dateCrossError, filters.fec_fin, filters.fec_ini]
  );

  const totalViewPages = useMemo(() => {
    if (rows.length === 0) {
      return 1;
    }
    return Math.ceil(rows.length / pageSize);
  }, [rows.length, pageSize]);

  const visibleRows = useMemo(() => {
    const start = (viewPage - 1) * pageSize;
    return rows.slice(start, start + pageSize);
  }, [rows, viewPage, pageSize]);

  useEffect(() => {
    if (viewPage > totalViewPages) {
      setViewPage(totalViewPages);
      setPageJumpInput(String(totalViewPages));
    }
  }, [totalViewPages, viewPage]);

  const runSearch = async () => {
    setError("");
    setMessage("");

    const validationError = validateFilters(filters);
    if (validationError) {
      setError(validationError);
      return;
    }

    setLoading(true);
    try {
      const result = await apiClient.searchTransacciones(filters, {
        offset: 0,
        limit: pageSize
      });
      setRows(result.items);
      setPage(1);
      setViewPage(1);
      setPageJumpInput("1");
      // When ORDS json/collection uses SQL-level ROW_NUMBER pagination it cannot
      // report hasMore reliably. Fall back to: if we received a full page, assume more.
      // Use pageSize as authoritative chunk size; ORDS metadata limit can be stale.
      const effectiveLimit = pageSize;
      const likelyMoreRows =
        typeof result.hasMore === "boolean" && result.hasMore
          ? true
          : result.items.length >= effectiveLimit;
      setHasMoreServerRows(likelyMoreRows);
      setServerLimit(pageSize);
      setServerOffset(result.offset ?? null);
      const paginationNote = likelyMoreRows
        ? " Navegue con Siguiente pagina para cargar mas resultados bajo demanda."
        : "";
      setMessage(
        `Busqueda completada: ${result.items.length} registros cargados. (ORDS real)${paginationNote}`
      );
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setLoading(false);
    }
  };

  const runLoadMoreServerRows = async (
    options?: LoadMoreOptions
  ): Promise<LoadMoreResult> => {
    setError("");
    setMessage("");

    if (!hasMoreServerRows || serverPagingBusy) {
      return {
        loaded: 0,
        exhausted: !hasMoreServerRows,
        failed: false,
        duplicated: false
      };
    }

    setServerPagingBusy(true);
    try {
      const currentChunkSize = serverLimit ?? (rows.length || DEFAULT_PAGE_SIZE);
      const nextOffset = (serverOffset ?? 0) + currentChunkSize;
      let pageOffsetUsed = nextOffset;
      let result = await apiClient.searchTransacciones(filters, {
        offset: nextOffset,
        limit: serverLimit ?? pageSize
      });

      if (result.items.length === 0) {
        setHasMoreServerRows(false);
        setMessage("El servicio no devolvio mas registros.");
        return {
          loaded: 0,
          exhausted: true,
          failed: false,
          duplicated: false
        };
      }

      const existingIds = new Set(rows.map((row) => row.id_transaccion));
      const uniqueIncoming = result.items.filter(
        (row) => !existingIds.has(row.id_transaccion)
      );

      let finalIncoming = uniqueIncoming;
      if (finalIncoming.length === 0) {
        // Fallback for endpoints that apply one-based offset semantics.
        const oneBasedOffset = nextOffset + 1;
        const retryResult = await apiClient.searchTransacciones(filters, {
          offset: oneBasedOffset,
          limit: serverLimit ?? pageSize
        });

        const retryIncoming = retryResult.items.filter(
          (row) => !existingIds.has(row.id_transaccion)
        );

        if (retryIncoming.length > 0) {
          result = retryResult;
          pageOffsetUsed = oneBasedOffset;
          finalIncoming = retryIncoming;
        }
      }

      if (finalIncoming.length === 0) {
        if (!options?.suppressUiError) {
          setError(
            `El servicio devolvio la misma pagina (offset=${serverOffset ?? 0}, limit=${serverLimit ?? pageSize}). Revise paginacion ORDS.`
          );
        }
        return {
          loaded: 0,
          exhausted: false,
          failed: false,
          duplicated: true
        };
      }

      setRows((prev) => [...prev, ...finalIncoming]);
      setMessage(
        `Se cargaron ${finalIncoming.length} registros adicionales desde ORDS. Total acumulado: ${rows.length + finalIncoming.length}.`
      );

      const nextLimit = result.limit ?? serverLimit ?? pageSize;
      const moreFromServer =
        typeof result.hasMore === "boolean"
          ? result.hasMore
          : finalIncoming.length >= nextLimit;

      setHasMoreServerRows(moreFromServer);
      setServerLimit(nextLimit);
      // Keep offset progression deterministic even when ORDS metadata returns stale offset=0.
      setServerOffset(pageOffsetUsed);
      return {
        loaded: finalIncoming.length,
        exhausted: !moreFromServer,
        failed: false,
        duplicated: false
      };
    } catch (err) {
      setError((err as Error).message);
      return {
        loaded: 0,
        exhausted: false,
        failed: true,
        duplicated: false
      };
    } finally {
      setServerPagingBusy(false);
    }
  };

  const runLoadOficial = async () => {
    setError("");
    setMessage("");
    try {
      const result = await apiClient.getOficial(filters.oficial);
      setOficialName(result.nombre);
      setMessage(`Oficial cargado: ${result.nombre}`);
    } catch (err) {
      setOficialName("");
      setError((err as Error).message);
    }
  };

  const runExportJasper = async () => {
    setError("");
    setMessage("");

    if (!filters.fec_ini || !filters.fec_fin) {
      setError("Debe selecionar las fechas o periodos correspondientes para poder generar el reporte, favor verificar..!");
      return;
    }

    if (dateCrossError) {
      setError(dateCrossError);
      return;
    }

    const confirmed = globalThis.confirm(
      "Seguro de generar los datos en la fecha seleccionada?"
    );
    if (!confirmed) {
      setMessage("Proceso cancelado.");
      return;
    }

    if (!canExportJasper) {
      setError("Debe completar fec_ini y fec_fin para exportar Jasper.");
      return;
    }

    try {
      const jasperUrl = apiClient.buildXmlJasperUrl(filters);
      const popup = globalThis.open(jasperUrl, "_blank", "noopener,noreferrer");

      if (!popup) {
        setError("El navegador bloqueo la ventana emergente de Jasper. Permita popups e intente de nuevo.");
        return;
      }

      setMessage(
        `Export Jasper lanzado (${filters.fec_ini} a ${filters.fec_fin}).`
      );
    } catch (err) {
      setError((err as Error).message);
    }
  };

  const toggleRowSelection = (idTransaccion: number, selected: boolean) => {
    setRows((prev) =>
      prev.map((row) =>
        row.id_transaccion === idTransaccion
          ? { ...row, seleccion: selected ? "S" : "N" }
          : row
      )
    );
  };

  const gotoPreviousViewPage = () => {
    setViewPage((prev) => Math.max(1, prev - 1));
    setPageJumpInput(String(Math.max(1, viewPage - 1)));
  };

  const gotoNextViewPage = async () => {
    if (viewPage < totalViewPages) {
      const nextView = Math.min(totalViewPages, viewPage + 1);
      setViewPage(nextView);
      setPageJumpInput(String(nextView));
      return;
    }

    if (!hasMoreServerRows || serverPagingBusy || loading) {
      return;
    }

    const result = await runLoadMoreServerRows({ suppressUiError: true });
    if (result.loaded <= 0) {
      if (result.failed) {
        setMessage("No se pudieron cargar mas registros por indisponibilidad de ORDS.");
      }
      if (result.duplicated) {
        setMessage("No se pudieron cargar mas registros porque el servicio repitio la misma pagina.");
      }
      return;
    }

    setPage((prev) => prev + 1);
    const nextView = viewPage + 1;
    setViewPage(nextView);
    setPageJumpInput(String(nextView));
  };

  const jumpToViewPage = () => {
    const requestedPage = Number(pageJumpInput);
    if (!Number.isFinite(requestedPage)) {
      return;
    }
    const clamped = Math.max(1, Math.min(totalViewPages, Math.trunc(requestedPage)));
    setViewPage(clamped);
    setPageJumpInput(String(clamped));
  };

  const changePageSize = (value: string) => {
    const nextSize = Number(value);
    if (!Number.isFinite(nextSize) || nextSize <= 0) {
      return;
    }
    setPageSize(nextSize);
    setPage(1);
    setViewPage(1);
    setPageJumpInput("1");
  };

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <div className="brand-mark">I</div>
          <div>
            <p className="brand-title">Infoplan</p>
            <p className="brand-subtitle">Portal de Aplicaciones</p>
          </div>
        </div>

        <nav className="side-nav" aria-label="Navegacion principal">
          <button type="button" className="side-link active">Inicio</button>
          <button type="button" className="side-link">Mi Perfil</button>
        </nav>

        <button type="button" className="side-logout">Cerrar Sesion</button>
      </aside>

      <div className="content-shell">
        <header className="topbar">
          <p className="topbar-title">Inicio</p>
          <div className="topbar-user">
            <div>
              <p className="topbar-name">Cesar Ricardo</p>
              <p className="topbar-mail">cericardo@humano.com.do</p>
            </div>
            <span className="topbar-avatar">CR</span>
          </div>
        </header>

        <main className="page">
          <section className="hero-card">
            <div>
              <h1>Consulta de Aprobaciones y Rechazos</h1>
              <p>Migracion Oracle Forms → React + ORDS</p>
            </div>
            <div className="hero-chip">Facturacion</div>
          </section>

          <FiltersPanel
            filters={filters}
            onChange={setFilters}
            onSearch={runSearch}
            onLoadOficial={runLoadOficial}
            searching={loading || serverPagingBusy}
            dateCrossError={dateCrossError}
            gerentes={gerentes}
            intermediarios={intermediarios}
          />

          <section className="panel status-panel">
            {dateCrossError && <p className="error">{dateCrossError}</p>}
            {message ? <p className="ok">{message}</p> : null}
            {error ? <p className="error">{error}</p> : null}
            {loading ? <p className="loading">Consultando...</p> : null}
            {oficialName && <p><strong>Oficial:</strong> {oficialName}</p>}
          </section>

          <section className="panel actions-grid">
            <button
              type="button"
              onClick={runExportJasper}
              disabled={!canExportJasper || loading || serverPagingBusy}
            >
              Exportar Jasper
            </button>
          </section>

          <section className="panel pagination-panel" aria-label="Paginacion resultados">
            <div className="pagination-left">
              <strong>Bloques cargados: {page}</strong>
              <span>Paginas de vista: {viewPage} de {totalViewPages}</span>
              <span>
                Registros acumulados: {rows.length}
                {hasMoreServerRows
                  ? " (hay mas filas disponibles; use Siguiente pagina)"
                  : " (sin mas filas por cargar)"}
              </span>
              <span>
                Nota: la grilla pagina localmente y carga mas filas solo cuando el usuario avanza.
              </span>
              {serverLimit !== null && (
                <span>
                  Respuesta ORDS: chunk={serverLimit}, ultimo offset={serverOffset ?? 0}
                </span>
              )}
            </div>
            <div className="pagination-right">
              <label>
                <span>Filas por carga</span>
                <select value={String(pageSize)} onChange={(e) => changePageSize(e.target.value)}>
                  <option value="10">10</option>
                  <option value="25">25</option>
                  <option value="50">50</option>
                  <option value="100">100</option>
                </select>
              </label>
              <button
                type="button"
                onClick={gotoPreviousViewPage}
                disabled={viewPage <= 1}
              >
                Anterior pagina
              </button>
              <button
                type="button"
                onClick={gotoNextViewPage}
                disabled={serverPagingBusy || loading || (!hasMoreServerRows && viewPage >= totalViewPages)}
              >
                Siguiente pagina
              </button>
              <label>
                <span>Ir a pagina</span>
                <input
                  type="number"
                  min={1}
                  max={totalViewPages}
                  value={pageJumpInput}
                  onChange={(e) => setPageJumpInput(e.target.value)}
                />
              </label>
              <button
                type="button"
                onClick={jumpToViewPage}
                disabled={rows.length === 0}
              >
                Ir
              </button>
            </div>
          </section>

          <ResultsTable
            rows={visibleRows}
            onToggleSelection={toggleRowSelection}
            rowNumberStart={(viewPage - 1) * pageSize + 1}
          />
        </main>
      </div>
    </div>
  );
}
