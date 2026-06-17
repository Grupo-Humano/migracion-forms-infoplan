# -*- coding: utf-8 -*-
"""
Analisis exhaustivo de mecanicas de base de datos en Oracle Forms XML.

Genera:
- inventario de Program Units, LOVs, RecordGroups y Triggers
- deteccion de SQL (SELECT/INSERT/UPDATE/DELETE/MERGE/EXECUTE IMMEDIATE)
- grafo de llamadas internas y externas
- cascadas de llamadas (anidamiento) desde triggers y program units

Uso:
  py -3 analyze_reemb_pago_db_mechanics.py <xml_path> <output_dir>
"""

from __future__ import annotations

import csv
import html
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
import xml.etree.ElementTree as ET

NS = {"f": "http://xmlns.oracle.com/Forms"}

SQL_PATTERNS = {
    "SELECT": re.compile(r"\bSELECT\b", re.IGNORECASE),
    "INSERT": re.compile(r"\bINSERT\b", re.IGNORECASE),
    "UPDATE": re.compile(r"\bUPDATE\b", re.IGNORECASE),
    "DELETE": re.compile(r"\bDELETE\b", re.IGNORECASE),
    "MERGE": re.compile(r"\bMERGE\b", re.IGNORECASE),
    "EXECUTE_IMMEDIATE": re.compile(r"\bEXECUTE\s+IMMEDIATE\b", re.IGNORECASE),
    "CURSOR": re.compile(r"\bCURSOR\b", re.IGNORECASE),
}

CALL_PATTERN = re.compile(r"\b([A-Z][A-Z0-9_$#\.]*)\s*\(", re.IGNORECASE)

RESERVED = {
    "IF", "ELSIF", "ELSE", "END", "BEGIN", "LOOP", "EXIT", "THEN", "WHILE", "FOR", "NULL",
    "NVL", "DECODE", "SUBSTR", "INSTR", "LTRIM", "RTRIM", "TRIM", "UPPER", "LOWER", "TO_CHAR",
    "TO_DATE", "TO_NUMBER", "COUNT", "SUM", "MAX", "MIN", "AVG", "ROUND", "TRUNC", "ABS",
    "SYSDATE", "SYSTIMESTAMP", "COMMIT", "ROLLBACK", "RAISE", "WHEN", "EXCEPTION", "INTO", "FROM",
    "WHERE", "ORDER", "GROUP", "HAVING", "UNION", "ALL", "DISTINCT", "AND", "OR", "NOT", "IS",
    "SET_ITEM_PROPERTY", "SET_BLOCK_PROPERTY", "GET_ITEM_PROPERTY", "GET_BLOCK_PROPERTY",
    "GO_ITEM", "GO_BLOCK", "EXECUTE_QUERY", "CLEAR_BLOCK", "DO_KEY", "SHOW_LOV", "CREATE_RECORD",
    "DELETE_RECORD", "CLEAR_RECORD", "LIST_VALUES", "EDIT_FIELD", "SYNCHRONIZE", "MESSAGE",
    "NAME_IN", "COPY", "OPEN_FORM", "CALL_FORM", "NEW_FORM", "SHOW_VIEW", "HIDE_VIEW",
    "FIND_RELATION", "QUERY_MASTER_DETAILS", "SET_VIEW_PROPERTY", "GET_VIEW_PROPERTY", "SET_WINDOW_PROPERTY",
    "FIND_TIMER", "DELETE_TIMER", "CREATE_TIMER", "ID_NULL", "SHOW_ALERT", "PROPERTY_TRUE", "PROPERTY_FALSE",
    "PROPERTY_ON", "PROPERTY_OFF", "FORM_TRIGGER_FAILURE", "NO_REPEAT", "USER", "DUAL",
}


def read_text_attr(node: ET.Element, attr_name: str) -> str:
    txt = node.get(attr_name)
    if txt is None:
        txt = "".join(node.itertext() or [])
    if txt is None:
        return ""
    txt = html.unescape(txt)
    txt = txt.replace("\r\n", "\n").replace("\r", "\n")
    return txt


def compact(text: str, max_len: int = 220) -> str:
    line = " ".join(text.strip().split())
    if len(line) <= max_len:
        return line
    return line[: max_len - 3] + "..."


