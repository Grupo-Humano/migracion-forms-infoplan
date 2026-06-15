# extract_lovs_records.py
# -*- coding: utf-8 -*-
"""
Extractor de LOVs (List of Values) y Record Groups de Oracle Forms XML
Exporta información detallada en JSON y CSV
"""

from pathlib import Path
import xml.etree.ElementTree as ET
import json
import csv
import sys
import argparse

NS = {"f": "http://xmlns.oracle.com/Forms"}


def read_text_attr(node, attr_name):
    """Lee un atributo de texto del nodo XML"""
    txt = node.get(attr_name)
    if txt is None:
        txt = "".join(node.itertext() or [])
    return txt or ""


def extract_lovs(root):
    """Extrae todos los LOVs del formulario"""
    lovs = {}

    for lov in root.findall(".//f:LOV", NS):
        lov_name = lov.get("Name") or lov.get("name")
        if not lov_name:
            continue

        lov_info = {
            "name": lov_name,
            "title": lov.get("Title") or lov.get("title") or "",
            "recordGroup": lov.get("RecordGroup") or lov.get("recordgroup") or "",
            "recordGroupQuery": "",
            "width": lov.get("Width") or "",
            "height": lov.get("Height") or "",
            "xPosition": lov.get("XPosition") or "",
            "yPosition": lov.get("YPosition") or "",
            "automaticRefresh": lov.get("AutomaticRefresh") or lov.get("automaticrefresh") or "false",
            "automaticSkip": lov.get("AutomaticSkip") or lov.get("automaticskip") or "false",
            "automaticSelect": lov.get("AutomaticSelect") or lov.get("automaticselect") or "false",
            "columns": [],
            "columnMapping": [],
            "usedByItems": []
        }

        # Extraer columnas del LOV
        for col in lov.findall(".//f:LovColumnMapping", NS):
            col_name = col.get("Name") or col.get("name") or ""
            col_title = col.get("Title") or col.get("title") or col_name
            col_width = col.get("Width") or col.get("width") or ""
            display = col.get("Display") or col.get("display") or "true"
            return_item = col.get("ReturnItem") or col.get("returnitem") or ""

            lov_info["columns"].append({
                "name": col_name,
                "title": col_title,
                "width": col_width,
                "display": display.lower() == "true",
                "returnItem": return_item
            })

        lovs[lov_name] = lov_info

    return lovs


def extract_record_groups(root):
    """Extrae todos los Record Groups del formulario"""
    record_groups = {}

    for rg in root.findall(".//f:RecordGroup", NS):
        rg_name = rg.get("Name") or rg.get("name")
        if not rg_name:
            continue

        rg_query = read_text_attr(rg, "RecordGroupQuery")
        if not rg_query:
            rg_query = read_text_attr(rg, "recordgroupquery")

        rg_type = rg.get("RecordGroupType") or rg.get(
            "recordgrouptype") or "Query"

        rg_info = {
            "name": rg_name,
            "type": rg_type,
            "query": rg_query,
            "fetchSize": rg.get("RecordGroupFetchSize") or rg.get("recordgroupfetchsize") or "",
            "columns": [],
            "usedByLOVs": []
        }

        # Extraer columnas del Record Group
        for col in rg.findall(".//f:ColumnSpecification", NS):
            col_name = col.get("Name") or col.get("name") or ""
            col_type = col.get("ColumnDatatype") or col.get(
                "columndatatype") or ""
            col_length = col.get("MaximumLength") or col.get(
                "maximumlength") or ""

            rg_info["columns"].append({
                "name": col_name,
                "datatype": col_type,
                "maxLength": col_length
            })

        record_groups[rg_name] = rg_info

    return record_groups


def find_lov_usage(root, lovs):
    """Encuentra qué items usan cada LOV"""
    for block in root.findall(".//f:Block", NS):
        block_name = block.get("Name") or block.get("name") or ""

        for item in block.findall(".//f:Item", NS):
            item_name = item.get("Name") or item.get("name") or ""
            lov_name = item.get("LOVName") or item.get("lovname") or ""

            if lov_name and lov_name in lovs:
                lovs[lov_name]["usedByItems"].append({
                    "block": block_name,
                    "item": item_name
                })

    return lovs


