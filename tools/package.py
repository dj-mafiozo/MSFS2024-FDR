"""Package source and Win64 release, excluding private recordings/configuration."""
from pathlib import Path
import zipfile
root=Path(__file__).resolve().parents[1]
license_name='LICENSE' if (root/'LICENSE').exists() else 'LICENSE.txt'
settings=(root/'bin/settings.example.ini').read_text(encoding='utf-8-sig')
def tree(z,folder,suffixes=None,prefix=None):
 base=root/folder
 for p in base.rglob('*'):
  if not p.is_file() or any(x in p.parts for x in ['__history','__recovery','node_modules','.git']):continue
  if suffixes is not None and p.suffix.lower() not in suffixes:continue
  z.write(p,(Path(prefix)/p.relative_to(base) if prefix else p.relative_to(root)).as_posix())
def docs(z):
 for p in root.glob('*.md'):z.write(p,p.name)
 for folder in ['support','translations','runtime']:
  for p in (root/folder).rglob('*'):
   if p.is_file() and (p.suffix.lower() in {'.md','.i18n','.patch'} or p.name=='LICENSE'):z.write(p,p.relative_to(root).as_posix())
 tree(z,'docs',{'.png'})
 tree(z,'help',{'.htm','.hhp','.hhc','.h','.md'})
 z.write(root/license_name,license_name)
with zipfile.ZipFile(root/'MSFSFDR-VCL-source.zip','w',zipfile.ZIP_DEFLATED) as z:
 for folder,suffixes in [('src',{'.pas','.dfm','.dpr','.dproj','.inc','.res','.ico'}),('tools',{'.py','.ps1','.dpr','.txt'}),('runtime',{'.dll'}),('tests',{'.dpr'})]:tree(z,folder,suffixes)
 tree(z,'Icons',{'.png','.bmp'})
 tree(z,'assets/fonts',{'.ttf','.ttc','.txt','.json'})
 docs(z)
 for p in (root/'tests/fixtures').glob('*.PLN'):z.write(p,p.relative_to(root).as_posix())
 for n in ['build.ps1','test.ps1','.gitignore','bin/settings.example.ini']:z.write(root/n,n)
 for n in ['native-preview.png','simbrief-preview.png','settings-en-preview.png','toolbar-preview.png','verification.log','flightpad-export.log','dependencies.log']:
  p=root/'tests'/n
  if p.exists():z.write(p,'tests/'+n)
 wv=root/'vendor/WebView4Delphi-main'
 if not wv.exists():wv=root.parent/'FSHudPanel/vendor/WebView4Delphi-main'
 assert (wv/'source').is_dir(),'Missing WebView4Delphi source'
 for folder in ['source','bin64']:
  for p in (wv/folder).rglob('*'):
   if p.is_file():z.write(p,'vendor/WebView4Delphi-main/'+p.relative_to(wv).as_posix())
 for p in wv.glob('*LICENSE*'):
  if p.is_file():z.write(p,'vendor/WebView4Delphi-main/'+p.name)
 i18n=root/'vendor/i18n'
 assert (i18n/'Packages/i18nLocalizer.pas').exists(),'Missing i18n source'
 tree(z,'vendor/i18n',{'.pas','.dfm','.inc','.res','.dcr','.rc','.dpk'})
 tree(z,'vendor/Delphi-StackTrace',{'.pas','.inc','.md'})
 z.write(root/'vendor/Delphi-StackTrace/License','vendor/Delphi-StackTrace/License')
 z.write(i18n/'LICENSE','vendor/i18n/LICENSE')
 z.writestr('bin/settings.ini',settings)
with zipfile.ZipFile(root/'MSFSFDR-VCL.zip','w',zipfile.ZIP_DEFLATED) as z:
 for n in ['MSFS2024-FDR.exe','MSFS2024-FDR.pdb','SimConnect.dll','sqlite3.dll','WebView2Loader.dll','MSFS2024-FDR.i18n']:z.write(root/'bin'/n,n)
 tree(z,'bin/fonts',{'.ttf','.ttc','.txt','.json'},'fonts')
 tree(z,'bin/help',{'.chm'},'help')
 docs(z);z.write(root/'MSFSFDR-VCL-source.zip','MSFSFDR-VCL-source.zip')
 z.writestr('settings.ini',settings)
with zipfile.ZipFile(root/'MSFSFDR-VCL-source.zip') as z:
 names=z.namelist()
 for n in ['src/forms/frmMainU.pas','src/forms/frmMainU.dfm','src/i18n/LocalizationCatalogU.pas','tests/VerifyLocalization.dpr','translations/MSFS2024-FDR.i18n','vendor/i18n/Packages/i18nLocalizer.pas','vendor/i18n/LICENSE','README.en.md','README.de.md','README.es.md','Testy.de.md','Testy.es.md','src/Frames/fraMapU.pas','src/Frames/fraGraphU.pas','src/Forms/frmViewWindowU.pas']:assert n.lower() in {name.lower() for name in names},n
 assert not any(n.endswith(('.db','.dproj.local','.identcache','.stat')) for n in names)
 assert len(names)==len(set(names)),'Duplicate ZIP members'
with zipfile.ZipFile(root/'MSFSFDR-VCL.zip') as z:
 assert 'gemini_api_key=\n' in z.read('settings.ini').decode()
 assert 'language=auto' in z.read('settings.ini').decode()
 for lang in ('pl','en','de','es'):
  assert 'help/MSFS2024-FDR.'+lang+'.chm' in z.namelist()
  assert 'help/'+lang+'/overview.htm' in z.namelist()
print('PASS: Win64/source archives preserve source tree, four-language documentation, external four-language catalog, i18n license/dependencies and safe Windows-language defaults; no recordings or local credentials.')

with zipfile.ZipFile(root/'MSFSFDR-VCL.zip') as z:
 for name in ['NotoSans-Regular.ttf','NotoSansArabic-Regular.ttf','NotoSansHebrew-Regular.ttf','NotoSansDevanagari-Regular.ttf','NotoSansCJK-Regular.ttc','OFL-Noto.txt','OFL-NotoCJK.txt']:
  assert z.read('fonts/'+name)==(root/'assets/fonts'/name).read_bytes(),name
print('PASS: all bundled script fonts and OFL licenses are present in runtime archive.')

for archive in ['MSFSFDR-VCL.zip','MSFSFDR-VCL-source.zip']:
 with zipfile.ZipFile(root/archive) as z:
  assert not any('mateusz-efb-ifly/' in n.lower() or n.lower().startswith(('community/','optional-community/','efb-addon/')) for n in z.namelist())
