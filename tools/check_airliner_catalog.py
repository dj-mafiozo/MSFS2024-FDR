"""Verify imported AIRLINER metadata and the compiled Pascal catalog agree."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parents[1]
catalog = json.loads((root/'support/airliner/catalog.json').read_text(encoding='utf-8'))
text = (root/'src/telemetry/AirlinerCatalogU.pas').read_text(encoding='utf-8-sig')
count = int(re.search(r'AirlinerVarCount\s*=\s*(\d+)', text)[1])
names = re.findall(r"'([^']+)'", re.split(r'AirlinerNames\s*:', text, maxsplit=1, flags=re.I)[1].split('AirlinerUnits')[0])
units = re.findall(r"'([^']*)'", re.split(r'\bimplementation\b', re.split(r'AirlinerUnits\s*:', text, maxsplit=1, flags=re.I)[1], maxsplit=1, flags=re.I)[0])
assert count == catalog['count'] == len(names) == len(units)
assert len(set(n.casefold() for n in names)) == count
assert names == [field['name'] for field in catalog['fields']]
assert units == [field['units'][0] for field in catalog['fields']]
assert all('airliner' in name.lower() and not any(c in name for c in '#${}') for name in names)
assert all(field['sources'] and field['units'] for field in catalog['fields'])
print(f'PASS: {count} AIRLINER catalog fields match source provenance and units.')