def link_lovs_to_record_groups(lovs, record_groups):
    """Vincula LOVs con sus Record Groups"""
    for lov_name, lov_info in lovs.items():
        rg_name = lov_info.get("recordGroup", "")
        if rg_name and rg_name in record_groups:
            record_groups[rg_name]["usedByLOVs"].append(lov_name)
            # Copiar la query del Record Group al LOV para referencia
            lovs[lov_name]["recordGroupQuery"] = record_groups[rg_name]["query"]

    return lovs, record_groups


def parse_xml(xml_path: Path):
    """Parsea el XML y extrae LOVs y Record Groups"""
    print(f"\nINFO: Parseando: {xml_path.name}")

    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Extraer LOVs
    lovs = extract_lovs(root)
    print(f"   ✓ LOVs encontrados: {len(lovs)}")

    # Extraer Record Groups
    record_groups = extract_record_groups(root)
    print(f"   ✓ Record Groups encontrados: {len(record_groups)}")

    # Encontrar uso de LOVs en items
    lovs = find_lov_usage(root, lovs)

    # Vincular LOVs con Record Groups
    lovs, record_groups = link_lovs_to_record_groups(lovs, record_groups)

    return lovs, record_groups


def export_to_json(lovs, record_groups, output_dir: Path, form_name: str):
    """Exporta LOVs y Record Groups a JSON"""

    # JSON de LOVs
    lovs_file = output_dir / f"{form_name}_lovs.json"
    with lovs_file.open("w", encoding="utf-8") as f:
        json.dump(lovs, f, indent=2, ensure_ascii=False)
    print(f"\nOK: LOVs exportados a: {lovs_file}")

    # JSON de Record Groups
    rg_file = output_dir / f"{form_name}_record_groups.json"
    with rg_file.open("w", encoding="utf-8") as f:
        json.dump(record_groups, f, indent=2, ensure_ascii=False)
    print(f"OK: Record Groups exportados a: {rg_file}")

    # JSON combinado
    combined_file = output_dir / f"{form_name}_lovs_and_records.json"
    combined = {
        "formName": form_name,
        "lovCount": len(lovs),
        "recordGroupCount": len(record_groups),
        "lovs": lovs,
        "recordGroups": record_groups
    }
    with combined_file.open("w", encoding="utf-8") as f:
        json.dump(combined, f, indent=2, ensure_ascii=False)
    print(f"OK: Combinado exportado a: {combined_file}")


