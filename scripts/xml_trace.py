# forms_trace_cli.py
# -*- coding: utf-8 -*-
"""
Oracle Forms XML Inspector + Flowchart Trace (Mermaid + HTML)
- Lista Blocks/Items (con ItemType) y triggers -> items_catalog.csv
- Traza estilo diagrama de flujo (Mermaid) + HTML con código por paso
- Soporta GO_BLOCK/GO_ITEM/EXECUTE_QUERY/CLEAR_BLOCK/CALL_FORM/OPEN_FORM/NEW_FORM
- Sigue llamadas a Program Units y muestra su código
- Detecta y sugiere triggers de navegación presentes en destino
- TODO se guarda en el directorio actual (no usa /mnt/data)
"""

from pathlib import Path
import xml.etree.ElementTree as ET
import re
import csv
import json
import sys
import html
import argparse

# =======================
# CONFIG
# =======================
XML_PATHS = []
OUTPUT_DIR = Path.cwd()
NS = {"f": "http://xmlns.oracle.com/Forms"}

# ======= Regex útiles =======
RX_GO_BLOCK = re.compile(r"\bGO_BLOCK\s*\(\s*'([^']+)'\s*\)", re.I)
RX_GO_ITEM = re.compile(r"\bGO_ITEM\s*\(\s*'([^']+)'\s*\)", re.I)
RX_EXEC_QUERY = re.compile(r"\bEXECUTE_QUERY\b", re.I)
RX_CLEAR_BLK = re.compile(r"\bCLEAR_BLOCK\s*\(([^)]*)\)", re.I)
RX_CALL_FORM = re.compile(
    r"\b(CALL_FORM|OPEN_FORM|NEW_FORM)\s*\(\s*'([^']+)'", re.I)
RX_ITEM_REF = re.compile(r":([A-Za-z0-9_$#]+)\.([A-Za-z0-9_$#]+)")
RX_PROC_CALL = re.compile(r"\b([A-Z][A-Z0-9_$#]*)\s*\(", re.I)
RESERVED = {
    "IF", "ELSIF", "ELSE", "END", "BEGIN", "LOOP", "EXIT", "THEN", "WHILE", "FOR", "NULL",
    "GO_BLOCK", "GO_ITEM", "EXECUTE_QUERY", "CLEAR_BLOCK", "CALL_FORM", "OPEN_FORM", "NEW_FORM",
    "MSG_ALERT", "MESSAGE", "SYNCHRONIZE", "RAISE", "FORM_TRIGGER_FAILURE", "IIF"
}

# ======= Estructuras =======
forms = {
    # bname -> {"triggers":{t:code}, "items":{iname:{itemType, triggers{t:code}, attrs}}}
    "blocks": {},
    "alerts": {},        # aname -> attrs
    "program_units": {},  # pname -> {"code": str}
    "canvas": {},        # cname -> {"attrs": {}, "items": []}
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Oracle Forms XML Inspector + Flowchart Trace"
    )
    parser.add_argument(
        "xml_files",
        nargs="*",
        help="Archivos XML de entrada. Si se omite, usa forms/*.xml",
    )
    parser.add_argument(
        "--output-dir",
        "-o",
        help="Directorio de salida (por defecto: directorio actual)",
    )
    return parser.parse_args()


def resolve_input_paths(cli_paths):
    if cli_paths:
        return [Path(p) for p in cli_paths]
    default_forms_dir = Path(__file__).resolve().parents[1] / "forms"
    return sorted(default_forms_dir.glob("*.xml"))

# ======= Utilidades =======


def read_text_attr(node, attr_name):
    txt = node.get(attr_name)
    if txt is None:
        txt = "".join(node.itertext() or [])
    return txt or ""


