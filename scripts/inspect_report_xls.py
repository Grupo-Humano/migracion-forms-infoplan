import json
import os
from datetime import datetime

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
PRIMARY_FILE = os.path.join(
    BASE_DIR, 'data', 'jasper-reference', 'report6.xls')
LEGACY_FILE = os.path.join(BASE_DIR, 'report6.xls')
FILE_PATH = PRIMARY_FILE if os.path.exists(PRIMARY_FILE) else LEGACY_FILE

try:
    import xlrd
except Exception as exc:
    print(json.dumps({"error": f"xlrd import failed: {exc}"}))
    raise SystemExit(1)

if not os.path.exists(FILE_PATH):
    print(json.dumps({"error": f"file not found: {FILE_PATH}"}))
    raise SystemExit(1)

book = xlrd.open_workbook(FILE_PATH)
sheet = book.sheet_by_index(0)


def normalize_header(text):
    return str(text).strip().upper()


header_row_idx = None
for r in range(sheet.nrows):
    probe = [normalize_header(sheet.cell_value(r, c))
             for c in range(sheet.ncols)]
    if "FEC_TRA" in probe and "ID_TRANSACCION" in probe:
        header_row_idx = r
        headers = [str(sheet.cell_value(r, c)).strip()
                   for c in range(sheet.ncols)]
        break

if header_row_idx is None:
    print(json.dumps(
        {"error": "could not locate header row with FEC_TRA and ID_TRANSACCION"}))
    raise SystemExit(1)

rows = []
for r in range(header_row_idx + 1, sheet.nrows):
    row = []
    for c in range(sheet.ncols):
        v = sheet.cell_value(r, c)
        ct = sheet.cell_type(r, c)
        if ct == xlrd.XL_CELL_DATE:
            dt = xlrd.xldate_as_datetime(v, book.datemode)
            row.append(dt.strftime('%Y-%m-%d'))
        elif ct == xlrd.XL_CELL_NUMBER:
            if float(v).is_integer():
                row.append(str(int(v)))
            else:
                row.append(str(v))
        else:
            row.append(str(v).strip())
    rows.append(row)

# basic column detection
upper = [h.upper() for h in headers]
idx_fecha = next((i for i, h in enumerate(upper) if h == 'FEC_TRA'), None)
idx_id = next((i for i, h in enumerate(upper) if h == 'ID_TRANSACCION'), None)
idx_estado = next((i for i, h in enumerate(upper) if h == 'ESTADO'), None)

fechas = []
fechas_dt = []
ids = []
estados = {}
date_counts = {}
for row in rows:
    # Skip fully blank rows
    if not any(cell for cell in row):
        continue

    if idx_fecha is not None and idx_fecha < len(row):
        v = row[idx_fecha]
        if v:
            fechas.append(v)
            try:
                parsed = datetime.strptime(v, '%d-%b-%Y')
                fechas_dt.append(parsed)
                key = parsed.strftime('%Y-%m-%d')
                date_counts[key] = date_counts.get(key, 0) + 1
            except Exception:
                pass
    if idx_id is not None and idx_id < len(row):
        v = row[idx_id]
        if v:
            ids.append(v)
    if idx_estado is not None and idx_estado < len(row):
        v = row[idx_estado]
        if v:
            estados[v] = estados.get(v, 0) + 1

out = {
    "header_row_idx": header_row_idx,
    "file": FILE_PATH,
    "sheet": sheet.name,
    "row_count": len(rows),
    "col_count": len(headers),
    "headers": headers,
    "fecha_idx": idx_fecha,
    "id_idx": idx_id,
    "estado_idx": idx_estado,
    "fecha_min": min(fechas_dt).strftime('%Y-%m-%d') if fechas_dt else (min(fechas) if fechas else None),
    "fecha_max": max(fechas_dt).strftime('%Y-%m-%d') if fechas_dt else (max(fechas) if fechas else None),
    "id_min": min(ids) if ids else None,
    "id_max": max(ids) if ids else None,
    "estado_counts_top": dict(sorted(estados.items(), key=lambda kv: kv[1], reverse=True)[:10]),
    "date_counts_top": dict(sorted(date_counts.items(), key=lambda kv: kv[1], reverse=True)[:10]),
    "first_rows": rows[:5]
}
print(json.dumps(out, ensure_ascii=True))
