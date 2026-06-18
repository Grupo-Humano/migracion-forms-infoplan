// BusquedaAfiliado — Paso 1 del flujo reemb_pago
// Nova (Frontend) | Sprint 6 T-01
// Contrato v1: busqueda por AFILIADO | CARNET | DOCUMENTO | NOMBRE

import { useState } from "react";
import type { AfiliadoItem, CriterioBusqueda } from "../../types-reemb-pago";
import { buscarAfiliados } from "../../mock-afiliados";

type Props = {
  onSeleccionar: (afiliado: AfiliadoItem) => void;
};

const CRITERIOS: { value: CriterioBusqueda; label: string; placeholder: string }[] = [
  { value: "NOMBRE", label: "Nombre", placeholder: "Ej: María Elena..." },
  { value: "DOCUMENTO", label: "Documento / Cédula", placeholder: "Ej: 001002345..." },
  { value: "CARNET", label: "N° Carnet", placeholder: "Ej: C-2024-001" },
  { value: "AFILIADO", label: "ID Afiliado", placeholder: "Ej: AF-00123" },
];

const ESTADO_COLORS: Record<string, string> = {
  ACTIVO: "#8ce99a",
  INACTIVO: "#adc0e4",
  SUSPENDIDO: "#f97373",
};

export function BusquedaAfiliado({ onSeleccionar }: Readonly<Props>) {
  const [criterio, setCriterio] = useState<CriterioBusqueda>("NOMBRE");
  const [valor, setValor] = useState("");
  const [resultados, setResultados] = useState<AfiliadoItem[] | null>(null);
  const [buscando, setBuscando] = useState(false);
  const [afiliadoSeleccionado, setAfiliadoSeleccionado] = useState<string | null>(null);

  const placeholderActual =
    CRITERIOS.find((c) => c.value === criterio)?.placeholder ?? "";

  function handleBuscar() {
    if (!valor.trim()) return;
    setBuscando(true);
    setResultados(null);
    setAfiliadoSeleccionado(null);

    // Simula latencia de red para el demo
    setTimeout(() => {
      const items = buscarAfiliados(criterio, valor);
      setResultados(items);
      setBuscando(false);
    }, 600);
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter") handleBuscar();
  }

  function handleSeleccionar(afiliado: AfiliadoItem) {
    setAfiliadoSeleccionado(afiliado.idAfiliado);
    // Pequeño delay visual antes de avanzar
    setTimeout(() => onSeleccionar(afiliado), 300);
  }

  return (
    <div style={{ display: "grid", gap: 14 }}>
      {/* Panel de búsqueda */}
      <section className="panel">
        <h2>Buscar Afiliado</h2>
        <div className="grid" style={{ gridTemplateColumns: "220px 1fr auto" }}>
          <label>
            <span>Buscar por</span>
            <select
              value={criterio}
              onChange={(e) => {
                setCriterio(e.target.value as CriterioBusqueda);
                setValor("");
                setResultados(null);
              }}
            >
              {CRITERIOS.map((c) => (
                <option key={c.value} value={c.value}>
                  {c.label}
                </option>
              ))}
            </select>
          </label>

          <label>
            <span>
              Valor de búsqueda <span className="required">*</span>
            </span>
            <input
              type="text"
              value={valor}
              onChange={(e) => setValor(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder={placeholderActual}
              autoFocus
            />
          </label>

          <label>
            <span style={{ visibility: "hidden" }}>Buscar</span>
            <button
              className="primary"
              onClick={handleBuscar}
              disabled={buscando || !valor.trim()}
            >
              {buscando ? "Buscando…" : "🔍 Buscar"}
            </button>
          </label>
        </div>
      </section>

      {/* Estado de carga */}
      {buscando && (
        <section className="panel status-panel">
          <p className="loading">Consultando afiliados…</p>
        </section>
      )}

      {/* Resultados */}
      {resultados !== null && !buscando && (
        <section className="panel">
          <h2>
            Resultados{" "}
            {resultados.length > 0 && (
              <span className="badge">{resultados.length}</span>
            )}
          </h2>

          {resultados.length === 0 ? (
            <div className="status-panel">
              <p style={{ color: "var(--ink-soft)", margin: "8px 0" }}>
                No se encontraron afiliados para los criterios ingresados.
              </p>
            </div>
          ) : (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>ID Afiliado</th>
                    <th>Nombre Completo</th>
                    <th>Identificación</th>
                    <th>N° Carnet</th>
                    <th>Estado</th>
                    <th style={{ textAlign: "center" }}>Acción</th>
                  </tr>
                </thead>
                <tbody>
                  {resultados.map((afiliado) => {
                    const isSelected =
                      afiliadoSeleccionado === afiliado.idAfiliado;
                    return (
                      <tr
                        key={afiliado.idAfiliado}
                        style={{
                          background: isSelected
                            ? "rgba(95,157,237,0.15)"
                            : undefined,
                        }}
                      >
                        <td>
                          <code style={{ color: "var(--accent)", fontSize: "0.82rem" }}>
                            {afiliado.idAfiliado}
                          </code>
                        </td>
                        <td style={{ fontWeight: 600 }}>
                          {afiliado.nombreCompleto}
                        </td>
                        <td>{afiliado.identificacion}</td>
                        <td>{afiliado.numeroCarnet}</td>
                        <td>
                          <span
                            style={{
                              color:
                                ESTADO_COLORS[afiliado.estadoAfiliado] ??
                                "var(--ink-soft)",
                              fontWeight: 700,
                              fontSize: "0.8rem",
                            }}
                          >
                            {afiliado.estadoAfiliado}
                          </span>
                        </td>
                        <td style={{ textAlign: "center" }}>
                          <button
                            className="primary"
                            style={{ padding: "6px 14px", fontSize: "0.8rem" }}
                            onClick={() => handleSeleccionar(afiliado)}
                            disabled={isSelected}
                          >
                            {isSelected ? "✓ Seleccionado" : "Seleccionar →"}
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </section>
      )}

      {/* Hint inicial */}
      {resultados === null && !buscando && (
        <section className="panel status-panel">
          <p style={{ color: "var(--ink-soft)", margin: "4px 0" }}>
            Ingrese un criterio de búsqueda y presione <strong>Buscar</strong> o{" "}
            <kbd
              style={{
                background: "var(--bg-sidebar-deep)",
                border: "1px solid var(--line-soft)",
                borderRadius: 4,
                padding: "1px 6px",
                fontSize: "0.82rem",
              }}
            >
              Enter
            </kbd>{" "}
            para comenzar.
          </p>
        </section>
      )}
    </div>
  );
}