def parse_xml(path: Path):
    tree = ET.parse(path)
    root = tree.getroot()

    # Alerts
    for a in root.findall(".//f:Alert", NS):
        name = a.get("Name") or a.get("name")
        if name:
            forms["alerts"][name] = {"attrs": dict(a.attrib)}

    # Program Units
    for pu in root.findall(".//f:ProgramUnit", NS):
        name = pu.get("Name") or pu.get("name")
        code = read_text_attr(pu, "ProgramUnitText")
        if not code:
            code = read_text_attr(pu, "programunittext")
        if name:
            forms["program_units"][name] = {"code": code}

    # Canvas
    for canvas in root.findall(".//f:Canvas", NS):
        cname = canvas.get("Name") or canvas.get("name")
        if cname:
            forms["canvas"][cname] = {
                "attrs": dict(canvas.attrib),
                "items": []
            }

    # Blocks / Items / Triggers
    for b in root.findall(".//f:Block", NS):
        bname = b.get("Name") or b.get("name")
        if not bname:
            continue
        # Propiedades de base de datos del bloque
        query_data_source_name = b.get("QueryDataSourceName") or ""
        query_data_source_type = b.get("QueryDataSourceType") or "None"
        database_block = b.get("DatabaseBlock", "false").lower() == "true"

        blk = forms["blocks"].setdefault(bname, {
            "triggers": {},
            "items": {},
            "queryDataSourceName": query_data_source_name,
            "queryDataSourceType": query_data_source_type,
            "databaseBlock": database_block
        })

        for tr in b.findall("./f:Trigger", NS):
            tname = tr.get("Name") or tr.get("name")
            tcode = read_text_attr(tr, "TriggerText")
            blk["triggers"][tname] = tcode

        for it in b.findall("./f:Item", NS):
            iname = it.get("Name") or it.get("name")
            itype = it.get("ItemType") or it.get("itemtype") or ""
            canvas_name = it.get("CanvasName") or it.get(
                "canvasname") or it.get("Canvas") or it.get("canvas")
            tab_page_name = it.get("TabPageName") or it.get(
                "tabpagename") or ""
            if not iname:
                continue
            # Propiedades de base de datos
            database_item = it.get("DatabaseItem", "true").lower(
            ) == "true"  # Por defecto true si no se especifica
            column_name = it.get("ColumnName") or ""

            meta = blk["items"].setdefault(iname, {
                "itemType": itype,
                "triggers": {},
                "attrs": dict(it.attrib),
                "canvas": canvas_name,
                "tabPageName": tab_page_name,
                "databaseItem": database_item,
                "columnName": column_name
            })

            # Asociar item al canvas
            if canvas_name and canvas_name in forms["canvas"]:
                forms["canvas"][canvas_name]["items"].append({
                    "block": bname,
                    "item": iname,
                    "itemType": itype,
                    "tabPageName": tab_page_name,
                    "databaseItem": database_item,
                    "columnName": column_name
                })

            for tr in it.findall("./f:Trigger", NS):
                tname = tr.get("Name") or tr.get("name")
                tcode = read_text_attr(tr, "TriggerText")
                meta["triggers"][tname] = tcode


def load_all(xml_paths):
    ok = False
    for p in xml_paths:
        pth = Path(p)
        if not pth.exists():
            print(f"WARN: No existe {pth.resolve()}")
            continue
        print(f"INFO: Parseando: {pth}")
        parse_xml(pth)
        ok = True
    if not ok:
        print("ERROR: No se cargo ningun XML. Proporciona archivos o usa forms/*.xml.")
        sys.exit(1)


def list_all():
    out_csv = OUTPUT_DIR / "items_catalog.csv"
    rows = []
    for bname, b in sorted(forms["blocks"].items()):
        rows.append({
            "kind": "BLOCK", "block": bname, "item": "", "itemType": "", "trigger": ";".join(sorted(b["triggers"])),
            "canvas": "", "databaseItem": "", "columnName": "",
            "queryDataSourceName": b.get("queryDataSourceName", ""),
            "queryDataSourceType": b.get("queryDataSourceType", "None"),
            "databaseBlock": str(b.get("databaseBlock", False))
        })
        for iname, meta in sorted(b["items"].items()):
            rows.append({
                "kind": "ITEM", "block": bname, "item": iname, "itemType": meta.get("itemType", ""),
                "trigger": ";".join(sorted(meta["triggers"])),
                "canvas": meta.get("canvas", ""),
                "tabPageName": meta.get("tabPageName", ""),
                "databaseItem": str(meta.get("databaseItem", False)),
                "columnName": meta.get("columnName", ""),
                "queryDataSourceName": "", "queryDataSourceType": "", "databaseBlock": ""
            })
    for aname in sorted(forms["alerts"]):
        rows.append({
            "kind": "ALERT", "block": "", "item": aname, "itemType": "Alert", "trigger": "", "canvas": "", "tabPageName": "",
            "databaseItem": "", "columnName": "", "queryDataSourceName": "", "queryDataSourceType": "", "databaseBlock": ""
        })
    for pname in sorted(forms["program_units"]):
        rows.append({
            "kind": "PROGRAM_UNIT", "block": "", "item": pname, "itemType": "ProgramUnit", "trigger": "", "canvas": "", "tabPageName": "",
            "databaseItem": "", "columnName": "", "queryDataSourceName": "", "queryDataSourceType": "", "databaseBlock": ""
        })

    # Agregar Canvas al CSV
    for cname, canvas_info in sorted(forms["canvas"].items()):
        rows.append({
            "kind": "CANVAS", "block": "", "item": cname, "itemType": "Canvas",
            "trigger": "", "canvas": cname, "tabPageName": "",
            "databaseItem": "", "columnName": "", "queryDataSourceName": "", "queryDataSourceType": "", "databaseBlock": ""
        })

    with out_csv.open("w", newline="", encoding="utf-8") as f:
        fieldnames = ["kind", "block", "item", "itemType", "trigger", "canvas", "tabPageName", "databaseItem", "columnName",
                      "queryDataSourceName", "queryDataSourceType", "databaseBlock"]
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)
    print(f"Catálogo exportado: {out_csv}")


