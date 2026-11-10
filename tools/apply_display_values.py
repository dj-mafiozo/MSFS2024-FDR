"""Attach audited display dictionaries to Pascal catalogs, also after regeneration.
Numeric keys are raw recorded values; values are cockpit labels, never translated.
Only explicit SDK enumerations and typed booleans are inferred, never numeric ranges.
"""
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[1]
CATALOGS={
 'src/Telemetry/TelemetryCatalogU.pas':'TSimField',
 'src/Aircraft/iFly/iFlySDKCatalogU.pas':'TSDKField',
 'src/Aircraft/PMDG/PMDGNG3CatalogU.pas':'TPMDGField',
 'src/Aircraft/PMDG/PMDG777CatalogU.pas':'TPMDG777Field',
 'src/Aircraft/Fenix/FenixCatalogU.pas':'TFenixField',
 'src/Aircraft/FBW/FBWCatalogU.pas':'TFBWField',
}
PREFIXES={'iFlySDKCatalogU':'iFlySDK','PMDGNG3CatalogU':'PMDGNG3','PMDG777CatalogU':'PMDG777','FenixCatalogU':'FenixLVar','FBWCatalogU':'FBWLVar','TelemetryCatalogU':''}
for provider in ['PMDGDC6','CSS737','MaddogX','SkySimDC9','SkySimMD11','TFDiMD11','AsoboBell407','AsoboEC135']:
 CATALOGS['src/Aircraft/'+('PMDG' if provider=='PMDGDC6' else provider)+'/'+provider+'LVarsU.pas']='TAddonLVarField'
 PREFIXES[provider+'LVarsU']=provider
AUDIT_PATH=ROOT/'support/display-values/catalog.json'
AUDITED=json.loads(AUDIT_PATH.read_text(encoding='utf-8-sig'))['mappings'] if AUDIT_PATH.is_file() else {}
BOEING=r'0=UP\r\n1=1\r\n2=2\r\n3=5\r\n4=10\r\n5=15\r\n6=25\r\n7=30\r\n8=40'
AIRBUS=r'0=0\r\n1=1\r\n2=2\r\n3=3\r\n4=FULL'
OVERRIDES={
 ('iFlySDKCatalogU','FLAP_Status'):BOEING,
 ('iFlySDKCatalogU','Autobrake_Selector_Status'):r'0=RTO\r\n1=DISARMED\r\n2=1\r\n3=2\r\n4=3\r\n5=MAX',
 ('PMDGNG3CatalogU','MAIN_AutobrakeSelector'):r'0=RTO\r\n1=DISARMED\r\n2=1\r\n3=2\r\n4=3\r\n5=MAX',
 ('PMDG777CatalogU','FCTL_Flaps_Lever'):r'0=UP\r\n1=1\r\n2=5\r\n3=15\r\n4=20\r\n5=25\r\n6=30',
 ('FenixCatalogU','S_FC_FLAPS'):AIRBUS,
 ('FenixCatalogU','S_MIP_GEAR'):r'0=UP\r\n1=DOWN',
 ('FBWCatalogU','A32NX_FLAPS_HANDLE_INDEX'):AIRBUS,
 ('TelemetryCatalogU','gear_handle_position'):r'0=UP\r\n1=DOWN',
 ('TelemetryCatalogU','sim_on_ground'):r'0=AIRBORNE\r\n1=GROUND',
 ('TelemetryCatalogU','engine_type'):r'0=PISTON\r\n1=JET\r\n2=NONE\r\n3=HELO TURBINE\r\n4=UNSUPPORTED\r\n5=TURBOPROP\r\n6=ELECTRIC',
 ('TelemetryCatalogU','flaps_handle_index'):'', # Per-ICAO dictionaries live in FlapsHandleU.
}
def literals(s):return ''.join(x.replace("''", "'") for x in re.findall(r"'((?:[^']|'')*)'",s))
def display(stem,name,line):
 if (stem,name) in OVERRIDES:return OVERRIDES[stem,name]
 prefix=PREFIXES.get(stem,'')
 key=(prefix+'.' if prefix else '')+name
 if key in AUDITED:return r'\r\n'.join(k+'='+v for k,v in AUDITED[key]['values'].items())
 if stem=='TelemetryCatalogU':
  if name.startswith('turb_eng_ignition_switch_ex1'):return r'0=OFF\r\n1=AUTO\r\n2=ON'
  if name.startswith('turb_eng_condition_lever_position'):return r'0=CUTOFF\r\n1=LOW IDLE\r\n2=HIGH IDLE'
  if name.startswith('bleed_air_source_control'):return r'0=AUTO\r\n1=OFF\r\n2=APU\r\n3=ENGINES'
  if name=='pitot_heat_switch':return r'0=OFF\r\n1=ON\r\n2=AUTO'
  if name.startswith('gear_warning_'):return r'0=NONE\r\n1=GEAR UP\r\n2=AMPHIBIOUS GEAR UP\r\n3=AMPHIBIOUS GEAR DOWN\r\n4=ON GROUND HANDLE UP'
 if re.search(r"Units\s*:\s*'Bool'|Kind\s*:\s*'bool'",line,re.I):return r'0=OFF\r\n1=ON'
 if stem=='FBWCatalogU' and re.search(r'_(IS_ON|IS_AUTO|HAS_FAULT|IS_AVAILABLE|IS_ACTIVE)$',name):return r'0=OFF\r\n1=ON'
 desc=literals(line.split('Description:',1)[-1]) if 'Description:' in line else ''
 # Multi-position SDK descriptions with complete explicit labels only.
 items=list(re.finditer(r'(?<![\w.\-])(-?\d+)\s*[:=]\s*',desc))
 if len(items)<2 or len(items)>20:return ''
 pairs=[]
 for i,m in enumerate(items):
  text=desc[m.end():items[i+1].start() if i+1<len(items) else len(desc)].strip(' ,;')
  text=re.sub(r'^(?:switch|selector|lever|light|position)\s*','',text,flags=re.I).strip()
  if not text or len(text)>45 or re.search(r'\.\.|\b(?:see|otherwise|range)\b|[<>\r\n]',text,re.I):return ''
  pairs.append(m[1]+'='+text)
 if len({p.split('=')[0] for p in pairs})!=len(pairs):return ''
 return r'\r\n'.join(pairs)
