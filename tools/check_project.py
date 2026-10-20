"""Check that the Delphi IDE project explicitly lists every local source unit."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
src = root / 'src'
dpr = (src / 'MSFS2024-FDR.dpr').read_text(encoding='utf-8-sig')
project = ET.parse(src / 'MSFS2024-FDR.dproj')
ns = {'m': 'http://schemas.microsoft.com/developer/msbuild/2003'}
refs = [item.attrib['Include'].replace('\\', '/').lower() for item in project.findall('.//m:DCCReference', ns)]
dpr_refs = [name.replace('\\', '/').lower() for name in re.findall(r"\bin\s*'([^']+\.pas)'", dpr, re.I)]
source_files=[p for p in src.rglob('*.pas') if not any(part in {'__history','__recovery'} for part in p.relative_to(src).parts)]
units = {p.relative_to(src).as_posix().lower() for p in source_files}
errors = []
for label, listed in [('DPR', dpr_refs), ('DPROJ', refs)]:
    errors.extend(f'{label}: missing {name}' for name in sorted(units - set(listed)))
    errors.extend(f'{label}: duplicate {name}' for name in sorted(set(listed)) if listed.count(name) > 1)
    errors.extend(f'{label}: absent source {name}' for name in listed if not (src / name).is_file())
for path in source_files:
    text=path.read_text(encoding='utf-8-sig')
    declaration=re.search(r'(?im)^\s*unit\s+(\w+)\s*;',text)
    if not declaration or declaration[1].lower()!=path.stem.lower(): errors.append(f'Unit/file mismatch: {path}')
    if not path.stem.endswith('U'): errors.append(f'Missing U suffix: {path}')
    if re.search(r'\bTNative\w*\s*=\s*class',text,re.I): errors.append(f'Old Native class: {path}')
    if path.stem.startswith('frm') and not path.with_suffix('.dfm').is_file(): errors.append(f'Missing DFM: {path}')
for path in source_files:
    dfm=path.with_suffix('.dfm')
    if not dfm.is_file(): continue
    name=path.relative_to(src).as_posix().lower()
    ref=next((r for r in project.findall('.//m:DCCReference',ns) if r.get('Include').replace('\\','/').lower()==name),None)
    match=re.search(r'^object (\w+): (\w+)',dfm.read_text(encoding='utf-8-sig'))
    if ref is None or not match or ref.findtext('m:Form',namespaces=ns)!=match[1]:
        errors.append('Incorrect form resource metadata: '+name)
    if re.search(r'Class\s*\(T(?:Localized)?Frame\)',path.read_text(encoding='utf-8-sig'),re.I):
        if ref is None or ref.findtext('m:DesignClass',namespaces=ns)!='TFrame':
            errors.append('Missing TFrame design metadata: '+name)
        frame_dfm=dfm.read_text(encoding='utf-8-sig')
        forbidden=re.findall(r'^  (ClientHeight|ClientWidth|OldCreateOrder|PixelsPerInch|TextHeight)\s*=',frame_dfm,re.M)
        if forbidden: errors.append('Form-only properties in frame DFM: '+name+': '+', '.join(forbidden))
        if match and not re.search(r"\{\s*"+re.escape(match[1])+r"\s*:\s*TFrame\s*\}",dpr,re.I):
            errors.append('Missing TFrame designer annotation in DPR: '+name)

for property_name in ['DCC_DcuOutput','DCC_ObjPath','DCC_HppOutput','DCC_DcpOutput','DCC_BplOutput']:
    paths=project.findall('.//m:'+property_name,ns)
    if not paths or any('.build' not in (node.text or '') or '$(Platform)' not in node.text or '$(Config)' not in node.text for node in paths):
        errors.append('Unsafe compiler output path: '+property_name)
if project.find(".//m:Target[@Name='DeployTranslations']",ns) is None:
    errors.append('Missing translation deployment target')
for target in project.findall('m:Target',ns):
    if any(name in target.attrib for name in ('AfterTargets','BeforeTargets')):
        errors.append('Delphi 10.2 IDE does not support BeforeTargets/AfterTargets')
for name in ('BuildDependsOn','MakeDependsOn'):
    values=project.findall('m:PropertyGroup/m:'+name,ns)
    if not values or values[-1].text.strip() != '$('+name+');DeployTranslations':
        errors.append('Missing Delphi 10.2 compatible translation hook: '+name)
required_scopes={'Winapi','System','Vcl','Xml','Data'}
# The IDE can normalize inherited namespaces back into Base; validate the effective chain.
for platform in ('Win32','Win64'):
    for config in ('Cfg_1','Cfg_2'):
        scopes=set()
        for group in project.findall('m:PropertyGroup',ns):
            condition=group.get('Condition','')
            if condition in ("'$(Base)'!=''", "'$(Base_"+platform+")'!=''", "'$("+config+")'!=''", "'$("+config+'_'+platform+")'!=''"):
                scopes.update(group.findtext('m:DCC_Namespace',default='',namespaces=ns).split(';'))
        if not required_scopes.issubset(scopes):
            errors.append('Missing effective Windows unit scopes: '+config+'_'+platform)
delphi_import_seen=False
for child in project.getroot():
    if child.tag=='{'+ns['m']+'}Import' and 'CodeGear.Delphi.Targets' in child.get('Project',''):
        delphi_import_seen=True
    if delphi_import_seen and child.tag=='{'+ns['m']+'}PropertyGroup':
        if any(node.tag.split('}')[-1].startswith('DCC_') for node in child):
            errors.append('Compiler settings after CodeGear.Delphi.Targets import: IDE/compiler may ignore them')
if errors:
    raise SystemExit('\n'.join(errors))
print(f'PASS: all {len(units)} local Pascal units explicitly listed in DPR and DPROJ.')
