# extract_program_units.py
# -*- coding: utf-8 -*-
"""
Script para extraer Program Units de Oracle Forms XML
Uso: python extract_program_units.py <archivo.xml> [nombre_program_unit] [--json] [--no-comments]
"""

import xml.etree.ElementTree as ET
import sys
import json
import html
import re
from pathlib import Path

# Namespace para Oracle Forms XML
NS = {"f": "http://xmlns.oracle.com/Forms"}

def read_text_attr(node, attr_name):
    """Lee un atributo de texto del nodo"""
    txt = node.get(attr_name)
    if txt is None:
        txt = "".join(node.itertext() or [])
    return txt or ""


def clean_code(code, remove_comments=False):
    """
    Limpia el código PL/SQL:
    - Decodifica entidades HTML/XML (&#10; -> salto de línea, etc.)
    - Opcionalmente remueve comentarios problemáticos
    
    Args:
        code: Código fuente a limpiar
        remove_comments: Si es True, remueve comentarios SQL
        
    Returns:
        str: Código limpio
    """
    if not code:
        return ""
    
    # 1. Decodificar entidades HTML/XML (&#10; = \n, &#13; = \r, etc.)
    code = html.unescape(code)
    
    # 2. Reemplazar entidades numéricas específicas que html.unescape no maneje
    # &#10; = Line Feed (LF)
    # &#13; = Carriage Return (CR)
    code = re.sub(r'&#10;', '\n', code)
    code = re.sub(r'&#13;', '\r', code)
    code = re.sub(r'&#9;', '\t', code)
    
    # 3. Opcionalmente remover comentarios
    if remove_comments:
        # Remover comentarios de línea (-- ...)
        code = re.sub(r'--[^\n]*', '', code)
        
        # Remover comentarios de bloque (/* ... */)
        # Este regex maneja comentarios multilínea
        code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)
        
        # Limpiar líneas vacías múltiples (dejar máximo 2 líneas vacías consecutivas)
        code = re.sub(r'\n{3,}', '\n\n', code)
    
    # 4. Normalizar saltos de línea a \n (Unix style)
    code = code.replace('\r\n', '\n').replace('\r', '\n')
    
    return code.strip()


def extract_all_program_units(xml_path, remove_comments=False):
    """
    Extrae todos los Program Units del formulario
    
    Args:
        xml_path: Ruta al archivo XML de Oracle Forms
        remove_comments: Si es True, remueve comentarios del código
        
    Returns:
        dict: Diccionario con los program units {nombre: {tipo, codigo}}
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    program_units = {}
    
    # Buscar todos los Program Units
    for pu in root.findall(".//f:ProgramUnit", NS):
        pu_name = pu.get("Name") or pu.get("name")
        pu_type = pu.get("ProgramUnitType") or pu.get("programunittype") or "Unknown"
        pu_code = read_text_attr(pu, "ProgramUnitText")
        if not pu_code:
            pu_code = read_text_attr(pu, "programunittext")
        
        # Limpiar el código: decodificar entidades y opcionalmente remover comentarios
        pu_code = clean_code(pu_code, remove_comments)
        
        if pu_name:
            program_units[pu_name] = {
                "name": pu_name,
                "type": pu_type,
                "code": pu_code
            }
    
    return program_units


def extract_single_program_unit(xml_path, pu_name, remove_comments=False):
    """
    Extrae un Program Unit específico
    
    Args:
        xml_path: Ruta al archivo XML de Oracle Forms
        pu_name: Nombre del Program Unit a buscar
        remove_comments: Si es True, remueve comentarios del código
        
    Returns:
        dict: Información del Program Unit o None si no se encuentra
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    # Buscar el Program Unit específico
    for pu in root.findall(".//f:ProgramUnit", NS):
        name = pu.get("Name") or pu.get("name")
        
        if name == pu_name:
            pu_type = pu.get("ProgramUnitType") or pu.get("programunittype") or "Unknown"
            pu_code = read_text_attr(pu, "ProgramUnitText")
            if not pu_code:
                pu_code = read_text_attr(pu, "programunittext")
            
            # Limpiar el código: decodificar entidades y opcionalmente remover comentarios
            pu_code = clean_code(pu_code, remove_comments)
            
            return {
                "name": name,
                "type": pu_type,
                "code": pu_code
            }
    
    return None