def find_item(full_or_short_name: str):
    if "." in full_or_short_name:
        b, i = full_or_short_name.split(".", 1)
        b = b.strip()
        i = i.strip()
        blk = forms["blocks"].get(b)
        if blk and i in blk["items"]:
            return b, i, blk["items"][i]
        return None, None, None
    else:
        matches = []
        for bname, b in forms["blocks"].items():
            if full_or_short_name in b["items"]:
                matches.append((bname, full_or_short_name,
                               b["items"][full_or_short_name]))
        if len(matches) == 1:
            return matches[0]
        return None, None, None


def code_actions(code: str):
    actions = []
    for blk in RX_GO_BLOCK.findall(code):
        actions.append({"type": "GO_BLOCK", "target_block": blk})
    for itm in RX_GO_ITEM.findall(code):
        actions.append({"type": "GO_ITEM", "target_item": itm})
    if RX_EXEC_QUERY.search(code):
        actions.append({"type": "EXECUTE_QUERY"})
    for m in RX_CLEAR_BLK.findall(code):
        actions.append({"type": "CLEAR_BLOCK", "arg": m.strip()})
    for kind, mod in RX_CALL_FORM.findall(code):
        actions.append({"type": kind.upper(), "module": mod})
    refs = sorted({f"{b}.{i}" for b, i in RX_ITEM_REF.findall(code)})
    if refs:
        actions.append({"type": "ITEM_REFS", "items": refs})
    procs = []
    for name in RX_PROC_CALL.findall(code):
        up = name.upper()
        if up not in RESERVED:
            procs.append(name)
    if procs:
        actions.append({"type": "CALLS", "procs": sorted(set(procs))})
    return actions

# ======= Funciones para Canvas =======


def get_canvas_items(canvas_name: str):
    """Retorna todos los items que pertenecen a un canvas específico"""
    canvas_info = forms["canvas"].get(canvas_name)
    if not canvas_info:
        return None
    return canvas_info["items"]


def export_canvas_to_json(canvas_name: str) -> bool:
    """Exporta la información de un canvas a un archivo JSON"""
    items = get_canvas_items(canvas_name)
    if items is None:
        return False

    # Agrupar por bloque y obtener información completa
    blocks_info = {}
    for item in items:
        block_name = item['block']
        if block_name not in blocks_info:
            block_info = forms["blocks"].get(block_name, {})
            blocks_info[block_name] = {
                "queryDataSourceName": block_info.get("queryDataSourceName", ""),
                "queryDataSourceType": block_info.get("queryDataSourceType", "None"),
                "databaseBlock": block_info.get("databaseBlock", False),
                "items": []
            }
        blocks_info[block_name]["items"].append(item)

    # Crear estructura JSON
    json_data = {
        "canvasName": canvas_name,
        "itemCount": len(items),
        "blockCount": len(blocks_info),
        "blocks": [
            {
                "blockName": block_name,
                "databaseBlock": block_data["databaseBlock"],
                "queryDataSourceName": block_data["queryDataSourceName"],
                "queryDataSourceType": block_data["queryDataSourceType"],
                "items": block_data["items"]
            }
            for block_name, block_data in sorted(blocks_info.items())
        ]
    }

    # Exportar a archivo
    json_filename = OUTPUT_DIR / f"canvas_{sanitize(canvas_name)}.json"
    with json_filename.open("w", encoding="utf-8") as f:
        json.dump(json_data, f, indent=2, ensure_ascii=False)

    print(f"\nOK: JSON exportado: {json_filename}")
    return True


