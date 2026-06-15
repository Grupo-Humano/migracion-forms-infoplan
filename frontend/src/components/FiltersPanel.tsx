import type { ChangeEvent } from "react";
import type { LovItem, SearchFilters } from "../types";

type Props = {
  filters: SearchFilters;
  onChange: (next: SearchFilters) => void;
  onSearch: () => void;
  onLoadOficial: () => void;
  searching: boolean;
  dateCrossError?: string;
  gerentes?: LovItem[];
  intermediarios?: LovItem[];
};

export function FiltersPanel({
  filters,
  onChange,
  onSearch,
  onLoadOficial,
  searching,
  dateCrossError = "",
  gerentes = [],
  intermediarios = []
}: Readonly<Props>) {
  const updateField =
    (field: keyof SearchFilters) => (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
      onChange({
        ...filters,
        [field]: event.target.value
      });
    };

  return (
    <section className="panel">
      <h2>Criterios de consulta</h2>
      <div className="grid">
        <label>
          <span>Fecha desde <span className="required">*</span></span>
          <input
            type="date"
            value={filters.fec_ini}
            onChange={updateField("fec_ini")}
            aria-invalid={Boolean(dateCrossError)}
          />
        </label>
        <label>
          <span>Fecha hasta <span className="required">*</span></span>
          <input
            type="date"
            value={filters.fec_fin}
            onChange={updateField("fec_fin")}
            aria-invalid={Boolean(dateCrossError)}
          />
          {dateCrossError && <span className="field-error">{dateCrossError}</span>}
        </label>
        <label>
          <span>Cliente</span>
          <input
            type="number"
            value={filters.cliente}
            onChange={updateField("cliente")}
            placeholder="Opcional"
          />
        </label>
        <label>
          <span>Oficial</span>
          <div className="inline-input">
            <input
              type="number"
              value={filters.oficial}
              onChange={updateField("oficial")}
              placeholder="Opcional"
            />
            <button type="button" onClick={onLoadOficial}>
              Cargar nombre
            </button>
          </div>
        </label>
        <label>
          <span>Gerente</span>
          <select value={filters.gerente} onChange={updateField("gerente")}>
            <option value="">-- Todos --</option>
            {gerentes.map((g) => (
              <option key={g.codigo} value={String(g.codigo)}>{g.nombre}</option>
            ))}
          </select>
        </label>
        <label>
          <span>Intermediario</span>
          <select value={filters.intermediario} onChange={updateField("intermediario")}>
            <option value="">-- Todos --</option>
            {intermediarios.map((i) => (
              <option key={i.codigo} value={String(i.codigo)}>{i.nombre}</option>
            ))}
          </select>
        </label>
      </div>
      <div className="actions-row">
        <button
          type="button"
          className="primary"
          onClick={onSearch}
          disabled={searching || Boolean(dateCrossError)}
          aria-busy={searching}
        >
          {searching ? "Buscando..." : "Buscar"}
        </button>
      </div>
    </section>
  );
}
