"""Import only FSLTL model animation/ICAO facts and hashes; never model assets."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[1]
def pascal_tokens(text):
 pattern=r"'(?:[^']|'')*'|//[^\n]*|\{[^}]*\}|\(\*[\s\S]*?\*\)|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]"
 return [t if t.startswith("'") else t.lower() for t in re.findall(pattern,text) if not t.startswith(('//','{','(*'))]

def render(data):
 rows=sorted(data['profiles'].items());lines=['// Generated from the local FSLTL Base repository; parameter facts only.',f' FSLTLProfileCount = {len(rows)};',' FSLTLProfiles:array[0..FSLTLProfileCount-1]of TFSLTLProfile = (']
 for i,(name,row) in enumerate(rows):
  label='|'.join(row['inputs']).replace("'","''");chunks=[label[j:j+115] for j in range(0,len(label),115)] or ['']
  lines.append("  (Prefix:'"+name+"';ICAO:'"+row['icao']+"';Inputs:"+'+'.join("'"+v+"'" for v in chunks)+')'+(',' if i+1<len(rows) else ');'))
 return '\n'.join(lines)+'\n'
def import_source(source):
 base=source/'fsltl-traffic-base';templates={};types={};hashes={}
 for p in (base/'ModelBehaviorDefs').rglob('*.xml'):
  text=p.read_text(encoding='utf-8-sig',errors='replace')
  for m in re.finditer(r'<Template\s+Name="([^"]+)"[^>]*>([\s\S]*?)</Template>',text,re.I):templates[m[1]]=m[2]
 def inputs(text,seen=None):
  seen=set() if seen is None else seen;result={v.strip().upper() for v in re.findall(r'\(A:([^,)]+)',text,re.I)}
  for name in re.findall(r'<UseTemplate\s+Name\s*=\s*"([^"]+)"',text,re.I):
   if name in templates and name not in seen:seen.add(name);result.update(inputs(templates[name],seen))
  return result
 for folder in (base/'SimObjects/Airplanes').iterdir():
  if not folder.is_dir():continue
  xmls=list(folder.glob('model*/*.xml'))
  if not xmls:continue
  cfg=folder/'aircraft.cfg';text=cfg.read_text(encoding='utf-8-sig',errors='replace') if cfg.exists() else ''
  match=re.search(r'^icao_type_designator\s*=\s*"?([^";\r\n]+)',text,re.I|re.M);icao=match[1].strip().upper() if match else folder.name.removeprefix('FSLTL_').split('_')[0];values=set()
  for p in xmls:values.update(inputs(p.read_text(encoding='utf-8-sig',errors='replace')));hashes[p.relative_to(source).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
  types[folder.name]={'icao':icao,'inputs':sorted(values),'reverse':any('TURB ENG JET THRUST' in v for v in values),'model_xmls':len(xmls)}
 return {'source_commit':subprocess.check_output(['git','-C',str(source),'rev-parse','HEAD'],text=True).strip(),'profiles':types,'sources':hashes}
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',type=Path);p.add_argument('--check',action='store_true');a=p.parse_args();facts=ROOT/'support/fsltl/profiles.json';output=ROOT/'src/Visualization/FSLTLProfiles.inc'
 if a.check:
  data=json.loads(facts.read_text(encoding='utf-8'));assert pascal_tokens(output.read_text(encoding='utf-8-sig'))==pascal_tokens(render(data)),'Regenerate FSLTLProfiles.inc'
  assert all(v['inputs']==sorted(set(v['inputs'])) for v in data['profiles'].values());assert all(re.fullmatch('[0-9a-f]{64}',v) for v in data['sources'].values())
 else:
  if not a.source:p.error('--source must name the local FSLTL Base clone')
  data=import_source(a.source);facts.parent.mkdir(exist_ok=True);facts.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8');output.write_text(render(data),encoding='utf-8')
 print('PASS:',len(data['profiles']),'FSLTL families and',len(data['sources']),'model XML hashes; fact-only generated profiles.')
