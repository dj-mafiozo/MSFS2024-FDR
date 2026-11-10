"""Validate generated aircraft catalogs without requiring commercial add-ons."""
from pathlib import Path
import re,json
r=Path(__file__).resolve().parents[1]
s=(r/'src/Aircraft/AddonLVarCatalogU.pas').read_text(encoding='utf-8-sig')
metadata=json.loads((r/'support/addon-lvars/fields.json').read_text(encoding='utf-8'))
assert len(metadata)==8
assert sum(x['literal_read_count'] for x in metadata)==int(re.search(r'AddonFieldCount\s*=\s*(\d+)',s)[1])
all_source="\n".join(p.read_text(encoding="utf-8-sig") for p in (r/"src/Aircraft").rglob("*LVarsU.pas"))
catalog_names={name.replace("''","'") for name in re.findall(r"\bName\s*:\s*'((?:''|[^'])*)'",all_source,re.I)}
for x in metadata:
 assert len(x['fields'])==x['literal_read_count']
 assert len({v['name'] for v in x['fields']})==len(x['fields'])
 for field in x['fields']:
  assert field['name'] in catalog_names,field['name']
  assert '#' not in field['name'] and not field['name'].startswith(':')
 for source in x['sources']:assert re.fullmatch('[0-9a-f]{64}',source['sha256'])
p=json.loads((r/'support/pmdg777/fields.json').read_text(encoding='utf-8'))
s=(r/'src/Aircraft/PMDG/PMDG777CatalogU.pas').read_text(encoding='utf-8-sig')
assert p['field_count']==len(p['fields'])==int(re.search(r'PMDG777FieldCount\s*=\s*(\d+)',s)[1])
assert p['struct_size']==int(re.search(r'PMDG777DataSize\s*=\s*(\d+)',s)[1])
for f in p['fields']:assert f['offset']+f['size']<=p['struct_size']
assert p['sha256'] in s
print('PASS: eight aircraft profiles, '+str(sum(x['literal_read_count'] for x in metadata))+' literal fields, source provenance and '+str(p['field_count'])+' typed PMDG777 fields.')
