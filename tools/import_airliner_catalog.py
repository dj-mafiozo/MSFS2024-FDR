"""Import literal numeric L:*airliner* names from a supplied source-file list.

Use rg -l -i airliner <package-root> -g '*.js' -g '*.xml' to prepare the list.
Only names, units and provenance are retained, never instrument source code.
"""
import argparse
import hashlib
import json
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('file_list', type=pathlib.Path)
args = parser.parse_args()
found = {}
sources = []
js = re.compile(r'''(?:GetSimVarValue|SetSimVarValue)\s*\(\s*(['"])(L:[^'"\r\n]*airliner[^'"\r\n]*)\1\s*,\s*(['"])([^'"\r\n]*)\3''', re.I)
xml = re.compile(r'\(\s*(?:>|&gt;)?(L:[^,()\r\n]*airliner[^,()\r\n]*),\s*([^()]+)\)', re.I)
for filename in args.file_list.read_text(encoding='utf-8-sig').splitlines():
    path = pathlib.Path(filename)
    raw = path.read_bytes()
    text = raw.decode('utf-8-sig', errors='replace')
    # Provenance relative to the package; no user-specific absolute paths.
    parts = path.parts
    pivot = max((i for i, part in enumerate(parts) if part.lower() in ('packages', 'community', 'streamedpackages')), default=-1)
    source = '/'.join(parts[pivot+1:]) if pivot >= 0 else path.name
    hits = [(m[2], m[4]) for m in js.finditer(text)]
    hits += [(m[1], m[2]) for m in xml.finditer(text)]
    used = False
    for name, unit in hits:
        name, unit = name[2:].strip(), unit.strip()
        # Exclude concatenated/interpolated expressions and dynamic name templates.
        if not re.fullmatch(r'[A-Za-z0-9_:. -]+', name) or unit.lower() == 'string':
            continue
        key = name.upper()
        entry = found.setdefault(key, {'name': name, 'units': [], 'sources': []})
        if unit.lower() not in [u.lower() for u in entry['units']]:
            entry['units'].append(unit)
        if source not in entry['sources']:
            entry['sources'].append(source)
        used = True
    if used:
        sources.append({'path': source, 'sha256': hashlib.sha256(raw).hexdigest()})
first = ['AIRLINER_V1_SPEED', 'AIRLINER_VR_SPEED', 'AIRLINER_V2_SPEED',
         'AIRLINER_MINIMUM_DESCENT_ALTITUDE', 'AIRLINER_DECISION_HEIGHT']
missing = set(first) - found.keys()
if missing:
    raise SystemExit(f'Expected core names absent: {missing}')
names = first + sorted(found.keys() - set(first))
entries = [dict(found[n], name=n) for n in names]
for entry in entries:
    entry['units'].sort(key=lambda u: u.lower() in ('number', 'enum', ''))
manifest = {'scope': 'Literal numeric L:*airliner* names in supplied installed instrument sources; not runtime enumeration.',
            'count': len(entries), 'fields': entries, 'sources': sources}
(root/'support/airliner/catalog.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
def quote(text):
    return "'" + text.replace("'", "''") + "'"
lines = ['unit AirlinerCatalogU;', 'interface', f'const AirlinerVarCount={len(entries)};',
         f'AirlinerNames:array[0..{len(entries)-1}] of string=(']
lines += ['  '+quote(e['name'])+(',' if i<len(entries)-1 else ');') for i,e in enumerate(entries)]
lines += [f'AirlinerUnits:array[0..{len(entries)-1}] of string=(']
lines += ['  '+quote(e['units'][0])+(',' if i<len(entries)-1 else ');') for i,e in enumerate(entries)]
lines += ['implementation', 'end.']
(root/'src/telemetry/AirlinerCatalogU.pas').write_text('\n'.join(lines)+'\n', encoding='utf-8')
print(f'PASS: imported {len(entries)} numeric L:*airliner* names from {len(sources)} instrument files.')
print('\n'.join(names))
