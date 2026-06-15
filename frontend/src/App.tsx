import { useMemo, useState } from "react";
import * as ordsClient from "./api/ordsClient";
import { FiltersPanel } from "./components/FiltersPanel";
import { ResultsTable } from "./components/ResultsTable";
import type { SearchFilters, TransactionRow } from "./types";

// Force real ORDS client (no mock mode)
const apiClient = ordsClient;

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

  const dateCrossError = getDateCrossError(filters);

  const canExportJasper = useMemo(
    () => Boolean(filters.fec_ini && filters.fec_fin),
    [filters.fec_fin, filters.fec_ini]
  );

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
      const found = await apiClient.searchTransacciones(filters);
      setRows(found);
      setMessage(`Busqueda completada: ${found.length} registros. (ORDS real)`);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setLoading(false);
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

  const runMarcar = async () => {
    setError("");
    setMessage("");
    try {
      const result = await apiClient.marcarTodas();
      setRows((prev) => prev.map((row) => ({ ...row, seleccion: "S" })));
      setMessage(`Marcado global aplicado. Filas afectadas: ${result.rows_affected}`);
    } catch (err) {
      setError((err as Error).message);
    }
  };

  const runDesmarcar = async () => {
    setError("");
    setMessage("");
    try {
      const result = await apiClient.desmarcarTodas();
      setRows((prev) => prev.map((row) => ({ ...row, seleccion: "N" })));
      setMessage(
        `Desmarcado global aplicado. Filas afectadas: ${result.rows_affected}`
      );
    } catch (err) {
      setError((err as Error).message);
    }
  };

  const runExportOle = async () => {
    setError("");
    setMessage("");
    try {
      const payload = await apiClient.exportOle();
      setMessage(
        `Export OLE: ${payload.message} (${payload.selected_rows ?? 0} seleccionadas)`
      );
    } catch (err) {
      setError((err as Error).message);
    }
  };

  const runExportJasper = async () => {
    setError("");
    setMessage("");
    if (!canExportJasper) {
      setError("Debe completar fec_ini y fec_fin para exportar Jasper.");
      return;
    }
    try {
      const payload = await apiClient.exportJasper(filters.fec_ini, filters.fec_fin);
      setMessage(
        `Export Jasper: ${payload.message} (${payload.from_date} a ${payload.to_date})`
      );
    } catch (err) {
      setError((err as Error).message);
    }
  };

  return (
    <main className="page">
      <header>
        <h1>Consulta de Aprobaciones y Rechazos</h1>
        <p>Migracion Oracle Forms → React + ORDS</p>
      </header>

      <FiltersPanel
        filters={filters}
        onChange={setFilters}
        onSearch={runSearch}
        onLoadOficial={runLoadOficial}
        searching={loading}
        dateCrossError={dateCrossError}
      />

      <section className="panel status-panel">
        {dateCrossError && <p className="error">{dateCrossError}</p>}
        {message ? <p className="ok">{message}</p> : null}
        {error ? <p className="error">{error}</p> : null}
        {loading ? <p className="loading">Consultando...</p> : null}
        {oficialName && <p><strong>Oficial:</strong> {oficialName}</p>}
      </section>

      <section className="panel actions-grid">
        <button type="button" onClick={runMarcar}>
          Marcar todas
        </button>
        <button type="button" onClick={runDesmarcar}>
          Desmarcar todas
        </button>
        <button type="button" onClick={runExportOle}>
          Exportar OLE
        </button>
        <button type="button" onClick={runExportJasper} disabled={!canExportJasper}>
          Exportar Jasper
        </button>
      </section>

      <ResultsTable rows={rows} />
    </main>
  );
}
