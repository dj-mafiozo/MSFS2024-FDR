"""Package source and Win64 release, excluding private recordings/configuration."""
from pathlib import Path
import zipfile
root=Path(__file__).resolve().parents[1]
license_name='LICENSE' if (root/'LICENSE').exists() else 'LICENSE.txt'
settings=(root/'bin/settings.example.ini').read_text(encoding='utf-8-sig')
def tree(z,folder,suffixes=None,prefix=None):
 base=root/folder
 for p in base.rglob('*'):
  if p.name in {'ZipPasswordU.pas','congratulations.mfz','private.pem'} or p.suffix.lower()=='.res':continue
  if not p.is_file() or any(x in p.parts for x in ['__history','__recovery','node_modules','.git']):continue
  if p.suffix.lower()=='.pem' and p.name.lower()!='public.pem':continue
  if suffixes is not None and p.suffix.lower() not in suffixes:continue
  z.write(p,(Path(prefix)/p.relative_to(base) if prefix else p.relative_to(root)).as_posix())
def docs(z):
 for p in root.glob('*.md'):z.write(p,p.name)
 for folder in ['support','translations','runtime']:
  for p in (root/folder).rglob('*'):
   if p.is_file() and (p.suffix.lower() in {'.md','.i18n','.patch'} or p.name=='LICENSE' or (folder=='support' and p.name in {'fields.json','binding-profiles.json','locpak-audit.json','variant-audit.json','variables.json','update-audit.json'})):z.write(p,p.relative_to(root).as_posix())
 tree(z,'docs',{'.png'})
 tree(z,'help',{'.htm','.hhp','.hhc','.h','.md'})
 z.write(root/license_name,license_name)
with zipfile.ZipFile(root/'MSFSFDR-VCL-source.zip','w',zipfile.ZIP_DEFLATED) as z:
 for folder,suffixes in [('src',{'.pas','.dfm','.dpr','.dproj','.inc','.rc','.manifest','.ico','.pem'}),('tools',{'.py','.ps1','.dpr','.txt'}),('runtime',{'.dll'}),('tests',{'.dpr','.pas','.dproj','.groupproj','.props','.js','.py'})]:tree(z,folder,suffixes)
 tree(z,'community',{'.xml','.js','.html','.svg','.md','.json','.spb'})
 tree(z,'Assets',{'.png'})
 tree(z,'Icons',{'.png','.bmp'})
 tree(z,'assets/fonts',{'.ttf','.ttc','.txt','.json'})
 docs(z)
 for p in (root/'tests/fixtures').glob('*.PLN'):z.write(p,p.relative_to(root).as_posix())
 for n in ['build.ps1','test.ps1','.gitignore','bin/settings.example.ini']:z.write(root/n,n)
 for n in ['native-preview.png','simbrief-preview.png','settings-en-preview.png','toolbar-preview.png','verification.log','flightpad-export.log','dependencies.log']:
  p=root/'tests'/n
  if p.exists():z.write(p,'tests/'+n)
 i18n=root/'vendor/i18n'
 assert (i18n/'Packages/i18nLocalizer.pas').exists(),'Missing i18n source'
 tree(z,'vendor/i18n',{'.pas','.dfm','.inc','.dcr','.rc','.dpk','.bmp'})
 tree(z,'vendor/Delphi-StackTrace',{'.pas','.inc','.md'})
 z.write(root/'vendor/Delphi-StackTrace/License','vendor/Delphi-StackTrace/License')
 z.write(i18n/'LICENSE','vendor/i18n/LICENSE')
 z.writestr('bin/settings.ini',settings)
# Public sources deliberately exclude the private password implementation and decoy.
with zipfile.ZipFile(root/'MSFSFDR-VCL-source.zip') as z:
 assert not any(Path(n).name in {'ZipPasswordU.pas','congratulations.mfz','private.pem'} for n in z.namelist())
 assert not any(n.endswith('ZipPassword-ExampleU.pas') for n in z.namelist()), 'Password example belongs to separately licensed setup-core'
import subprocess,sys
subprocess.run([sys.executable,str(root/'tools/package_flightsim.py')],check=True)
print('PASS: public source archive excludes private files; runtime uses the unencrypted portable release packager.')
