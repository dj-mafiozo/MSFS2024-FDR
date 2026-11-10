"""Register every tests/*.dpr in the Delphi IDE group; apply shared compiler/runtime paths.
Run after adding a test. --check validates without editing.
"""
from pathlib import Path
import argparse,re,uuid,xml.etree.ElementTree as E
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--check',action='store_true');a=p.parse_args()
r=Path(__file__).resolve().parents[1];tests=r/'tests';ns='http://schemas.microsoft.com/developer/msbuild/2003'
projects=sorted(tests.glob('*.dpr'),key=lambda p:p.name.lower());group=tests/'Tests.groupproj'
if a.check:
 tree=E.parse(group);items={Path(x.get('Include')).stem for x in tree.findall('.//{'+ns+'}Projects')}
 assert items=={x.stem for x in projects},'Run tools/sync_test_projects.py to update Tests.groupproj'
 for source in projects:
  text=(source.with_suffix('.dproj')).read_text(encoding='utf-8-sig')
  assert 'Tests.Shared.props' in text,source
  if '<AppType>Library</AppType>' in text: assert '<GenDll>true</GenDll>' in text,('Missing DLL output setting',source)
 print('PASS:',len(projects),'test/probe/mock projects registered in Tests.groupproj with shared paths.')
 raise SystemExit
for source in projects:
 dest=source.with_suffix('.dproj')
 if not dest.exists():
  text=f'''<Project xmlns="{ns}">
 <PropertyGroup><ProjectGuid>{{{str(uuid.uuid5(uuid.NAMESPACE_URL,'MSFS2024-FDR/tests/'+source.stem)).upper()}}}</ProjectGuid><MainSource>{source.name}</MainSource><ProjectVersion>18.4</ProjectVersion><Base>True</Base><Config Condition="'$(Config)'==''">Debug</Config><Platform Condition="'$(Platform)'==''">Win64</Platform><AppType>{'Library' if source.stem.startswith('Mock') and source.stem!='MockFlightPad32' else 'Console'}</AppType><FrameworkType>VCL</FrameworkType></PropertyGroup>
 <Import Project="$(BDS)\\Bin\\CodeGear.Delphi.Targets"/>
</Project>'''
 else:text=dest.read_text(encoding='utf-8-sig')
 if 'Tests.Shared.props' not in text:
  pos=text.index('<Import Project="$(BDS)\\Bin\\CodeGear.Delphi.Targets"')
  text=text[:pos]+f'<PropertyGroup><FDRVerifyTest>{str(source.stem.startswith(("Verify","CaptureHelp"))).lower()}</FDRVerifyTest></PropertyGroup>\n    <Import Project="Tests.Shared.props"/>\n    '+text[pos:]
 # AppType alone does not select .dll in Delphi 10.2 targets.
 if '<AppType>Library</AppType>' in text and '<GenDll>true</GenDll>' not in text:
  text=text.replace('<AppType>Library</AppType>','<AppType>Library</AppType><GenDll>true</GenDll>')
 # Delphi targets require a compile item; MainSource alone can report a false successful build.
 if '<DelphiCompile ' not in text:
  text=text.replace('<Import Project="Tests.Shared.props"/>','<ItemGroup><DelphiCompile Include="$(MainSource)"><MainSource>MainSource</MainSource></DelphiCompile></ItemGroup>\n    <Import Project="Tests.Shared.props"/>')
 # Keep existing configurations/IDE metadata; default runtime architecture is explicit.
 default='Win32' if source.stem=='MockFlightPad32' else 'Win64'
 text=re.sub(r'(<Platform Condition="[^\"]*">)[^<]*(</Platform>)',r'\g<1>'+default+r'\2',text,count=1)
 text=re.sub(r'<TargetedPlatforms>[^<]*</TargetedPlatforms>','<TargetedPlatforms>'+('1' if source.stem=='MockFlightPad32' else '3')+'</TargetedPlatforms>',text)
 # IDE platform availability is stored separately from TargetedPlatforms.
 text=re.sub(r'(<Platform value="Win64">)[^<]*(</Platform>)',r'\g<1>'+('False' if source.stem=='MockFlightPad32' else 'True')+r'\2',text)
 text=re.sub(r'(<Platform value="Win32">)[^<]*(</Platform>)',r'\g<1>True\2',text)
 if '<BuildConfiguration Include="Base">' not in text:
  text=text.replace('<Import Project="Tests.Shared.props"/>','<ItemGroup><BuildConfiguration Include="Base"><Key>Base</Key></BuildConfiguration></ItemGroup>\n    <Import Project="Tests.Shared.props"/>')
 for config in ['Debug','Release']:
  if '<BuildConfiguration Include="'+config+'">' not in text:
   keys=set(re.findall(r'<Key>([^<]+)</Key>',text));i=1
   while 'Cfg_'+str(i) in keys:i+=1
   key='Cfg_'+str(i)
   metadata='<ItemGroup><BuildConfiguration Include="'+config+'"><Key>'+key+'</Key><CfgParent>Base</CfgParent></BuildConfiguration></ItemGroup>'
   condition="'$(Config)'=='"+config+"' or '$("+key+")'!=''"
   metadata+='<PropertyGroup Condition="'+condition+'"><'+key+'>true</'+key+'><CfgParent>Base</CfgParent></PropertyGroup>'
   text=text.replace('<Import Project="Tests.Shared.props"/>',metadata+'\n    <Import Project="Tests.Shared.props"/>')
 if '<ProjectExtensions>' not in text:
  metadata='<ProjectExtensions><Borland.Personality>Delphi.Personality.12</Borland.Personality><Borland.ProjectType/><BorlandProject><Delphi.Personality><Source><Source Name="MainSource">'+source.name+'</Source></Source></Delphi.Personality><Platforms><Platform value="Win32">True</Platform><Platform value="Win64">'+('False' if source.stem=='MockFlightPad32' else 'True')+'</Platform></Platforms></BorlandProject><ProjectFileVersion>12</ProjectFileVersion></ProjectExtensions>'
  text=text.replace('<Import Project="Tests.Shared.props"/>',metadata+'\n    <Import Project="Tests.Shared.props"/>')
 dest.write_text(text,encoding='utf-8-sig')