def extract_calls(code: str) -> list[str]:
    calls = []
    for m in CALL_PATTERN.findall(code or ""):
        c = (m or "").strip()
        if not c:
            continue
        base = c.split(".")[-1].upper()
        if base in RESERVED:
            continue
        if c.upper() in RESERVED:
            continue
        calls.append(c)
    return sorted(set(calls), key=lambda s: s.upper())


def sql_metrics(code: str) -> dict[str, int]:
    result = {}
    for k, p in SQL_PATTERNS.items():
        result[k] = len(p.findall(code or ""))
    return result


def detect_select_snippets(code: str) -> list[str]:
    if not code:
        return []
    snippets = []
    pattern = re.compile(r"\bSELECT\b.*?(?:;|\n\s*FROM\b.*?;)", re.IGNORECASE | re.DOTALL)
    for m in pattern.finditer(code):
        snippets.append(compact(m.group(0), 300))
    if snippets:
        return snippets[:20]
    # fallback line-based
    for ln in code.splitlines():
        if re.search(r"\bSELECT\b", ln, re.IGNORECASE):
            snippets.append(compact(ln, 300))
    return snippets[:20]


def node_id(kind: str, name: str) -> str:
    return f"{kind}:{name}"


def dfs_cascade(start: str, graph: dict[str, list[str]]) -> list[list[str]]:
    paths = []

    def walk(cur: str, seen: set[str], path: list[str]) -> None:
        nxt = graph.get(cur, [])
        if not nxt:
            paths.append(path[:])
            return
        progressed = False
        for n in nxt:
            if n in seen:
                paths.append(path + [f"{n} (cycle)"])
                continue
            progressed = True
            walk(n, seen | {n}, path + [n])
        if not progressed:
            paths.append(path[:])

    walk(start, {start}, [start])
    return paths


