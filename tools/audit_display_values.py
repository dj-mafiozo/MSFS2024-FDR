"""Audit local SDK/XML display labels without redistributing proprietary source code.
Emit only variable/value labels, source hashes and extraction rules. Runtime never
needs the installed aircraft XML or SDK. No commands are sent to the simulator.
"""
from pathlib import Path
import argparse,hashlib,json,re,unicodedata,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
PROVIDERS={
 'flybywire-aircraft-a320-neo':'FBWLVar','fnx-aircraft-a32x-common':'FenixLVar','fnx-aircraft-320':'FenixLVar',
 'ifly-aircraft-737max8':'iFlySDK','pmdg-aircraft-dc6':'PMDGDC6',
 'css-aircraft-b737-300':'CSS737','css-aircraft-b737-400':'CSS737','css-aircraft-b737-500':'CSS737','lsh-maddogx-aircraft':'MaddogX',
 'skysim-aircraft-dc9':'SkySimDC9','skysim-aircraft-md11':'SkySimMD11',
 'tfdidesign-aircraft-md11':'TFDiMD11'}
PREFIX={'iFlySDKCatalogU':'iFlySDK','PMDGNG3CatalogU':'PMDGNG3','PMDG777CatalogU':'PMDG777','FenixCatalogU':'FenixLVar','FBWCatalogU':'FBWLVar','TelemetryCatalogU':''}
def enum_labels(description):
 """Read explicitly numbered labels, including partial documented enumerations.
 Ellipses never imply the values between endpoints. Ranges alone are not enums.
 """
 text=unicodedata.normalize('NFKC',description)
 markers=list(re.finditer(r'(?<![\w.\-~])(-?\d+(?:\.\d+)?)\s*[:=]\s*',text))
 if len(markers)<2:return {}
 result={}
 for i,m in enumerate(markers):
  value=format(float(m[1]),'.15g')
  label=text[m.end():markers[i+1].start() if i+1<len(markers) else len(text)].strip(' ,;')
  label=re.split(r'\.{2,}|\b(?:Note|This|When|where|which|See|for Capt|reverse sequence)\b',label,flags=re.I)[0].strip(' ,;')
  label=re.sub(r'^(?:switch|selector|lever|light|position|switchUP)\s*','',label,flags=re.I)
  # Remove trailing explanatory sentences, not cockpit punctuation such as T.O.
  label=re.sub(r'\s*\((?:\d.*?(?:momentary|momnentary).*|.*?only|.*?steps)\).*$', '',label,flags=re.I)
  label=label.strip().strip(' ,;\"\'').strip()
  if label.endswith('.') and not label.endswith('T.O.'):label=label[:-1].rstrip()
  if not label or '~' in label or len(label)>55 or re.search(r'[<>\r\n]|[\u3400-\u9fff]|\b(?:otherwise|range|corresponds)\b',label,re.I):continue
  label=label.upper()
  if value in result and result[value]!=label:return {}
  result[value]=label
 return result if len(result)>=2 else {}
def indexed_labels(node):
 result={}
 for p in node:
  match=re.fullmatch(r'ANIMTIP_(\d+)',p.tag)
  if not match:continue
  text=(p.text or '').strip()
  if not text or len(text)>55 or ('TT:' in text or any(c in text for c in '#<>')):return {}
  result[match[1]]=text.upper()
 return result if len(result)>=2 else {}
def momentary_labels(node):
 """Only explicit matching press=1/release=0 writes, never template-name guesses."""
 press=(node.findtext('LEFT_SINGLE_CODE') or '').strip()
 release=(node.findtext('LEFT_LEAVE_CODE') or node.findtext('LEFT_RELEASE_CODE') or '').strip()
 pattern=r'([01])\s*\(>L:([A-Za-z_][A-Za-z_0-9]*)(?:\s*,\s*\w+)?\)'
 a=re.fullmatch(pattern,press);b=re.fullmatch(pattern,release)
 if a and b and a[1]=='1' and b[1]=='0' and a[2]==b[2]:return a[2],{'0':'RELEASED','1':'PRESSED'}
 return None