items='\n'.join(f'  <Projects Include="{s.stem}.dproj"><Dependencies/></Projects>' for s in projects)
text=f'<Project xmlns="{ns}">\n <PropertyGroup><ProjectGuid>{{FF251C45-F63D-4B19-9AF9-5FDC13A28CB9}}</ProjectGuid><Platform Condition="\'$(Platform)\'==\'\'">Win64</Platform><Config Condition="\'$(Config)\'==\'\'">Debug</Config></PropertyGroup>\n <ItemGroup>\n{items}\n </ItemGroup>\n'
for source in projects:
 for suffix,target in [('',None),(':Make','Make'),(':Clean','Clean')]:
  text+=f' <Target Name="{source.stem}{suffix}"><MSBuild Projects="{source.stem}.dproj" Properties="Platform={"Win32" if source.stem=="MockFlightPad32" else "$(Platform)"}"'+(f' Targets="{target}"' if target else '')+'/></Target>\n'
for operation in ['Build','Make','Clean']:
 names=';'.join(s.stem+(':'+operation if operation!='Build' else '') for s in projects)
 text+=f' <Target Name="{operation}"><CallTarget Targets="{names}"/></Target>\n'
text+='<ProjectExtensions><Borland.Personality>Default.Personality.12</Borland.Personality><Borland.ProjectType/><BorlandProject><Default.Personality/></BorlandProject></ProjectExtensions>\n'
text+=' <Import Project="$(BDS)\\Bin\\CodeGear.Group.Targets" Condition="Exists(\'$(BDS)\\Bin\\CodeGear.Group.Targets\')"/>\n</Project>\n';group.write_text(text,encoding='utf-8-sig')
folders=['..\\'+p.relative_to(r).as_posix().replace('/','\\') for p in (r/'src').rglob('*') if p.is_dir() and not any(z in p.parts for z in ['__history','__recovery'])]
paths=';'.join(['.','..\\src','..\\..\\MSFS2024-FDR-Setup\\src','..\\..\\setup-common\\src','..\\..\\setup-core\\src']+folders+['$(I18nRoot)','$(VirtualTreeRoot)','..\\vendor\\Delphi-StackTrace\\source'])
props=f'''<Project xmlns="{ns}">
 <PropertyGroup>
  <VirtualTreeRoot Condition="'$(VirtualTreeRoot)'=='' and Exists('$(MSBuildThisFileDirectory)..\\..\\Virtual-TreeView\\Source\\VirtualTrees.pas')">$(MSBuildThisFileDirectory)..\\..\\Virtual-TreeView\\Source</VirtualTreeRoot>
  <VirtualTreeRoot Condition="'$(VirtualTreeRoot)'==''">$(MSBuildThisFileDirectory)..\\vendor\\Virtual-TreeView\\Source</VirtualTreeRoot>
  <I18nRoot Condition="'$(I18nRoot)'==''">$(MSBuildThisFileDirectory)..\\vendor\\i18n\\Packages</I18nRoot>
  <DCC_UnitSearchPath>$(BDS)\\source\\DUnitX;{paths};$(DCC_UnitSearchPath)</DCC_UnitSearchPath>
  <PreBuildEvent>python.exe &quot;$(MSBuildThisFileDirectory)..\\tools\\build_resources.py&quot; --app --vendor</PreBuildEvent>
  <PreBuildEventIgnoreExitCode>false</PreBuildEventIgnoreExitCode>
  <DCC_IncludePath>$(BDS)\\source\\DUnitX;$(DCC_IncludePath)</DCC_IncludePath>
  <DCC_ResourcePath>$(BDS)\\lib\\$(Platform)\\release;$(DCC_ResourcePath)</DCC_ResourcePath>
  <DCC_Namespace>System;System.Win;Winapi;Vcl;Data;Xml;Xml.Win;$(DCC_Namespace)</DCC_Namespace>
  <DCC_Define Condition="'$(FDRVerifyTest)'=='true'">PORT_TEST;$(DCC_Define)</DCC_Define>
  <DCC_DcuOutput>$(MSBuildThisFileDirectory)..\\.build\\Tests\\$(Platform)\\$(Config)\\$(MSBuildProjectName)</DCC_DcuOutput>
  <DCC_ExeOutput>$(MSBuildThisFileDirectory)</DCC_ExeOutput>
  <DCC_DllOutput>$(MSBuildThisFileDirectory)</DCC_DllOutput>
  <DCC_ObjPath>$(DCC_DcuOutput)</DCC_ObjPath>
  <PostBuildEvent Condition="'$(Platform)'=='Win64'">copy /Y &quot;$(MSBuildThisFileDirectory)..\\bin\\sqlite3.dll&quot; &quot;$(MSBuildThisFileDirectory)sqlite3.dll&quot; &amp;&amp; copy /Y &quot;$(MSBuildThisFileDirectory)..\\bin\\SimConnect.dll&quot; &quot;$(MSBuildThisFileDirectory)SimConnect.dll&quot;</PostBuildEvent>
 </PropertyGroup>
</Project>'''
(tests/'Tests.Shared.props').write_text(props,encoding='utf-8-sig')
print('Updated',len(projects),'IDE test projects and shared paths.')