def list_canvas():
    """Lista todos los canvas y sus elementos"""
    if not forms["canvas"]:
        print("No se encontraron Canvas en los formularios.")
        return

    print(f"\n=== CANVAS ENCONTRADOS ({len(forms['canvas'])}) ===")
    for cname, canvas_info in sorted(forms["canvas"].items()):
        print(f"\nCanvas: {cname}")
        if canvas_info["items"]:
            print(f"   Items ({len(canvas_info['items'])}):")
            for item in canvas_info["items"]:
                db_info = "[DB]" if item.get(
                    'databaseItem', False) else "[CTRL]"
                column_info = f" -> {item.get('columnName', '')}" if item.get(
                    'columnName') else ""
                tab_info = f" [Tab: {item.get('tabPageName', '')}]" if item.get(
                    'tabPageName') else ""
                print(
                    f"   {db_info} {item['block']}.{item['item']} [{item['itemType']}]{column_info}{tab_info}")
        else:
            print("   (sin elementos)")


def search_canvas_by_item(block_name: str, item_name: str):
    """Busca en qué canvas está un item específico"""
    for cname, canvas_info in forms["canvas"].items():
        for item in canvas_info["items"]:
            if item["block"] == block_name and item["item"] == item_name:
                return cname
    return None


def list_block_items(block_name: str, export_csv: bool = False, export_json: bool = False):
    """Lista todos los items de un bloque específico con sus detalles"""
    block_info = forms["blocks"].get(block_name)

    if not block_info:
        print(f"ERROR: Bloque '{block_name}' no encontrado.")
        # Mostrar bloques disponibles
        available = list(forms["blocks"].keys())
        if available:
            print(f"\nBloques disponibles: {', '.join(sorted(available))}")
        return

    print(f"\n{'='*60}")
    print(f"BLOQUE: {block_name}")
    print(f"{'='*60}")

    # Información de base de datos del bloque
    if block_info.get("databaseBlock", False):
        print("Tipo: Bloque de Base de Datos")
        if block_info.get("queryDataSourceName"):
            print(
                f"Fuente: {block_info['queryDataSourceName']} ({block_info.get('queryDataSourceType', 'None')})")
    else:
        print("Tipo: Bloque de Control (no conectado a BD)")

    # Triggers del bloque
    if block_info.get("triggers"):
        print(f"\nTriggers del Bloque ({len(block_info['triggers'])}):")
        for tname in sorted(block_info["triggers"].keys()):
            print(f"   - {tname}")

    # Items del bloque
    items = block_info.get("items", {})
    if not items:
        print("\n   (sin items)")
        return

    print(f"\nItems del Bloque ({len(items)}):")
    print(f"{'-'*60}")

    # Preparar datos para exportación
    items_data = []

    for item_name, item_meta in sorted(items.items()):
        db_icon = "[DB]" if item_meta.get('databaseItem', False) else "[CTRL]"
        item_type = item_meta.get('itemType', 'Unknown')
        canvas = item_meta.get('canvas', '')
        tab_page = item_meta.get('tabPageName', '')
        column = item_meta.get('columnName', '')
        triggers = item_meta.get('triggers', {})

        print(f"\n{db_icon} {item_name}")
        print(f"   Tipo: {item_type}")

        if canvas:
            print(f"   Canvas: {canvas}")

        if tab_page:
            print(f"   Tab Page: {tab_page}")

        if column:
            print(f"   Columna BD: {column}")
        elif item_meta.get('databaseItem', False):
            print(f"   Columna BD: {item_name}")

        if triggers:
            print(
                f"   Triggers ({len(triggers)}): {', '.join(sorted(triggers.keys()))}")
        else:
            print("   Triggers: (ninguno)")

        # Agregar a datos de exportación
        item_data = {
            "block": block_name,
            "item": item_name,
            "itemType": item_type,
            "canvas": canvas,
            "tabPageName": tab_page,
            "databaseItem": item_meta.get('databaseItem', False),
            "columnName": column if column else (item_name if item_meta.get('databaseItem', False) else ""),
            "triggers": list(sorted(triggers.keys())),
            "triggerCount": len(triggers)
        }
        items_data.append(item_data)

    # Exportar CSV si se solicitó
    if export_csv and items_data:
        csv_rows = [{
            **item,
            "databaseItem": str(item["databaseItem"]),
            "triggers": ";".join(item["triggers"])
        } for item in items_data]

        csv_filename = OUTPUT_DIR / f"block_{sanitize(block_name)}_items.csv"
        with csv_filename.open("w", newline="", encoding="utf-8") as f:
            fieldnames = ["block", "item", "itemType", "canvas", "tabPageName",
                          "databaseItem", "columnName", "triggers", "triggerCount"]
            w = csv.DictWriter(f, fieldnames=fieldnames)
            w.writeheader()
            w.writerows(csv_rows)
        print(f"\nOK: CSV exportado: {csv_filename}")

    # Exportar JSON si se solicitó
    if export_json and items_data:
        json_data = {
            "blockName": block_name,
            "blockInfo": {
                "databaseBlock": block_info.get("databaseBlock", False),
                "queryDataSourceName": block_info.get("queryDataSourceName", ""),
                "queryDataSourceType": block_info.get("queryDataSourceType", "None"),
                "triggers": list(sorted(block_info.get("triggers", {}).keys()))
            },
            "itemCount": len(items_data),
            "items": items_data
        }

        json_filename = OUTPUT_DIR / f"block_{sanitize(block_name)}_items.json"
        with json_filename.open("w", encoding="utf-8") as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        print(f"\nOK: JSON exportado: {json_filename}")