def export_to_csv(lovs, record_groups, output_dir: Path, form_name: str):
    """Exporta LOVs y Record Groups a CSV"""

    # CSV de LOVs
    lovs_csv = output_dir / f"{form_name}_lovs.csv"
    with lovs_csv.open("w", newline="", encoding="utf-8") as f:
        fieldnames = ["lovName", "title", "recordGroup", "automaticRefresh", "automaticSkip",
                      "automaticSelect", "columnCount", "usedByCount", "hasQuery"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for lov_name, lov_info in sorted(lovs.items()):
            writer.writerow({
                "lovName": lov_name,
                "title": lov_info.get("title", ""),
                "recordGroup": lov_info.get("recordGroup", ""),
                "automaticRefresh": lov_info.get("automaticRefresh", "false"),
                "automaticSkip": lov_info.get("automaticSkip", "false"),
                "automaticSelect": lov_info.get("automaticSelect", "false"),
                "columnCount": len(lov_info.get("columns", [])),
                "usedByCount": len(lov_info.get("usedByItems", [])),
                "hasQuery": "Yes" if lov_info.get("recordGroupQuery", "") else "No"
            })
    print(f"OK: LOVs CSV exportado a: {lovs_csv}")

    # CSV de Record Groups
    rg_csv = output_dir / f"{form_name}_record_groups.csv"
    with rg_csv.open("w", newline="", encoding="utf-8") as f:
        fieldnames = ["recordGroupName", "type", "columnCount",
                      "usedByLOVCount", "hasQuery", "queryPreview"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for rg_name, rg_info in sorted(record_groups.items()):
            query = rg_info.get("query", "")
            query_preview = query[:100] + "..." if len(query) > 100 else query

            writer.writerow({
                "recordGroupName": rg_name,
                "type": rg_info.get("type", ""),
                "columnCount": len(rg_info.get("columns", [])),
                "usedByLOVCount": len(rg_info.get("usedByLOVs", [])),
                "hasQuery": "Yes" if query else "No",
                "queryPreview": query_preview.replace("\n", " ").replace("\r", "")
            })
    print(f"OK: Record Groups CSV exportado a: {rg_csv}")


def print_summary(lovs, record_groups):
    """Imprime un resumen en consola"""
    print(f"\n{'='*70}")
    print("RESUMEN DE LOVs Y RECORD GROUPS")
    print(f"{'='*70}")

    print(f"\nLOVs ({len(lovs)}):")
    for lov_name, lov_info in sorted(lovs.items()):
        print(f"\n  - {lov_name}")
        print(f"    Título: {lov_info.get('title', 'N/A')}")
        print(f"    Record Group: {lov_info.get('recordGroup', 'N/A')}")
        print(f"    Columnas: {len(lov_info.get('columns', []))}")
        print(f"    Usado por: {len(lov_info.get('usedByItems', []))} items")

        if lov_info.get('usedByItems'):
            print("    Items:")
            for item in lov_info.get('usedByItems', []):
                print(f"      - {item['block']}.{item['item']}")

        if lov_info.get('columns'):
            print("    Columnas LOV:")
            for col in lov_info.get('columns', []):
                display_icon = "[V]" if col.get('display', True) else "[ ]"
                return_info = f" -> {col['returnItem']}" if col.get(
                    'returnItem') else ""
                print(
                    f"      {display_icon} {col['name']} [{col.get('title', '')}]{return_info}")

    print(f"\nRecord Groups ({len(record_groups)}):")
    for rg_name, rg_info in sorted(record_groups.items()):
        print(f"\n  - {rg_name}")
        print(f"    Tipo: {rg_info.get('type', 'N/A')}")
        print(f"    Columnas: {len(rg_info.get('columns', []))}")
        print(f"    Usado por: {len(rg_info.get('usedByLOVs', []))} LOVs")

        if rg_info.get('usedByLOVs'):
            print(f"    LOVs: {', '.join(rg_info.get('usedByLOVs', []))}")

        if rg_info.get('columns'):
            print("    Columnas:")
            for col in rg_info.get('columns', []):
                print(f"      - {col['name']} ({col.get('datatype', 'N/A')})")

        if rg_info.get('query'):
            query = rg_info['query'].strip()
            print("    Query:")
            # Mostrar primeras líneas del query
            lines = query.split('\n')[:5]
            for line in lines:
                print(f"      {line}")
            if len(query.split('\n')) > 5:
                print(f"      ... ({len(query.split('\n')) - 5} líneas más)")


def main():
    parser = argparse.ArgumentParser(
        description="Extrae LOVs y Record Groups de archivos XML de Oracle Forms"
    )
    parser.add_argument("xml_file", help="Ruta al archivo XML de Oracle Forms")
    parser.add_argument("--json", action="store_true", help="Exportar a JSON")
    parser.add_argument("--csv", action="store_true", help="Exportar a CSV")
    parser.add_argument(
        "--output-dir", "-o", help="Directorio de salida (por defecto: directorio actual)")
    parser.add_argument("--summary", action="store_true",
                        help="Mostrar resumen detallado en consola")

    args = parser.parse_args()

    # Validar archivo XML
    xml_path = Path(args.xml_file)
    if not xml_path.exists():
        print(f"ERROR: No se encuentra el archivo {xml_path}")
        sys.exit(1)

    # Directorio de salida
    output_dir = Path(args.output_dir) if args.output_dir else Path.cwd()
    output_dir.mkdir(parents=True, exist_ok=True)

    # Nombre del formulario (sin extensión)
    form_name = xml_path.stem

    # Parsear XML
    try:
        lovs, record_groups = parse_xml(xml_path)
    except Exception as e:
        print(f"ERROR: Error al parsear XML: {e}")
        sys.exit(1)

    # Exportar según opciones
    if args.json or (not args.json and not args.csv):
        export_to_json(lovs, record_groups, output_dir, form_name)

    if args.csv:
        export_to_csv(lovs, record_groups, output_dir, form_name)

    if args.summary:
        print_summary(lovs, record_groups)

    print("\nOK: Proceso completado exitosamente")
    print(f"INFO: Archivos generados en: {output_dir.absolute()}")


if __name__ == "__main__":
    main()
