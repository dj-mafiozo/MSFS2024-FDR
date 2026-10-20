"""Generate the read-only Fenix L-var catalog from the imported cockpit inventory."""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = json.loads((root/'support/fenix/variables.json').read_text(encoding='utf-8'))
def pas(text):
    return '+'.join("'"+text[i:i+100].replace("'", "''")+"'" for i in range(0,len(text),100)) or "''"
lines = ['unit FenixCatalogU;', 'interface',
 'type TFenixField=record Name,Description:string;end;',
 f'const FenixFieldCount={len(source["variables"])};',
 'FenixBatchSize=128;',
 'FenixBatchCount=(FenixFieldCount+FenixBatchSize-1) div FenixBatchSize;',
 'FenixCockpitSHA256='+pas(source['sha256'])+';',
 'FenixFields:array[0..FenixFieldCount-1] of TFenixField = (']
for name, contexts in source['variables'].items():
    description='; '.join(dict.fromkeys(c['template']+' / '+c['parameter'] for c in contexts))
    if name=='S_FC_FLAPS':description+='; lever detents 0..4, not flap angle or actual surface position'
    if name=='S_MIP_GEAR':description+='; 0=UP, 1=DOWN lever, not physical gear extension/contact'
    if name in ['A_FC_THROTTLE_LEFT_INPUT','A_FC_THROTTLE_RIGHT_INPUT']:description+='; animation input 0..5; not normalized throttle percentage'
    lines.append('(Name:'+pas(name)+';Description:'+pas(description)+'),')
lines[-1]=lines[-1][:-1]
lines.extend([');','function IsFenixAircraft(const Title:string):Boolean;',
 'implementation','uses System.SysUtils;',
 'function IsFenixAircraft(const Title:string):Boolean;',
 'var T:string;begin T:=UpperCase(Title);Result:=(Pos(\'FENIX\',T)>0) or (Pos(\'FNX_32\',T)>0) or (Pos(\'FNX A32\',T)>0);end;', 'end.'])
(root/'src/aircraft/fenix/FenixCatalogU.pas').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Generated',len(source['variables']),'Fenix fields.')
