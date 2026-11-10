"""Generate active Fenix candidates and historical-only definitions from the audited inventory."""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = json.loads((root/'support/fenix/variables.json').read_text(encoding='utf-8-sig'))

def pas(text):
    return '+'.join("'"+text[i:i+100].replace("'", "''")+"'" for i in range(0,len(text),100)) or "''"

def description(name, contexts, historical=False):
    result = '; '.join(dict.fromkeys(c['template']+' / '+c['parameter'] for c in contexts))
    if name == 'S_FC_FLAPS': result += '; lever detents 0..4, not actual surface position'
    if name == 'S_MIP_GEAR': result += '; 0=UP, 1=DOWN lever, not physical gear extension/contact'
    if name in ['A_FC_THROTTLE_LEFT_INPUT','A_FC_THROTTLE_RIGHT_INPUT']: result += '; animation input 0..5, not normalized throttle percentage'
    if historical: result += '; HISTORICAL ONLY: absent from current model inventory; never subscribed by current reader'
    return result

retired = source.get('retired_variables', {})
lines = ['unit FenixCatalogU;', 'interface',
 'type TFenixField=record Name,Description:string;end;',
 f'const FenixFieldCount={len(source["variables"])};',
 'FenixBatchSize=128;',
 'FenixBatchCount=(FenixFieldCount+FenixBatchSize-1) div FenixBatchSize;',
 'FenixCockpitSHA256='+pas(source['sha256'])+';',
 'FenixCatalogSHA256='+pas(source.get('catalog_sha256',source['sha256']))+';',
 'FenixPackageVersion='+pas(source.get('package_version',''))+';',
 f'FenixRetiredFieldCount={len(retired)};',
 'FenixFields:array[0..FenixFieldCount-1] of TFenixField = (']
for name, contexts in source['variables'].items():
    lines.append('(Name:'+pas(name)+';Description:'+pas(description(name,contexts))+'),')
lines[-1]=lines[-1][:-1]
lines += [');',f'FenixRetiredFields:array[0..{max(1,len(retired))-1}] of TFenixField = (']
for name, contexts in (retired or {'':[]}).items():
    lines.append('(Name:'+pas(name)+';Description:'+pas(description(name,contexts,True))+'),')
lines[-1]=lines[-1][:-1]
lines.extend([');','function IsFenixAircraft(const Title:string):Boolean;',
 'implementation','uses System.SysUtils;',
 'function IsFenixAircraft(const Title:string):Boolean;',
 'var T:string;begin T:=UpperCase(Title);Result:=(Pos(\'FENIX\',T)>0) or (Pos(\'FNX_32\',T)>0) or (Pos(\'FNX A32\',T)>0);end;', 'end.'])
(root/'src/aircraft/fenix/FenixCatalogU.pas').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Generated',len(source['variables']),'active and',len(retired),'historical-only Fenix definitions.')

from apply_display_values import update_catalog
update_catalog(root/'src/aircraft/fenix/FenixCatalogU.pas')
