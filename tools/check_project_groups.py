import os
"""Validate Delphi IDE group/project metadata, beyond XML/MSBuild syntax."""
from pathlib import Path
import xml.etree.ElementTree as E
import uuid
ROOT=Path(__file__).resolve().parents[1]
NS={'m':'http://schemas.microsoft.com/developer/msbuild/2003'}
errors=[];seen=set();guids={};groups=0;projects=0

def fail(path,message):errors.append(f'{os.path.relpath(path,ROOT)}: {message}')
def text(node,path):return node.findtext(path,default='',namespaces=NS).strip()
def visit(path):
 global groups,projects
 path=path.resolve()
 if path in seen:return
 seen.add(path)
 if not path.is_file():fail(path,'missing file');return
 try:root=E.parse(path).getroot()
 except E.ParseError as e:fail(path,f'invalid XML: {e}');return
 guid=text(root,'m:PropertyGroup/m:ProjectGuid')
 try:uuid.UUID(guid.strip('{}'))
 except ValueError:fail(path,'invalid ProjectGuid')
 if guid in guids:fail(path,f'duplicate GUID with {guids[guid]}')
 guids[guid]=str(os.path.relpath(path,ROOT))
 exts=root.findall('m:ProjectExtensions',NS)
 if len(exts)!=1:fail(path,'expected one ProjectExtensions')
 if path.suffix=='.groupproj':
  groups+=1
  if text(root,'m:ProjectExtensions/m:Borland.Personality')!='Default.Personality.12':fail(path,'missing Default.Personality.12')
  if root.find('m:ProjectExtensions/m:BorlandProject/m:Default.Personality',NS) is None:fail(path,'missing group IDE personality node')
  items=root.findall('m:ItemGroup/m:Projects',NS);names=set();targets={t.get('Name'):t for t in root.findall('m:Target',NS)}
  for item in items:
   name=item.get('Include','');child=(path.parent/name.replace('\\','/')).resolve()
   if name.casefold() in names:fail(path,f'duplicate project {name}')
   names.add(name.casefold())
   for suffix,operation in [('',None),(':Make','Make'),(':Clean','Clean')]:
    target=targets.get(child.stem+suffix)
    if target is None:fail(path,f'missing target {child.stem+suffix}');continue
    task=target.find('m:MSBuild',NS)
    if task is None or (path.parent/task.get('Projects','').replace('\\','/')).resolve()!=child:fail(path,f'target path mismatch {child.stem+suffix}')
    elif operation and task.get('Targets')!=operation:fail(path,f'wrong operation {child.stem+suffix}')
   visit(child)
  for operation in ('Build','Make','Clean'):
   target=targets.get(operation)
   expected={Path(n.replace('\\','/')).stem+(':'+operation if operation!='Build' else '') for n in names}
   actual=set()
   if target is not None:
    for task in target.findall('m:CallTarget',NS):actual.update(task.get('Targets','').split(';'))
   if {x.casefold() for x in actual}!={x.casefold() for x in expected}:fail(path,f'{operation} target does not cover group projects')
 else:
  projects+=1
  if text(root,'m:PropertyGroup/m:ProjectVersion')!='18.4':fail(path,'ProjectVersion must match Tokyo Update 3 (18.4)')
  source=text(root,'m:PropertyGroup/m:MainSource')
  if not (path.parent/source).is_file():fail(path,'missing MainSource file')
  if text(root,'m:ProjectExtensions/m:Borland.Personality')!='Delphi.Personality.12':fail(path,'missing Delphi.Personality.12')
  node=root.find('m:ProjectExtensions/m:BorlandProject/m:Delphi.Personality/m:Source/m:Source[@Name="MainSource"]',NS)
  if node is None or (node.text or '').strip()!=source:fail(path,'missing/mismatched BorlandProject/Delphi.Personality/Source/MainSource')
  if text(root,'m:ProjectExtensions/m:ProjectFileVersion')!='12':fail(path,'missing ProjectFileVersion=12')
  configs={};keys=set()
  for c in root.findall('m:ItemGroup/m:BuildConfiguration',NS):
   name=c.get('Include');key=text(c,'m:Key');parent=text(c,'m:CfgParent')
   if name in configs or key in keys or not key:fail(path,'duplicate/empty build configuration key')
   configs[name]=(key,parent);keys.add(key)
  for name in ('Base','Debug','Release'):
   if name not in configs:fail(path,f'missing {name} IDE configuration')
   elif name!='Base' and configs[name][1]!=configs.get('Base',('Base',''))[0]:fail(path,f'invalid parent for {name}')
  if not root.findall('m:ProjectExtensions/m:BorlandProject/m:Platforms/m:Platform',NS):fail(path,'missing IDE platforms')
for group in (ROOT/'MSFS24 Flight Data Recorder.groupproj',ROOT/'tests/Tests.groupproj'):visit(group)
# Release tooling can be opened separately in the IDE and needs the same metadata.
visit(ROOT.parent/'MSFS2024-FDR-Setup/src/PackageRelease.dproj')
if errors:
 print('\n'.join(errors));raise SystemExit(1)
print(f'PASS: {groups} Delphi groups and {projects} projects; GUIDs, paths, build targets, versions, IDE personality/source/configuration metadata.')
