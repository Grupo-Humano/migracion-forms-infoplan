import type { TransactionRow } from "../types";

type Props = {
  rows: TransactionRow[];
};

export function ResultsTable({ rows }: Props) {
  return (
    <section className="panel">
      <h2>Resultados ({rows.length})</h2>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Compania</th>
              <th>Ramo</th>
              <th>Secuencial</th>
              <th>Monto</th>
              <th>Estado</th>
              <th>Rechazo</th>
              <th>Respuesta Banco</th>
              <th>Oficial</th>
              <th>Gerente</th>
              <th>Intermediario</th>
              <th>Seleccion</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id_transaccion}>
                <td>{row.id_transaccion}</td>
                <td>{row.fec_tra}</td>
                <td>{row.cliente}</td>
                <td>{row.compania}</td>
                <td>{row.ramo}</td>
                <td>{row.secuencial}</td>
                <td>{row.monto}</td>
                <td>{row.estado}</td>
                <td>{row.codigo_rechazo ?? "-"}</td>
                <td>{row.respuesta_banco ?? "-"}</td>
                <td>{row.nombre_oficial ?? row.oficial ?? "-"}</td>
                <td>{row.nombre_gerente ?? row.gerente ?? "-"}</td>
                <td>{row.nombre_intermediario ?? row.intermediario ?? "-"}</td>
                <td>{row.seleccion}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
