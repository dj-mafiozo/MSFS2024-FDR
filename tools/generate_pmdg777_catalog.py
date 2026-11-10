"""Generate a PMDG NG3 data-field catalog with explicit MSVC default-pack offsets."""
import argparse,ctypes,hashlib,json,re
from pathlib import Path
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('header',type=Path);parser.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);args=parser.parse_args()
raw=args.header.read_bytes();text=raw.decode('utf-8-sig');body=text.split('struct PMDG_777X_Data',1)[1].split('};',1)[0].split('{',1)[1]
types={'bool':(1,'bool',ctypes.c_uint8),'char':(1,'text',ctypes.c_char),'unsigned char':(1,'u8',ctypes.c_uint8),'short':(2,'i16',ctypes.c_int16),'unsigned short':(2,'u16',ctypes.c_uint16),'int':(4,'i32',ctypes.c_int32),'unsigned int':(4,'u32',ctypes.c_uint32),'float':(4,'f32',ctypes.c_float)}
clean=re.sub(r'//[^\n]*','',body);fields=[];members=[];offset=0;alignment=1;assertions=[]
for declaration in clean.split(';'):
 declaration=' '.join(declaration.split())
 if not declaration:continue
 m=re.fullmatch(r'(bool|char|unsigned char|short|unsigned short|int|unsigned int|float)\s+(\w+)((?:\[\d+\])*)',declaration)
 if not m:raise ValueError('Unsupported declaration: '+declaration)
 typename,name,dims=m.groups();size,kind,ctype=types[typename];dimensions=[int(n) for n in re.findall(r'\d+',dims)]
 align=min(size,8);offset=(offset+align-1)//align*align;alignment=max(alignment,align)
 original_type=ctype
 for n in reversed(dimensions):ctype=ctype*n
 members.append((name,ctype));assertions.append((name,offset))
 comment_match=re.search(r'\b'+re.escape(name)+re.escape(dims)+r'\s*;[^\S\n]*(?://([^\n]*))?',body)
 description=comment_match[1].strip() if comment_match and comment_match[1] else 'Raw SDK '+typename
 def expand(label,dimensions,position):
  if not dimensions or kind=='text':
   count=1
   for n in dimensions:count*=n
   if name!='reserved':fields.append({'name':label,'kind':kind,'offset':position,'size':size*count,'description':description})
   return size*count
  total=0
  for n in range(dimensions[0]):total+=expand(label+'['+str(n)+']',dimensions[1:],position+total)
  return total
 offset+=expand(name,dimensions,offset)
struct_size=(offset+alignment-1)//alignment*alignment
class NativeData(ctypes.Structure):_fields_=members
assert ctypes.sizeof(NativeData)==struct_size
for name,position in assertions:assert getattr(NativeData,name).offset==position,name
j={'source_file':args.header.name,'sha256':hashlib.sha256(raw).hexdigest(),'struct_size':struct_size,'struct_alignment':alignment,'field_count':len(fields),'fields':fields,'members':[{'name':n,'offset':o} for n,o in assertions]}
out=args.root/'support/pmdg777';out.mkdir(parents=True,exist_ok=True);(out/'fields.json').write_text(json.dumps(j,indent=2)+'\n',encoding='utf-8')
def pas(s):return '+'.join("'"+s[i:i+90].replace("'","''")+"'" for i in range(0,len(s),90)) or "''"
lines=['{$StackFrames On}','unit PMDG777CatalogU;','interface','type TPMDG777Field=record Name,Kind:string;Offset,Size:Integer;Description:string;end;',f'const PMDG777DataSize={struct_size};',f'PMDG777FieldCount={len(fields)};','PMDG777CDUSize=1009;','PMDG777DataName=\'PMDG_777X_Data\';','PMDG777DataID=$504D4447;PMDG777DataDefinition=$504D4448;','PMDG777CDU0ID=$4E477835;PMDG777CDU1ID=$4E477836;','PMDG777CDU0Definition=$4E477838;PMDG777CDU1Definition=$4E477839;PMDG777CDU2ID=$4E477837;PMDG777CDU2Definition=$4E47783A;','PMDG777HeaderSHA256='+pas(j['sha256'])+';','PMDG777Fields:array[0..PMDG777FieldCount-1] of TPMDG777Field = (']
for f in fields:lines.append('(Name:'+pas(f['name'])+';Kind:'+pas(f['kind'])+f';Offset:{f["offset"]};Size:{f["size"]};Description:'+pas(f['description'])+'),')
lines[-1]=lines[-1][:-1];lines+=[');','function IsPMDG777Aircraft(const Title:string):Boolean;','implementation','uses System.SysUtils;','function IsPMDG777Aircraft(const Title:string):Boolean;','var T:string;begin T:=UpperCase(Title).Replace(\'-\',\'\').Replace(\'_\',\'\').Replace(\' \',\'\');','Result:=(Pos(\'PMDG\',T)>0) and ((Pos(\'777\',T)>0) or (Pos(\'B77\',T)>0)) and (Pos(\'MAX\',T)=0);end;','end.'];(args.root/'src/aircraft/pmdg/PMDG777CatalogU.pas').write_text('\n'.join(lines)+'\n',encoding='utf-8-sig')
# Compile this locally against the unmodified header to independently verify every member offset.
cpp=['#include "PMDG_777X_SDK.h"',f'static_assert(sizeof(PMDG_777X_Data)=={struct_size},"SDK size mismatch");','static_assert(sizeof(PMDG_777X_CDU_Screen)==1009,"CDU size mismatch");']
cpp += [f'static_assert(__builtin_offsetof(PMDG_777X_Data,{n})=={o},"{n}");' for n,o in assertions]
(args.root/'.build').mkdir(parents=True,exist_ok=True)
(args.root/'.build/VerifyPMDG777Layout.cpp').write_text('\n'.join(cpp)+'\n')
print(f'Generated {len(fields)} named SDK fields, {struct_size} bytes, alignment {alignment}; independent ctypes layout matches.')

from apply_display_values import update_catalog
update_catalog(args.root/'src/aircraft/pmdg/PMDG777CatalogU.pas')
