#!/usr/bin/env python3
import re
import zipfile

file_path = 'report6.xls'

try:
    # Try to read as ZIP (newer Excel formats)
    with zipfile.ZipFile(file_path, 'r') as zip_ref:
        print("File is a ZIP/newer Excel format")
        files = zip_ref.namelist()
        print("Files in archive:", files[:10])
except:
    # It's an OLE2 format (older .xls), try to extract strings
    with open(file_path, 'rb') as f:
        content = f.read()

    # Convert to string with error handling
    try:
        text_content = content.decode('utf-16-le', errors='ignore')
    except:
        text_content = content.decode('latin-1', errors='ignore')

    # Find dates and transaction IDs
    print("=== JASPER EXCEL DATA ANALYSIS ===\n")

    # Look for 4-digit transaction IDs (900xxx pattern)
    transaction_ids = re.findall(r'9\d{4}', text_content)
    if transaction_ids:
        unique_ids = sorted(set(transaction_ids))
        print(f"Found transaction IDs: {unique_ids[:20]}")  # First 20
        print(f"ID Range: {min(unique_ids)} to {max(unique_ids)}")
        print(f"Total records: {len(transaction_ids) // 2}")  # Approximate

    # Look for dates
    dates = re.findall(
        r'(?:0[1-9]|[12][0-9]|3[01])-(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)-2026', text_content, re.IGNORECASE)
    if dates:
        unique_dates = sorted(set(dates))
        # First and last 5
        print(f"\nFound dates: {unique_dates[:5]}...{unique_dates[-5:]}")
        print(f"Date range: {min(unique_dates)} to {max(unique_dates)}")

    # Look for status codes
    statuses = re.findall(
        r'(?:APROBADA|RECHAZADA|RECH|APR|PEN|DECLINADA|DECLINADA POR BANCO)', text_content)
    if statuses:
        unique_statuses = set(statuses)
        print(f"\nFound statuses: {unique_statuses}")

    # Print raw preview
    print(f"\n=== DATA PREVIEW ===")
    # Find a transaction record in the text
    lines = text_content.split('\n')
    data_lines = [l for l in lines if re.search(
        r'9\d{4}.*20(0|1|2)[0-9]-', l)][:10]
    for i, line in enumerate(data_lines, 1):
        print(f"{i}: {line[:120]}")
