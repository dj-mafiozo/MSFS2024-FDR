"""Audit installed official-aircraft locpaks. Emits metadata and numeric binding catalogs only.
No encrypted archives are opened; translated tooltip names never become variables.
"""
from pathlib import Path
import argparse,collections,hashlib,json,re
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--packages-root',type=Path,required=True,help='Directory containing Official2020 and Official2024')
p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);a=p.parse_args()
units={'bool','boolean','enum','number','percent','degrees','radians','feet','knots','seconds','volts','amps','mhz','khz','hertz','celsius','fahrenheit','inches of mercury','millibars','psi','gallons','pounds','rpm','position'}
report=[];profiles=[]
for store in ['Official2020','Official2024']:
 base=a.packages_root/store/'OneStore'
 if not base.exists():continue
 for package in sorted(base.iterdir()):
  if not package.is_dir() or not any(t in package.name.lower() for t in ['aircraft','plane','helicopter']):continue
  # All locale files, including nested directories; only JSON, never fsarchive.
  files=sorted(package.rglob('*.locpak'))
  if not files:continue
  counts=collections.Counter();sources=[];keys=set()
  for src in files:
   raw=src.read_bytes();strings=json.loads(raw.decode('utf-8-sig'))['LocalisationPackage']['Strings'];keys.update(strings)
   sources.append({'file':src.relative_to(package).as_posix(),'sha256':hashlib.sha256(raw).hexdigest(),'keys':len(strings)})
   found=set()
   for val in strings.values():
    for kind,name,unit in re.findall(r'\(\s*([LA]):([^,)]+),\s*([^)]*)\)',val,re.I):
     kind=kind.upper();name=name.strip();unit=unit.strip().lower()
     if re.fullmatch(r'[A-Za-z_][A-Za-z0-9_ .:\-\[\]]*',name) and unit in units:found.add((kind,name,unit))
   counts.update(found)
  fields=[{'name':('A:' if k=='A' else '')+n,'source_units':u,'locale_count':c} for (k,n,u),c in sorted(counts.items()) if c>=max(3,(len(files)+1)//2)]
  entry={'store':store,'package':package.name,'sources':sources,'key_count':len(keys),'airliner_keys':[k for k in sorted(keys) if 'AIRLINER' in k.upper()],
   'consensus_bindings':fields,'subscription_evidence':'Literal numeric bindings unchanged in at least half of installed locales (minimum three). Translation identifiers are not runtime variables.'}
  report.append(entry)
  identity={'microsoft-aircraft-bell407':('AsoboBell407','Microsoft Bell 407'),'microsoft-aircraft-ec135':('AsoboEC135','Microsoft EC135')}.get(package.name)
  if fields and identity:profiles.append({'provider':identity[0],'label':identity[1],'sources':sources,'fields':fields,'aircraft_titles':[]})
out=a.root/'support/official-aircraft';out.mkdir(parents=True,exist_ok=True)
(out/'locpak-audit.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
(out/'binding-profiles.json').write_text(json.dumps(profiles,indent=2)+'\n',encoding='utf8')
print('Audited',len(report),'packages;',sum(len(x['sources']) for x in report),'locale files;',[(x['provider'],len(x['fields'])) for x in profiles])