def get_block_triggers(block):
    return forms["blocks"].get(block, {}).get("triggers", {})


def get_item_triggers(block, item):
    return forms["blocks"].get(block, {}).get("items", {}).get(item, {}).get("triggers", {})


def resolve_program_unit(name):
    pu = forms["program_units"].get(name)
    return pu["code"] if pu else None


def pretty_code(code, max_len=None):
    if not code:
        return ""
    txt = "\n".join(ln.rstrip() for ln in code.splitlines())
    return (txt if not max_len or len(txt) <= max_len else txt[:max_len]+" ...")

# ======= Traza =======


def trace_from(element_name: str, max_depth: int = 3):
    trace = {"start": element_name, "steps": []}
    visited_pu = set()

    b, i, meta = find_item(element_name)
    if b and i:
        trigger_order = [
            "WHEN-MOUSE-ENTER", "WHEN-BUTTON-PRESSED", "WHEN-MOUSE-CLICK", "WHEN-MOUSE-LEAVE",
            "KEY-ENTER", "WHEN-VALIDATE-ITEM", "POST-CHANGE"
        ]
        triggers = get_item_triggers(b, i)
        ordered = [t for t in trigger_order if t in triggers] + \
            [t for t in triggers if t not in trigger_order]

        for tname in ordered:
            code = triggers[tname]
            actions = code_actions(code)
            step = {
                "element": f"{b}.{i}",
                "itemType": meta.get("itemType", ""),
                "trigger": tname,
                "code": code,
                "actions": actions
            }
            trace["steps"].append(step)
            # seguir program units
            for a in actions:
                if a["type"] == "CALLS":
                    for pu_name in a["procs"]:
                        follow_program_unit(
                            trace, pu_name, visited_pu, max_depth-1)

    else:
        blk = forms["blocks"].get(element_name)
        if not blk:
            print(
                f"No se encontró '{element_name}'. Usa 'BLOCK.ITEM' o ITEM único o BLOCK.")
            return trace
        for tname, code in blk["triggers"].items():
            actions = code_actions(code)
            step = {
                "element": element_name,
                "itemType": "BLOCK",
                "trigger": tname,
                "code": code,
                "actions": actions
            }
            trace["steps"].append(step)
            for a in actions:
                if a["type"] == "CALLS":
                    for pu_name in a["procs"]:
                        follow_program_unit(
                            trace, pu_name, visited_pu, max_depth-1)
    return trace


