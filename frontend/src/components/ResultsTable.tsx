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
  const renderOrNd = (value: string | number | null | undefined): string | number => {
    if (value === null || value === undefined) {
      return "N/D";
    }
    if (typeof value === "string" && value.trim() === "") {
      return "N/D";
    }
    return value;
  };

  return (
    <section className="panel">
      <h2>Resultados ({rows.length})</h2>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Tipo Documento</th>
              <th>Num. Documento</th>
              <th>Cliente Poliza</th>
              <th>Compania</th>
              <th>Ramo</th>
              <th>Secuencial</th>
              <th>Monto</th>
              <th>Estado</th>
              <th>Estatus Poliza</th>
              <th>Cod. Rechazo</th>
              <th>Descripcion Rechazo</th>
              <th>Respuesta Banco</th>
              <th>Num. Autoriza</th>
              <th>Lote ID</th>
              <th>Frecuencia Pago</th>
              <th>Oficial</th>
              <th>Gerente</th>
              <th>Director</th>
              <th>Intermediario</th>
              <th>Grupo</th>
              <th>ID Transaccion</th>
              <th>User Crea</th>
              <th>Fecha Crea</th>
              <th>User Actualiza</th>
              <th>Fecha Actualiza</th>
              <th>Telefono 1</th>
              <th>Telefono 2</th>
              <th>Telefono 3</th>
              <th>Sel.</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={row.id_transaccion}>
                <td>{rowNumberStart + index}</td>
                <td>{row.fec_tra}</td>
                <td>{row.cliente}</td>
                <td>{row.tipo_documento ?? ""}</td>
                <td>{row.num_documento ?? ""}</td>
                <td>{row.cliente_poliza ?? ""}</td>
                <td>{row.compania}</td>
                <td>{row.ramo}</td>
                <td>{row.secuencial}</td>
                <td>{row.monto.toLocaleString("es-DO", { minimumFractionDigits: 2 })}</td>
                <td>{row.estado}</td>
                <td>{row.estatus_poliza ?? ""}</td>
                <td>{row.codigo_rechazo ?? ""}</td>
                <td>{row.descripcion_rechazo ?? ""}</td>
                <td>{row.respuesta_banco ?? ""}</td>
                <td>{row.num_autoriza ?? ""}</td>
                <td>{row.lote_id ?? ""}</td>
                <td>{renderOrNd(row.frecuencia_pago)}</td>
                <td>{renderOrNd(row.nombre_oficial ?? row.oficial)}</td>
                <td>{renderOrNd(row.nombre_gerente ?? row.gerente)}</td>
                <td>{renderOrNd(row.nombre_director)}</td>
                <td>{renderOrNd(row.nombre_intermediario ?? row.intermediario)}</td>
                <td>{row.grupo ?? ""}</td>
                <td>{row.id_transaccion}</td>
                <td>{row.user_crea ?? ""}</td>
                <td>{row.fecha_crea ?? ""}</td>
                <td>{row.user_actualiza ?? ""}</td>
                <td>{row.fecha_actualiza ?? ""}</td>
                <td>{renderOrNd(row.telefono_1)}</td>
                <td>{renderOrNd(row.telefono_2)}</td>
                <td>{renderOrNd(row.telefono_3)}</td>
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