def audit(community,ifly_header,pmdg_header,pmdg777_header):
 from apply_display_values import CATALOGS,literals,display
 known={};old={};sources=[];source_ids={};mappings={};conflicts={};scanned={}
 def source(path,label):
  label=str(label).replace('\\','/')
  if label not in source_ids:
   source_ids[label]=len(sources);sources.append({'file':label,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
  return source_ids[label]
 def add(key,values,src,rule):
  if key not in known or not values or key in conflicts:return
  normalized={str(k):str(v) for k,v in values.items()}
  if key in mappings:
   merged=dict(mappings[key]['values'])
   for k,v in normalized.items():
    if k in merged and merged[k]!=v:
     conflicts[key]={'values':[mappings[key]['values'],normalized],'sources':mappings[key]['sources']+[src]};del mappings[key];return
    merged[k]=v
   mappings[key]['values']=merged
   if src not in mappings[key]['sources']:mappings[key]['sources'].append(src)
  else:mappings[key]={'values':normalized,'sources':[src],'rule':rule}
 for rel in CATALOGS:
  stem=Path(rel).stem
  if stem not in PREFIX:continue
  prefix=PREFIX[stem]
  for line in (ROOT/rel).read_text(encoding='utf-8-sig').splitlines():
   n=re.search(r"\(Name:\s*'([^']+)'",line)
   if n:
    key=(prefix+'.' if prefix else '')+n[1];known[key]=(stem,line);old[key]=bool(display(stem,n[1],line))
 addon=json.loads((ROOT/'support/addon-lvars/fields.json').read_text(encoding='utf-8-sig'))
 for provider in addon:
  for field in provider['fields']:known[provider['provider']+'.'+field['name']]=('addon',field)
 for prefix,path,encoding in [('iFlySDK',ifly_header,'gb18030'),('PMDGNG3',pmdg_header,'utf-8-sig'),('PMDG777',pmdg777_header,'utf-8-sig')]:
  if not path.is_file():raise FileNotFoundError(path)
  catalog,constant={'iFlySDK':('src/Aircraft/iFly/iFlySDKCatalogU.pas','SDKHeaderSHA256'),'PMDGNG3':('src/Aircraft/PMDG/PMDGNG3CatalogU.pas','PMDGHeaderSHA256'),'PMDG777':('src/Aircraft/PMDG/PMDG777CatalogU.pas','PMDG777HeaderSHA256')}[prefix]
  expected=re.search(constant+r"\s*=\s*'([^']+)'",(ROOT/catalog).read_text(encoding='utf-8-sig'))[1]
  if hashlib.sha256(path.read_bytes()).hexdigest()!=expected:raise ValueError('SDK version does not match compiled catalog: '+prefix)
  text=path.read_bytes().decode(encoding);src=source(path,prefix+'/'+path.name)
  comments=dict(re.findall(r'\b([A-Za-z_]\w*)(?:\s*\[[^\]]+\])*\s*;\s*//([^\r\n]*)',text))
  scanned[prefix]={'header_fields_with_comments':len(comments),'encoding':encoding}
  for key in known:
   if not key.startswith(prefix+'.'):continue
   base=key.split('.',1)[1].split('[')[0];description=comments.get(base,'')
   if not description:continue
   # These compact captain/FO selectors explicitly reverse their endpoint order.
   if 'reverse sequence for FO' in description:continue
   add(key,enum_labels(description),src,'sdk_explicit_enum')
  if prefix=='iFlySDK':
   add('iFlySDK.iFly737MAX_STATE',{'0':'NOT RUNNING','1':'RUNNING'},src,'sdk_defines')
   enum=re.search(r'enum\s+PLANE_LIST\s*\{(.*?)\}',text,re.S)
   if enum:
    names=re.findall(r'\biFly737MAX_(\d+)\b',enum[1]);add('iFlySDK.Aircraft_Model',{str(i):'737 MAX '+n for i,n in enumerate(names)},src,'sdk_enum_declaration')
   add('iFlySDK.LandingLlightAlternateFlash',{'0':'NOT INSTALLED','1':'INSTALLED'},src,'sdk_chinese_comment_translation')
 fbw=ROOT/'support/fbw/variables.json';src=source(fbw,'support/fbw/variables.json')
 for name,item in json.loads(fbw.read_text(encoding='utf-8-sig'))['variables'].items():
  values=enum_labels(item.get('remark',''))
  if not values and item.get('values','').replace(' ','') in ['0|1','0->1']:
   values={'0':'OFF','1':'ON'}
  add('FBWLVar.'+name,values,src,'fbw_documented_enum_or_boolean')
 for pkg,prefix in PROVIDERS.items():
  base=community/pkg
  if not base.is_dir():scanned[pkg]={'missing':True};continue
  parsed=0;bad=0
  for path in sorted(base.rglob('*.xml')):
   try:
    root=ET.parse(path).getroot();nodes=list(root.iter('UseTemplate'));parsed+=1
   except (ET.ParseError,UnicodeError):
    # Some vendor cockpit files contain malformed, unrelated XML sections.
    # Recover only independently valid UseTemplate fragments, without changing
    # the installed file or interpreting broken fragments as evidence.
    bad+=1;nodes=[]
    raw=path.read_text(encoding='utf-8-sig',errors='replace')
    raw=re.sub(r'<!--[\s\S]*?-->','',raw)
    for fragment in re.findall(r'<UseTemplate\b[^>]*>[\s\S]*?</UseTemplate>',raw):
     try:nodes.append(ET.fromstring(fragment))
     except ET.ParseError:pass
   src=source(path,Path(pkg)/path.relative_to(base))
   for node in nodes:
    labels=indexed_labels(node)
    if labels:
     for p in node:
      if p.tag=='VAR_NAME' or p.tag in ['VAR_NAME_LEFT','VAR_NAME_RIGHT']:
       name=(p.text or '').strip();add(prefix+'.'+name,labels,src,'xml_indexed_animtip')
    held=momentary_labels(node)
    if held:add(prefix+'.'+held[0],held[1],src,'xml_explicit_press_release')
  scanned[pkg]={'xml_files':parsed,'unreadable_xml_files':bad}
 # Literal typed booleans are fallback dictionaries; explicit XML labels win.
 src=source(ROOT/'support/addon-lvars/fields.json','support/addon-lvars/fields.json')
 for provider in addon:
  for field in provider['fields']:
   key=provider['provider']+'.'+field['name']
   if field['source_units'].lower()=='bool' and key not in mappings:add(key,{'0':'OFF','1':'ON'},src,'model_explicit_bool_unit')
 return {'schema':1,'sources':sources,'scanned':scanned,'mappings':dict(sorted(mappings.items())),'conflicts':conflicts,
  'summary':{'mapped_fields':len(mappings),'conflicting_fields_omitted':len(conflicts),'by_provider':{p:sum(k.startswith(p+'.') for k in mappings) for p in sorted({k.split('.')[0] for k in mappings})}}}
if __name__=='__main__':
 import sys,json
 if len(sys.argv)==4 and sys.argv[1]=='--extract-labels':
  cases=json.loads(Path(sys.argv[2]).read_text(encoding='utf-8-sig'))
  result=[]
  for case in cases:
   if 'description' in case: result.append(enum_labels(case['description']))
   else:
    node=ET.fromstring(case['xml'])
    result.append({'indexed':indexed_labels(node),'momentary':momentary_labels(node)})
  Path(sys.argv[3]).write_text(json.dumps(result,ensure_ascii=False),encoding='utf-8')
  raise SystemExit

 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--community',type=Path,required=True);p.add_argument('--ifly-header',type=Path,required=True);p.add_argument('--pmdg-header',type=Path,required=True);p.add_argument('--pmdg777-header',type=Path,required=True);p.add_argument('--output',type=Path,default=ROOT/'support/display-values/catalog.json');a=p.parse_args()
 result=audit(a.community,a.ifly_header,a.pmdg_header,a.pmdg777_header);a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8');print(json.dumps(result['summary'],ensure_ascii=False))
