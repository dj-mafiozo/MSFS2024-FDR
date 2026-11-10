"""Provenance and freshness checks for language-specific manual screenshots."""

from pathlib import Path

import hashlib,json,argparse

ROOT=Path(__file__).resolve().parents[1]

def source_hash():

 paths=set()

 for folder in ['src/Forms','src/Frames','src/Visualization','src/i18n']:

  paths.update(p for p in (ROOT/folder).rglob('*') if p.suffix.lower() in ('.pas','.dfm','.inc') and not any(x in p.parts for x in ['__history','__recovery']))

 paths.update([ROOT/'translations/MSFS2024-FDR.i18n',ROOT/'tests/CaptureHelpScreenshots.dpr',ROOT/'tests/HelpDemoDataU.pas',ROOT/'tests/HelpScreenshotU.pas',ROOT/'help/demo-route.pln',ROOT/'help/demo-simbrief.json'])

 paths.update((ROOT/'help').glob('example-analysis.*.txt'))
 digest=hashlib.sha256()

 for p in sorted(paths):digest.update(p.relative_to(ROOT).as_posix().encode());digest.update(p.read_bytes())

 return digest.hexdigest()

def prepare():

 import shutil,time

 folder=ROOT/'help/images';manifest=folder/'capture.json'

 if not manifest.exists():return

 backup=ROOT/'.build/help-image-backups'/str(time.time_ns());backup.mkdir(parents=True)

 assert backup.resolve().is_relative_to((ROOT/'.build').resolve())

 for name in json.loads(manifest.read_text(encoding='utf-8'))['images']:

  assert Path(name).name==name and name.endswith('.png')

  path=folder/name

  if path.exists():shutil.copy2(path,backup/name);path.unlink()

 print('Previous generated screenshots preserved in',backup.relative_to(ROOT))



def verify(stamp=False):

 folder=ROOT/'help/images';manifest=folder/'capture.json';files={}

 for lang in ('pl','en','de','es'):

  matches=list(folder.glob(lang+'-*.png'))

  assert len(matches)>=15,('Missing localized screenshots',lang,len(matches))

  for p in matches:

   data=p.read_bytes();assert data.startswith(b'\x89PNG\r\n\x1a\n'),p

   files[p.name]=hashlib.sha256(data).hexdigest()

 data={'source_sha256':source_hash(),'images':files,'data':'synthetic telemetry and anonymized EPLL plan/OFP; no personal flight recording','languages':['pl','en','de','es']}

 if stamp:manifest.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')

 else:assert json.loads(manifest.read_text(encoding='utf-8'))==data,'Documentation screenshots stale; run tools/capture_help.ps1'

 print('PASS:',len(files),'localized screenshots; UI source fingerprint current.')

if __name__=='__main__':

 p=argparse.ArgumentParser();p.add_argument('--stamp',action='store_true');p.add_argument('--prepare',action='store_true');a=p.parse_args();prepare() if a.prepare else verify(a.stamp)