def update_catalog(path,check=False):
 path=Path(path);text=path.read_text(encoding='utf-8-sig');original=text
 kind=next((v for k,v in CATALOGS.items() if Path(k).name==path.name),None)
 if not kind:return
 pat=r'('+kind+r'\s*=\s*Record)(.*?)(\bEnd\s*;)'
 def declaration(m):
  if re.search(r'\bDisplayValue\b',m[2],re.I):return m[0]
  return m[1]+m[2]+' DisplayValue : String;\n  '+m[3]
 text=re.sub(pat,declaration,text,count=1,flags=re.I|re.S)
 count=0
 def row(m):
  nonlocal count
  line=m[0];name=re.search(r"Name\s*:\s*'([^']+)'",line)[1]
  line=re.sub(r";\s*DisplayValue\s*:\s*'(?:[^']|'')*'(?:\s*\+\s*'(?:[^']|'')*')*",'',line)
  value=display(path.stem,name,line);count+=bool(value)
  pos=line.rfind(')')
  # A generated final row may close both the record and its enclosing array.
  if line[:pos].rstrip().endswith(')'):pos=line.rfind(')',0,pos)
  literal="+".join("'"+value[i:i+120].replace("'","''")+"'" for i in range(0,len(value),120)) or "''"
  return line[:pos]+"; DisplayValue: "+literal+line[pos:]
 tail=''
 if path.stem=='TelemetryCatalogU':
  pos=re.search(r'\bNumericColumns\s*:',text).start()
  tail=re.sub(r";\s*DisplayValue\s*:\s*'(?:[^']|'')*'(?:\s*\+\s*'(?:[^']|'')*')*",'',text[pos:]);text=text[:pos]
 text=re.sub(r'^.*\(\s*(?:Provider\s*:[^;]+;\s*)?Name\s*:.*$',row,text,flags=re.M)+tail
 if check:
  # Compare decoded per-field dictionaries; formatter may split literal chunks.
  expected={re.search(r"Name\s*:\s*'([^']+)'",m[0])[1]:literals(m[0].split('DisplayValue:',1)[-1]) for m in re.finditer(r"^.*\(\s*(?:Provider\s*:[^;]+;\s*)?Name\s*:.*$",text,flags=re.M)}
  actual={re.search(r"Name\s*:\s*'([^']+)'",m[0])[1]:literals(m[0].split('DisplayValue:',1)[-1]) for m in re.finditer(r"^.*\(\s*(?:Provider\s*:[^;]+;\s*)?Name\s*:.*$",original,flags=re.M)}
  assert expected==actual,('Display dictionaries stale',path)
 elif text!=original:path.write_text(text,encoding='utf-8-sig',newline='\r\n')
 return count
if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
 for name in CATALOGS:print(name,update_catalog(ROOT/name,a.check),'display dictionaries')
