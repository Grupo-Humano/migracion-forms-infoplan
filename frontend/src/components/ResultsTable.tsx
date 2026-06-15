import type { TransactionRow } from "../types";

type Props = {
  rows: TransactionRow[];
  onToggleSelection: (idTransaccion: number, selected: boolean) => void;
  rowNumberStart?: number;
};

export function ResultsTable({
  rows,
  onToggleSelection,
  rowNumberStart = 1
}: Readonly<Props>) {
  return (
    <section className="panel">
      <h2>Resultados ({rows.length})</h2>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>ID</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Cliente Poliza</th>
              <th>Compania</th>
              <th>Ramo</th>
              <th>Secuencial</th>
              <th>Monto</th>
              <th>Estado</th>
              <th>Estatus Poliza</th>
              <th>Cod. Rechazo</th>
              <th>Respuesta Banco</th>
              <th>Num. Autoriza</th>
              <th>Lote ID</th>
              <th>Frecuencia Pago</th>
              <th>Oficial</th>
              <th>Gerente</th>
              <th>Intermediario</th>
              <th>Sel.</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={row.id_transaccion}>
                <td>{rowNumberStart + index}</td>
                <td>{row.id_transaccion}</td>
                <td>{row.fec_tra}</td>
                <td>{row.cliente}</td>
                <td>{row.cliente_poliza ?? "-"}</td>
                <td>{row.compania}</td>
                <td>{row.ramo}</td>
                <td>{row.secuencial}</td>
                <td>{row.monto.toLocaleString("es-DO", { minimumFractionDigits: 2 })}</td>
                <td>{row.estado}</td>
                <td>{row.estatus_poliza ?? "-"}</td>
                <td>{row.codigo_rechazo ?? "-"}</td>
                <td>{row.respuesta_banco ?? "-"}</td>
                <td>{row.num_autoriza ?? "-"}</td>
                <td>{row.lote_id ?? "-"}</td>
                <td>{row.frecuencia_pago ?? "-"}</td>
                <td>{row.nombre_oficial ?? row.oficial ?? "-"}</td>
                <td>{row.nombre_gerente ?? row.gerente ?? "-"}</td>
                <td>{row.nombre_intermediario ?? row.intermediario ?? "-"}</td>
                <td>
                  <input
                    type="checkbox"
                    checked={row.seleccion === "S"}
                    onChange={(event) =>
                      onToggleSelection(row.id_transaccion, event.target.checked)
                    }
                    aria-label={`Seleccionar transaccion ${row.id_transaccion}`}
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