def follow_program_unit(trace, pu_name, visited, depth):
    if depth < 0:
        return
    key = pu_name.upper()
    if key in visited:
        return
    code = resolve_program_unit(pu_name)
    visited.add(key)
    if code:
        actions = code_actions(code)
        step = {
            "element": f"PROGRAM_UNIT.{pu_name}",
            "itemType": "ProgramUnit",
            "trigger": "(called)",
            "code": code,
            "actions": actions
        }
        trace["steps"].append(step)
        for a in actions:
            if a["type"] == "CALLS":
                for next_name in a["procs"]:
                    follow_program_unit(trace, next_name, visited, depth-1)

# ======= Exports =======


def export_dot(trace):
    out = OUTPUT_DIR / "forms_trace.dot"
    with out.open("w", encoding="utf-8") as f:
        f.write("digraph forms_trace {\n  rankdir=LR;\n  node [shape=box];\n")
        last = None
        for idx, st in enumerate(trace["steps"], start=1):
            nid = f"n{idx}"
            label = f"{idx}. {st['element']}\\n[{st['itemType']}]\\n{st['trigger']}"
            f.write(f'  {nid} [label="{label}"];\n')
            if last:
                f.write(f"  {last} -> {nid};\n")
            # acciones navegacionales como nodos chicos
            for ai, a in enumerate(st["actions"], start=1):
                if a["type"] in ("EXECUTE_QUERY", "CLEAR_BLOCK"):
                    aid = f"{nid}_a{ai}"
                    f.write(f'  {aid} [shape=ellipse,label="{a["type"]}"];\n')
                    f.write(f"  {nid} -> {aid};\n")
            last = nid
        f.write("}\n")
    print(f"Grafo DOT: {out}")


def export_mermaid_and_html(trace, element_name):
    # Mermaid
    mmd_path = OUTPUT_DIR / "forms_flowchart.mmd"
    # HTML final con diagrama + código
    html_path = OUTPUT_DIR / f"trace_{sanitize(element_name)}.html"

    # Construcción de nodos y edges
    lines = []
    lines.append("flowchart LR")
    idmap = {}  # idx -> node id
    extra_nodes = []  # (id,label)
    extra_edges = []  # (src_id, dst_id, label)

    for idx, st in enumerate(trace["steps"], start=1):
        nid = f"S{idx}"
        idmap[idx] = nid
        title = f"{idx}. {st['element']}\\n[{st['itemType']}]\\n{st['trigger']}"
        safe_title = title.replace('"', '\\"')
        lines.append(f'  {nid}["{safe_title}"]')

    # Conectar pasos lineales
    for i in range(1, len(idmap)):
        lines.append(f"  {idmap[i]} --> {idmap[i+1]}")

    # Bifurcaciones por acciones
    def add_node(_id, label):
        _label = label.replace('"', '\\"')
        extra_nodes.append((_id, _label))

    for idx, st in enumerate(trace["steps"], start=1):
        nid = idmap[idx]
        # Navegación / llamadas
        for ai, a in enumerate(st["actions"], start=1):
            if a["type"] == "GO_BLOCK":
                tb = a["target_block"]
                bid = f"B_{clean_id(tb)}"
                add_node(bid, f"Block: {tb}")
                extra_edges.append((nid, bid, "GO_BLOCK"))
                # posibles triggers en destino
                btr = get_block_triggers(tb)
                for tname in ("WHEN-NEW-BLOCK-INSTANCE", "PRE-QUERY", "POST-QUERY", "WHEN-NEW-RECORD-INSTANCE"):
                    if tname in btr:
                        tid = f"{bid}_{clean_id(tname)}"
                        add_node(tid, f"{tb}\\n{tname}")
                        extra_edges.append((bid, tid, ""))

            elif a["type"] == "GO_ITEM":
                tgt = a["target_item"]
                if "." not in tgt:
                    # relativo: asume mismo bloque del paso actual
                    base_block = st["element"].split(
                        ".", 1)[0] if "." in st["element"] else ""
                    tgt = f"{base_block}.{tgt}"
                tb, ti, _ = find_item(
                    tgt) if "." in tgt else (None, None, None)
                iid = f"I_{clean_id(tgt)}"
                if tb and ti:
                    itype = forms["blocks"][tb]["items"][ti].get(
                        "itemType", "")
                    add_node(iid, f"Item: {tb}.{ti}\\n[{itype}]")
                    extra_edges.append((nid, iid, "GO_ITEM"))
                    itr = get_item_triggers(tb, ti)
                    for tname in ("WHEN-NEW-ITEM-INSTANCE", "WHEN-VALIDATE-ITEM", "POST-CHANGE"):
                        if tname in itr:
                            tid = f"{iid}_{clean_id(tname)}"
                            add_node(tid, f"{tb}.{ti}\\n{tname}")
                            extra_edges.append((iid, tid, ""))
                else:
                    add_node(iid, f"Item: {tgt}")
                    extra_edges.append((nid, iid, "GO_ITEM"))

            elif a["type"] in ("EXECUTE_QUERY", "CLEAR_BLOCK"):
                aid = f"A_{idx}_{ai}"
                add_node(aid, a["type"])
                extra_edges.append((nid, aid, ""))

            elif a["type"] in ("CALL_FORM", "OPEN_FORM", "NEW_FORM"):
                aid = f"F_{idx}_{ai}"
                add_node(aid, f'{a["type"]}: {a.get("module", "")}')
                extra_edges.append((nid, aid, ""))

            elif a["type"] == "CALLS":
                for pu in a["procs"]:
                    pid = f"PU_{clean_id(pu)}"
                    add_node(pid, f"Program Unit: {pu}")
                    extra_edges.append((nid, pid, "CALLS"))

    # volcar extra nodes/edges
    for _id, _label in extra_nodes:
        lines.append(f'  {_id}("{_label}")')
    for src, dst, lbl in extra_edges:
        if lbl:
            lines.append(f'  {src} -- "{lbl}" --> {dst}')
        else:
            lines.append(f'  {src} --> {dst}')

    # clicks en cada paso que abren la sección de código
    for idx in range(1, len(trace["steps"])+1):
        nid = idmap[idx]
        lines.append(f'  click {nid} "#step{idx}" "Ver código del paso {idx}"')

    # Guardar .mmd
    with mmd_path.open("w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Mermaid exportado: {mmd_path}")

    # HTML con Mermaid + código por paso
    mermaid_code = html.escape("\n".join(lines))
    body_steps = []
    for idx, st in enumerate(trace["steps"], start=1):
        code_html = html.escape(st["code"] or "")
        actions_html = ""
        if st["actions"]:
            actions_html = "<ul>" + \
                "".join(
                    f"<li>{html.escape(str(a))}</li>" for a in st["actions"]) + "</ul>"
        item_type = html.escape(st.get("itemType", ""))
        body_steps.append(f"""
<section id="step{idx}">
  <h3>Paso {idx}: {html.escape(st['element'])} &nbsp;&nbsp;<small>[{item_type}]</small> — <code>{html.escape(st['trigger'])}</code></h3>
  <h4>Acciones detectadas</h4>
  {actions_html or "<p><em>(ninguna)</em></p>"}
  <h4>Código</h4>
  <pre><code class="language-plsql">{code_html}</code></pre>
  <hr>
</section>
""")

    html_doc = f"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>Trace {html.escape(element_name)}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {{ font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; margin: 20px; }}
