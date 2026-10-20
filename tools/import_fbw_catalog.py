"""Import readable, non-deprecated L-vars from the user-supplied FBW Flight Deck API HTML."""
import argparse,hashlib,itertools,json,re
from html.parser import HTMLParser
from pathlib import Path
class Tables(HTMLParser):
 def __init__(self):super().__init__();self.article=0;self.cell=None;self.row=[];self.rows=[]
 def handle_starttag(self,t,a):
  if t=='article':self.article+=1
  if not self.article:return
  if t=='tr':self.row=[]
  if t in ('td','th'):self.cell=[]
  if t=='br' and self.cell is not None:self.cell.append(' ')
 def handle_data(self,d):
  if self.article and self.cell is not None:self.cell.append(d)
 def handle_endtag(self,t):
  if t in ('td','th') and self.cell is not None:self.row.append(re.sub(r'\s+',' ',''.join(self.cell)).strip());self.cell=None
  if t=='tr' and self.article:self.rows.append(self.row)
  if t=='article':self.article-=1
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('html',type=Path);parser.add_argument('output',type=Path);args=parser.parse_args()
raw=args.html.read_bytes();p=Tables();p.feed(raw.decode('utf-8'))
fields={};skipped=[]
for row in p.rows:
 if len(row)!=6:continue
 function,name,values,access,kind,remark=row
 if ('LVAR' not in kind.upper() and not name.upper().startswith('LVAR:')) or ('SIMCONNECT' in kind.upper()):continue
 if 'R' not in access.upper() or 'deprecated' in remark.lower():skipped.append({'name':name,'reason':'not readable or deprecated'});continue
 name=re.sub(r'^(?:LVAR:|L:)','',name,flags=re.I)
 name=re.sub(r'(?<=_)\s+(?=[A-Z_0-9])','',name)
 variants=[name]
 while any('{' in n for n in variants):
  expanded=[]
  for n in variants:
   m=re.search(r'\{([^}]+)\}',n)
   if not m:expanded.append(n);continue
   options=re.split(r'\s*[|,]\s*',m[1])
   if len(options)<2:raise ValueError('Ambiguous placeholder '+name)
   expanded.extend(n[:m.start()]+o+n[m.end():] for o in options)
  variants=expanded
 for n in variants:
  if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_:]*',n):raise ValueError('Unresolved L-var '+n)
  fields[n]={'function':function,'values':values,'access':access,'remark':remark,'source':'local Flight Deck API'}
# Factual additions from the official custom-L-var reference linked by the supplied page.
# Descriptions are short unit/type facts, not copies of the full remote documentation.
for name,unit,remark in [('A32NX_IS_READY','bool','JavaScript readiness'),('A32NX_SPEEDS_VAPP','knots','FMS VAPP, including pilot override'),('A32NX_SPEEDS_MANAGED_PFD','knots','FMS managed speed target; zero is invalid')]:
 fields[name]={'function':name,'values':unit,'access':'R','remark':remark,'source':'official custom-L-var reference'}
result={'source_file':args.html.name,'source_sha256':hashlib.sha256(raw).hexdigest(),'reference_url':'https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/docs/a320-simvars.md','variable_count':len(fields),'variables':fields,'excluded':skipped}
args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8');print('Imported',len(fields),'readable L-vars; excluded',len(skipped),'deprecated/write-only rows.')
