# extract_block_triggers.py
# -*- coding: utf-8 -*-
"""
Script simple para extraer triggers de un bloque específico de Oracle Forms XML
Uso: python extract_block_triggers.py <archivo.xml> <nombre_bloque>
"""

import xml.etree.ElementTree as ET
import sys
import json
from pathlib import Path

# Namespace para Oracle Forms XML
NS = {"f": "http://xmlns.oracle.com/Forms"}


def read_text_attr(node, attr_name):
    """Lee un atributo de texto del nodo"""
    txt = node.get(attr_name)
    if txt is None:
        txt = "".join(node.itertext() or [])
    return txt or ""


def extract_block_triggers(xml_path, block_name):
    """
    Extrae todos los triggers de un bloque específico

    Args:
        xml_path: Ruta al archivo XML de Oracle Forms
        block_name: Nombre del bloque a buscar

    Returns:
        dict: Diccionario con los triggers del bloque {nombre_trigger: código}
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Buscar el bloque específico
    for block in root.findall(".//f:Block", NS):
        bname = block.get("Name") or block.get("name")

        if bname == block_name:
            triggers = {}

            # Extraer propiedades del bloque
            block_info = {
                "name": bname,
                "queryDataSourceName": block.get("QueryDataSourceName") or "",
                "queryDataSourceType": block.get("QueryDataSourceType") or "None",
                "databaseBlock": block.get("DatabaseBlock", "false").lower() == "true"
            }

            # Extraer todos los triggers del bloque
            for trigger in block.findall("./f:Trigger", NS):
                trigger_name = trigger.get("Name") or trigger.get("name")
                trigger_code = read_text_attr(trigger, "TriggerText")
                if trigger_name:
                    triggers[trigger_name] = trigger_code

            return {
                "block_info": block_info,
                "triggers": triggers
            }

    return None


def main():
    if len(sys.argv) < 3:
        print(
            "Uso: python extract_block_triggers.py <archivo.xml> <nombre_bloque> [--json]")
        print("\nEjemplo:")
        print("  python extract_block_triggers.py mi_form.xml MI_BLOQUE")
        print("  python extract_block_triggers.py mi_form.xml MI_BLOQUE --json")
        sys.exit(1)

    xml_file = Path(sys.argv[1])
    block_name = sys.argv[2]
    output_json = "--json" in sys.argv

    if not xml_file.exists():
        print(f"ERROR: No se encuentra el archivo '{xml_file}'")
        sys.exit(1)

    print(f"INFO: Leyendo: {xml_file}")
    print(f"INFO: Buscando bloque: {block_name}\n")

    try:
        result = extract_block_triggers(xml_file, block_name)

        if result is None:
            print(
                f"ERROR: No se encontro el bloque '{block_name}' en el archivo XML")
            sys.exit(1)

        block_info = result["block_info"]
        triggers = result["triggers"]

        if output_json:
            # Salida en formato JSON
            output = {
                "block": block_info,
                "triggers": triggers,
                "trigger_count": len(triggers)
            }
            print(json.dumps(output, indent=2, ensure_ascii=False))

            # Guardar archivo JSON
            output_file = Path(f"triggers_{block_info['name']}.json")
            with output_file.open("w", encoding="utf-8") as f:
                json.dump(output, f, indent=2, ensure_ascii=False)
            print(f"\nOK: Triggers guardados en: {output_file}")
        else:
            # Salida formateada para consola
            print("="*70)
            print(f"BLOQUE: {block_info['name']}")
            print("="*70)

            if block_info['databaseBlock']:
                print("Tipo: Bloque de Base de Datos")
                if block_info['queryDataSourceName']:
                    print(
                        f"Fuente: {block_info['queryDataSourceName']} ({block_info['queryDataSourceType']})")
            else:
                print("Tipo: Bloque de Control")

            print(f"\nTRIGGERS ENCONTRADOS: {len(triggers)}")
            print("-"*70)

            if not triggers:
                print("(sin triggers)")
            else:
                for idx, (trigger_name, trigger_code) in enumerate(triggers.items(), 1):
                    print(f"\n[{idx}] {trigger_name}")
                    print("-"*70)
                    print(trigger_code)
                    print()

            # Guardar en archivo
            output_file = Path(f"triggers_{block_info['name']}.txt")
            with output_file.open("w", encoding="utf-8") as f:
                f.write(f"BLOQUE: {block_info['name']}\n")
                f.write(f"Fuente: {block_info['queryDataSourceName']}\n")
                f.write(f"Database Block: {block_info['databaseBlock']}\n")
                f.write("="*70 + "\n\n")

                for trigger_name, trigger_code in triggers.items():
                    f.write(f"TRIGGER: {trigger_name}\n")
                    f.write("-"*70 + "\n")
                    f.write(trigger_code + "\n")
                    f.write("\n" + "="*70 + "\n\n")

            print(f"OK: Triggers guardados en: {output_file}")

    except ET.ParseError as e:
        print(f"ERROR: Error al parsear XML: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