pre {{ background:#f6f8fa; padding:12px; border-radius:6px; overflow:auto; }}
.flow {{ border:1px solid #ddd; border-radius:6px; padding:12px; background:#fff; }}
summary {{ cursor:pointer; }}
h3 code {{ background:#eee; padding:2px 6px; border-radius:4px; }}
small {{ color:#666; }}
</style>
<!-- Mermaid desde CDN (necesita internet para dibujar el diagrama) -->
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>mermaid.initialize({{ startOnLoad: true, securityLevel: "loose" }});</script>
</head>
<body>
<h1>Traza: {html.escape(element_name)}</h1>

<div class="flow">
<div class="mermaid">
{mermaid_code}
</div>
</div>

<h2>Código por paso</h2>
{"".join(body_steps)}

<p><em>Tip:</em> haz clic en los nodos del diagrama para saltar al código del paso correspondiente.</p>
</body>
</html>
"""
    with html_path.open("w", encoding="utf-8") as f:
        f.write(html_doc)
    print(f"HTML exportado: {html_path}")


def export_trace_bundle(trace, element_name):
    export_dot(trace)
    export_mermaid_and_html(trace, element_name)


def sanitize(s: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", s)


def clean_id(s: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]+", "_", s)

# ======= CLI =======


def main_menu():
    while True:
        print("\n=== Oracle Forms XML Inspector ===")
        print("1) Listar elementos y exportar CSV (ItemType + triggers)")
        print("2) Generar traza (flowchart + código) desde un elemento")
        print("3) Listar Canvas y sus elementos")
        print("4) Buscar elementos de un Canvas específico")
        print("5) Listar items de un Bloque específico")
        print("6) Salir")
        op = input("Opción: ").strip()
        if op == "1":
            list_all()
        elif op == "2":
            name = input(
                "Elemento inicio (BLOCK.ITEM o ITEM único o BLOCK): ").strip()
            try:
                depth = int(
                    input("Profundidad de Program Units [3]: ").strip() or "3")
            except ValueError:
                depth = 3
            tr = trace_from(name, max_depth=depth)
            export_trace_bundle(tr, name)
        elif op == "3":
            list_canvas()
        elif op == "4":
            canvas_name = input("Nombre del Canvas: ").strip()
            if canvas_name:
                items = get_canvas_items(canvas_name)
                if items is None:
                    print(f"ERROR: Canvas '{canvas_name}' no encontrado.")
                    # Mostrar canvas disponibles
                    available = list(forms["canvas"].keys())
                    if available:
                        print(
                            f"Canvas disponibles: {', '.join(sorted(available))}")
                elif not items:
                    print(
                        f"INFO: Canvas '{canvas_name}' encontrado pero sin elementos.")
                else:
                    print(
                        f"\nCanvas '{canvas_name}' - Elementos ({len(items)}):")
                    # Agrupar por bloque para mostrar información de fuente de datos
                    blocks_info = {}
                    for item in items:
                        block_name = item['block']
                        if block_name not in blocks_info:
                            block_info = forms["blocks"].get(block_name, {})
                            blocks_info[block_name] = {
                                "queryDataSourceName": block_info.get("queryDataSourceName", ""),
                                "queryDataSourceType": block_info.get("queryDataSourceType", "None"),
                                "databaseBlock": block_info.get("databaseBlock", False),
                                "items": []
                            }
                        blocks_info[block_name]["items"].append(item)

                    for block_name, block_data in sorted(blocks_info.items()):
                        print(f"\n   Bloque: {block_name}")
                        if block_data["databaseBlock"] and block_data["queryDataSourceName"]:
                            print(
                                f"      Fuente: {block_data['queryDataSourceName']} ({block_data['queryDataSourceType']})")
                        else:
                            print("      Bloque de control (no conectado a BD)")

                        for item in block_data["items"]:
                            db_icon = "[DB]" if item.get(
                                'databaseItem', False) else "[CTRL]"
                            column_info = f" -> {item.get('columnName', '')}" if item.get(
                                'columnName') else ""
                            tab_info = f" [Tab: {item.get('tabPageName', '')}]" if item.get(
                                'tabPageName') else ""
                            print(
                                f"      {db_icon} {item['item']} [{item['itemType']}]{column_info}{tab_info}")

                    # Preguntar si se desea exportar a JSON
                    export = input(
                        "\n¿Exportar a JSON? (s/n) [s]: ").strip().lower()
                    if export == '' or export == 's' or export == 'si' or export == 'yes' or export == 'y':
                        export_canvas_to_json(canvas_name)
            else:
                print("ERROR: Debe especificar un nombre de Canvas.")
        elif op == "5":
            block_name = input("Nombre del Bloque: ").strip()
            if block_name:
                export_csv = input(
                    "¿Exportar a CSV? (s/n) [n]: ").strip().lower()
                export_csv = export_csv == 's' or export_csv == 'si' or export_csv == 'yes' or export_csv == 'y'

                export_json = input(
                    "¿Exportar a JSON? (s/n) [s]: ").strip().lower()
                export_json = export_json == '' or export_json == 's' or export_json == 'si' or export_json == 'yes' or export_json == 'y'

                list_block_items(
                    block_name, export_csv=export_csv, export_json=export_json)
            else:
                print("ERROR: Debe especificar un nombre de Bloque.")
        elif op == "6":
            break
        else:
            print("Opción inválida.")


if __name__ == "__main__":
    args = parse_args()
    if args.output_dir:
        OUTPUT_DIR = Path(args.output_dir)
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    XML_PATHS = resolve_input_paths(args.xml_files)
    load_all(XML_PATHS)
    if not (forms["blocks"] or forms["alerts"] or forms["program_units"]):
        print("ERROR: No se detecto contenido en los XML configurados.")
        sys.exit(1)
    main_menu()
