"""Generate the compiled FBW catalog; all values are read-only raw L-vars."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1];j=json.loads((root/'support/fbw/variables.json').read_text(encoding='utf-8'))
def pas(s):return '+'.join("'"+s[i:i+100].replace("'","''")+"'" for i in range(0,len(s),100)) or "''"
lines=['unit FBWCatalogU;','interface','type TFBWField=record Name,Description:string;end;',f'const FBWFieldCount={len(j["variables"])};','FBWSourceSHA256='+pas(j['source_sha256'])+';','FBWFields:array[0..FBWFieldCount-1] of TFBWField = (']
for n,d in j['variables'].items():lines.append('(Name:'+pas(n)+';Description:'+pas(' | '.join([d['function'],d['values'],d['access'],d['remark']]))+'),')
lines[-1]=lines[-1][:-1];lines+=[');','function IsFBWAircraft(const Title:string):Boolean;','implementation','uses System.SysUtils;','function IsFBWAircraft(const Title:string):Boolean;','var T:string;begin T:=UpperCase(Title).Replace(\'-\',\'\').Replace(\'_\',\'\').Replace(\' \',\'\');','Result:=(Pos(\'A32NX\',T)>0) or ((Pos(\'FLYBYWIRE\',T)>0) and (Pos(\'A320\',T)>0)) or ((Pos(\'FBW\',T)>0) and (Pos(\'A320\',T)>0));end;','end.']
(root/'src/aircraft/fbw/FBWCatalogU.pas').write_text('\n'.join(lines)+'\n',encoding='utf-8');print('Generated',len(j['variables']),'FBW fields.')