def main():
    if len(sys.argv) < 2:
        print("Uso: python extract_program_units.py <archivo.xml> [nombre_program_unit] [--json] [--no-comments]")
        print("\nOpciones:")
        print("  --json          Salida en formato JSON en consola")
        print("  --no-comments   Omitir comentarios del código extraído")
        print("\nEjemplos:")
        print("  # Extraer TODOS los Program Units")
        print("  python extract_program_units.py mi_form.xml")
        print("  python extract_program_units.py mi_form.xml --json")
        print("  python extract_program_units.py mi_form.xml --no-comments")
        print("\n  # Extraer UN Program Unit específico")
        print("  python extract_program_units.py mi_form.xml MI_PROCEDIMIENTO")
        print("  python extract_program_units.py mi_form.xml MI_FUNCION --json")
        print("  python extract_program_units.py mi_form.xml MI_FUNCION --no-comments")
        sys.exit(1)
    
    xml_file = Path(sys.argv[1])
    output_json = "--json" in sys.argv
    remove_comments = "--no-comments" in sys.argv
    
    # Determinar si se busca un program unit específico o todos
    specific_pu = None
    if len(sys.argv) >= 3 and sys.argv[2] not in ["--json", "--no-comments"]:
        specific_pu = sys.argv[2]
    
    if not xml_file.exists():
        print(f"ERROR: No se encuentra el archivo '{xml_file}'")
        sys.exit(1)
    
    print(f"INFO: Leyendo: {xml_file}")
    if remove_comments:
        print("INFO: Modo: Omitiendo comentarios")
    
    try:
        if specific_pu:
            # Extraer un Program Unit específico
            print(f"INFO: Buscando Program Unit: {specific_pu}\n")
            result = extract_single_program_unit(xml_file, specific_pu, remove_comments)
            
            if result is None:
                print(f"ERROR: No se encontro el Program Unit '{specific_pu}' en el archivo XML")
                sys.exit(1)
            
            # Preparar datos para JSON (siempre)
            output = {
                "program_unit": result,
                "source_file": str(xml_file)
            }
            
            # Guardar archivo JSON (siempre)
            json_file = Path(f"pu_{result['name']}.json")
            with json_file.open("w", encoding="utf-8") as f:
                json.dump(output, f, indent=2, ensure_ascii=False)
            
            if output_json:
                # Solo mostrar JSON en consola si se solicita
                print(json.dumps(output, indent=2, ensure_ascii=False))
                print(f"\nOK: Program Unit guardado en: {json_file}")
            else:
                # Salida formateada en consola
                print("="*70)
                print(f"PROGRAM UNIT: {result['name']}")
                print(f"Tipo: {result['type']}")
                print("="*70)
                print(result['code'])
                print()
                
                # Guardar en archivo SQL
                sql_file = Path(f"pu_{result['name']}.sql")
                with sql_file.open("w", encoding="utf-8") as f:
                    f.write(f"-- PROGRAM UNIT: {result['name']}\n")
                    f.write(f"-- Tipo: {result['type']}\n")
                    f.write("-- " + "="*68 + "\n\n")
                    f.write(result['code'])
                    f.write("\n")
                
                print("OK: Archivos guardados:")
                print(f"   SQL: {sql_file}")
                print(f"   JSON: {json_file}")
        
        else:
            # Extraer TODOS los Program Units
            print("INFO: Extrayendo todos los Program Units\n")
            program_units = extract_all_program_units(xml_file, remove_comments)
            
            if not program_units:
                print("WARN: No se encontraron Program Units en el archivo XML")
                sys.exit(0)
            
            # Preparar datos para JSON (siempre)
            output = {
                "source_file": str(xml_file),
                "program_unit_count": len(program_units),
                "program_units": program_units
            }
            
            # Guardar archivo JSON (siempre)
            json_file = Path(f"program_units_all.json")
            with json_file.open("w", encoding="utf-8") as f:
                json.dump(output, f, indent=2, ensure_ascii=False)
            
            if output_json:
                # Solo mostrar JSON en consola si se solicita
                print(json.dumps(output, indent=2, ensure_ascii=False))
                print(f"\nOK: Program Units guardados en: {json_file}")
            else:
                # Salida formateada
                print("="*70)
                print(f"PROGRAM UNITS ENCONTRADOS: {len(program_units)}")
                print("="*70)
                
                for idx, (pu_name, pu_info) in enumerate(sorted(program_units.items()), 1):
                    print(f"\n[{idx}] {pu_name} ({pu_info['type']})")
                    print("-"*70)
                    # Mostrar primeras líneas del código
                    code_lines = pu_info['code'].split('\n')
                    preview_lines = min(5, len(code_lines))
                    print('\n'.join(code_lines[:preview_lines]))
                    if len(code_lines) > preview_lines:
                        print(f"... ({len(code_lines) - preview_lines} líneas más)")
                    print()
                
                # Guardar en archivo consolidado SQL
                sql_file = Path(f"program_units_all.sql")
                with sql_file.open("w", encoding="utf-8") as f:
                    f.write(f"-- PROGRAM UNITS EXTRAÍDOS DE: {xml_file.name}\n")
                    f.write(f"-- Total: {len(program_units)}\n")
                    f.write("-- " + "="*68 + "\n\n")
                    
                    for pu_name, pu_info in sorted(program_units.items()):
                        f.write(f"-- PROGRAM UNIT: {pu_name}\n")
                        f.write(f"-- Tipo: {pu_info['type']}\n")
                        f.write("-- " + "-"*68 + "\n")
                        f.write(pu_info['code'])
                        f.write("\n\n" + "-- " + "="*68 + "\n\n")
                
                # También guardar cada uno en archivos individuales
                print("\nINFO: Guardando archivos individuales...")
                pu_dir = Path("program_units")
                pu_dir.mkdir(exist_ok=True)
                
                for pu_name, pu_info in program_units.items():
                    # Limpiar nombre de archivo
                    safe_name = pu_name.replace('$', '_').replace('#', '_')
                    pu_file = pu_dir / f"{safe_name}.sql"
                    with pu_file.open("w", encoding="utf-8") as f:
                        f.write(f"-- PROGRAM UNIT: {pu_name}\n")
                        f.write(f"-- Tipo: {pu_info['type']}\n")
                        f.write("-- " + "="*68 + "\n\n")
                        f.write(pu_info['code'])
                        f.write("\n")
                
                print("\nOK: Archivos generados:")
                print(f"   SQL consolidado: {sql_file}")
                print(f"   JSON completo: {json_file}")
                print(f"   Individuales ({len(program_units)}): {pu_dir}/")
    
    except ET.ParseError as e:
        print(f"ERROR: Error al parsear XML: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