def main() -> int:
    if len(sys.argv) < 3:
        print("Uso: py -3 analyze_reemb_pago_db_mechanics.py <xml_path> <output_dir>")
        return 1

    xml_path = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)

    if not xml_path.exists():
        print(f"ERROR: No existe XML: {xml_path}")
        return 1

    root = ET.parse(xml_path).getroot()

    program_units = {}
    trigger_nodes = {}
    lovs = []
    record_groups = []

    # Program Units
    for pu in root.findall(".//f:ProgramUnit", NS):
        name = pu.get("Name") or pu.get("name") or ""
        if not name:
            continue
        pu_type = pu.get("ProgramUnitType") or pu.get("programunittype") or "Unknown"
        code = read_text_attr(pu, "ProgramUnitText") or read_text_attr(pu, "programunittext")
        program_units[name] = {
            "name": name,
            "type": pu_type,
            "code": code,
        }

    # Form triggers
    for tr in root.findall("./f:Trigger", NS):
        tname = tr.get("Name") or tr.get("name") or ""
        if not tname:
            continue
        code = read_text_attr(tr, "TriggerText")
        trigger_nodes[node_id("TRG_FORM", tname)] = {
            "scope": "FORM",
            "owner": "FORM",
            "name": tname,
            "code": code,
        }

    # Block and Item triggers
    for b in root.findall(".//f:Block", NS):
        bname = b.get("Name") or b.get("name") or ""
        if not bname:
            continue
        for tr in b.findall("./f:Trigger", NS):
            tname = tr.get("Name") or tr.get("name") or ""
            if not tname:
                continue
            code = read_text_attr(tr, "TriggerText")
            key = node_id("TRG_BLOCK", f"{bname}.{tname}")
            trigger_nodes[key] = {
                "scope": "BLOCK",
                "owner": bname,
                "name": tname,
                "code": code,
            }
        for i in b.findall("./f:Item", NS):
            iname = i.get("Name") or i.get("name") or ""
            if not iname:
                continue
            for tr in i.findall("./f:Trigger", NS):
                tname = tr.get("Name") or tr.get("name") or ""
                if not tname:
                    continue
                code = read_text_attr(tr, "TriggerText")
                key = node_id("TRG_ITEM", f"{bname}.{iname}.{tname}")
                trigger_nodes[key] = {
                    "scope": "ITEM",
                    "owner": f"{bname}.{iname}",
                    "name": tname,
                    "code": code,
                }

    # LOV + RecordGroup
    for lov in root.findall(".//f:LOV", NS):
        lname = lov.get("Name") or lov.get("name") or ""
        if lname:
            rg_name = lov.get("RecordGroupName") or lov.get("RecordGroup") or lov.get("recordgroup") or ""
            lovs.append({"name": lname, "record_group": rg_name})

    for rg in root.findall(".//f:RecordGroup", NS):
        rg_name = rg.get("Name") or rg.get("name") or ""
        if not rg_name:
            continue
        q = read_text_attr(rg, "RecordGroupQuery") or read_text_attr(rg, "recordgroupquery")
        record_groups.append({"name": rg_name, "query": q})

    # Build call graph
    pu_index_upper = {k.upper(): k for k in program_units.keys()}
    graph = defaultdict(list)
    edges = []

    def register_calls(source_id: str, code: str) -> dict[str, int]:
        metrics = sql_metrics(code)
        calls = extract_calls(code)
        for c in calls:
            c_base = c.split(".")[-1].upper()
            if c_base in pu_index_upper:
                target_name = pu_index_upper[c_base]
                target_id = node_id("PU", target_name)
                graph[source_id].append(target_id)
                edges.append({"source": source_id, "target": target_id, "type": "INTERNAL_PU_CALL", "raw": c})
            else:
                ext_id = node_id("EXT", c)
                graph[source_id].append(ext_id)
                edges.append({"source": source_id, "target": ext_id, "type": "EXTERNAL_CALL", "raw": c})
        return metrics

    nodes_metrics = {}

    for pu_name, pu in program_units.items():
        sid = node_id("PU", pu_name)
        nodes_metrics[sid] = register_calls(sid, pu["code"])

    for tid, tr in trigger_nodes.items():
        nodes_metrics[tid] = register_calls(tid, tr["code"])

    # Write inventories
    with (out_dir / "05-program-units-inventory.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["name", "type", "sql_select", "sql_insert", "sql_update", "sql_delete", "sql_merge", "execute_immediate", "cursor", "call_count"])
        w.writeheader()
        for name in sorted(program_units.keys(), key=str.upper):
            sid = node_id("PU", name)
            m = nodes_metrics.get(sid, {})
            call_count = sum(1 for e in edges if e["source"] == sid)
            w.writerow({
                "name": name,
                "type": program_units[name]["type"],
                "sql_select": m.get("SELECT", 0),
                "sql_insert": m.get("INSERT", 0),
                "sql_update": m.get("UPDATE", 0),
                "sql_delete": m.get("DELETE", 0),
                "sql_merge": m.get("MERGE", 0),
                "execute_immediate": m.get("EXECUTE_IMMEDIATE", 0),
                "cursor": m.get("CURSOR", 0),
                "call_count": call_count,
            })

    with (out_dir / "06-lovs-recordgroups-inventory.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["kind", "name", "record_group", "has_query", "query_preview"])
        w.writeheader()
        for lov in sorted(lovs, key=lambda x: x["name"].upper()):
            w.writerow({"kind": "LOV", "name": lov["name"], "record_group": lov["record_group"], "has_query": "", "query_preview": ""})
        rg_map = {r["name"]: r for r in record_groups}
        for rg in sorted(record_groups, key=lambda x: x["name"].upper()):
            q = rg.get("query", "")
            w.writerow({
                "kind": "RecordGroup",
                "name": rg["name"],
                "record_group": "",
                "has_query": "YES" if q.strip() else "NO",
                "query_preview": compact(q, 260),
            })

    with (out_dir / "07-trigger-inventory.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["node_id", "scope", "owner", "trigger", "sql_select", "sql_insert", "sql_update", "sql_delete", "sql_merge", "execute_immediate", "cursor", "call_count"])
        w.writeheader()
        for tid in sorted(trigger_nodes.keys(), key=str.upper):
            tr = trigger_nodes[tid]
            m = nodes_metrics.get(tid, {})
            call_count = sum(1 for e in edges if e["source"] == tid)
            w.writerow({
                "node_id": tid,
                "scope": tr["scope"],
                "owner": tr["owner"],
                "trigger": tr["name"],
                "sql_select": m.get("SELECT", 0),
                "sql_insert": m.get("INSERT", 0),
                "sql_update": m.get("UPDATE", 0),
                "sql_delete": m.get("DELETE", 0),
                "sql_merge": m.get("MERGE", 0),
                "execute_immediate": m.get("EXECUTE_IMMEDIATE", 0),
                "cursor": m.get("CURSOR", 0),
                "call_count": call_count,
            })

    with (out_dir / "08-call-edges.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["source", "target", "type", "raw"])
        w.writeheader()
        for e in edges:
            w.writerow(e)

    # Cascades
    entrypoints = sorted(list(trigger_nodes.keys()) + [node_id("PU", n) for n in program_units.keys()], key=str.upper)
    cascade_lines = []
    cascade_lines.append("# Cascadas de llamadas (exhaustivo)\n")
    cascade_lines.append(f"Entrypoints analizados: {len(entrypoints)}")
    cascade_lines.append("")
    for ep in entrypoints:
        cascade_lines.append(f"## {ep}")
        paths = dfs_cascade(ep, graph)
        cascade_lines.append(f"Total rutas: {len(paths)}")
        for idx, p in enumerate(paths, start=1):
            cascade_lines.append(f"{idx}. " + " -> ".join(p))
        cascade_lines.append("")

    (out_dir / "09-cascadas-llamadas.md").write_text("\n".join(cascade_lines), encoding="utf-8")

    # SQL snippets
    sql_lines = []
    sql_lines.append("# Selects y SQL detectados por nodo\n")
    for pu_name in sorted(program_units.keys(), key=str.upper):
        sid = node_id("PU", pu_name)
        code = program_units[pu_name]["code"]
        sql_lines.append(f"## {sid}")
        m = nodes_metrics.get(sid, {})
        sql_lines.append(f"- SELECT={m.get('SELECT', 0)} INSERT={m.get('INSERT', 0)} UPDATE={m.get('UPDATE', 0)} DELETE={m.get('DELETE', 0)} MERGE={m.get('MERGE', 0)} EXECUTE_IMMEDIATE={m.get('EXECUTE_IMMEDIATE', 0)} CURSOR={m.get('CURSOR', 0)}")
        snippets = detect_select_snippets(code)
        if snippets:
            sql_lines.append("- Snippets:")
            for s in snippets:
                sql_lines.append(f"  - {s}")
        sql_lines.append("")

    for tid in sorted(trigger_nodes.keys(), key=str.upper):
        tr = trigger_nodes[tid]
        code = tr["code"]
        sql_lines.append(f"## {tid}")
        m = nodes_metrics.get(tid, {})
        sql_lines.append(f"- SELECT={m.get('SELECT', 0)} INSERT={m.get('INSERT', 0)} UPDATE={m.get('UPDATE', 0)} DELETE={m.get('DELETE', 0)} MERGE={m.get('MERGE', 0)} EXECUTE_IMMEDIATE={m.get('EXECUTE_IMMEDIATE', 0)} CURSOR={m.get('CURSOR', 0)}")
        snippets = detect_select_snippets(code)
        if snippets:
            sql_lines.append("- Snippets:")
            for s in snippets:
                sql_lines.append(f"  - {s}")
        sql_lines.append("")

    (out_dir / "10-sql-detectado-exhaustivo.md").write_text("\n".join(sql_lines), encoding="utf-8")

    summary = {
        "source_xml": str(xml_path),
        "program_units": len(program_units),
        "lovs": len(lovs),
        "record_groups": len(record_groups),
        "triggers_total": len(trigger_nodes),
        "call_edges": len(edges),
        "generated_files": [
            "05-program-units-inventory.csv",
            "06-lovs-recordgroups-inventory.csv",
            "07-trigger-inventory.csv",
            "08-call-edges.csv",
            "09-cascadas-llamadas.md",
            "10-sql-detectado-exhaustivo.md",
        ],
    }
    (out_dir / "00-resumen-analisis-db-mechanics.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")

    print(json.dumps(summary, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
