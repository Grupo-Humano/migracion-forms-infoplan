import type { ChangeEvent } from "react";
import type { SearchFilters } from "../types";

type Props = {
  filters: SearchFilters;
  onChange: (next: SearchFilters) => void;
  onSearch: () => void;
  onLoadOficial: () => void;
  searching: boolean;
};

export function FiltersPanel({
  filters,
  onChange,
  onSearch,
  onLoadOficial,
  searching
}: Readonly<Props>) {
  const updateField =
    (field: keyof SearchFilters) => (event: ChangeEvent<HTMLInputElement>) => {
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
          <span>Fecha desde</span>
          <input
            type="date"
            value={filters.fec_ini}
            onChange={updateField("fec_ini")}
          />
        </label>
        <label>
          <span>Fecha hasta</span>
          <input
            type="date"
            value={filters.fec_fin}
            onChange={updateField("fec_fin")}
          />
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
          <input
            type="number"
            value={filters.gerente}
            onChange={updateField("gerente")}
            placeholder="Opcional"
          />
        </label>
        <label>
          <span>Intermediario</span>
          <input
            type="number"
            value={filters.intermediario}
            onChange={updateField("intermediario")}
            placeholder="Opcional"
          />
        </label>
      </div>
      <div className="actions-row">
        <button type="button" className="primary" onClick={onSearch}>
          {searching ? "Buscando..." : "Buscar"}
        </button>
      </div>
    </section>
  );
}
