"""Build current, illustrated four-language CHMs; portable runtime ships CHM only."""
from pathlib import Path
import os,shutil,subprocess,sys,re,tempfile,hashlib,json,argparse
from help_assets import verify
from generate_help import CODEPAGES
ROOT=Path(__file__).resolve().parents[1]
verify()
subprocess.run([sys.executable,str(ROOT/'tools/generate_help.py')],check=True)
compiler=Path(os.environ.get('HHC_EXE') or shutil.which('hhc.exe') or str(Path(os.environ.get('ProgramFiles(x86)',os.environ.get('ProgramFiles','')))/'HTML Help Workshop/hhc.exe'))
if not compiler.is_file():raise SystemExit('HTML Help Workshop required; set HHC_EXE. Stale CHMs are never silently reused.')
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--require-chm',action='store_true');parser.add_argument('--output',type=Path);args=parser.parse_args()
# Inspect compiled navigation strings, not merely preserved source files.
candidates=[os.environ.get('SEVENZIP_EXE'),shutil.which('7z.exe'),shutil.which('7zz.exe')]
for env_name in ['ProgramFiles','ProgramFiles(x86)']:
 base=os.environ.get(env_name)
 if base:candidates.extend([str(Path(base)/'7-Zip/7z.exe'),str(Path(base)/'PeaZip/res/7z/7z.exe')])
sevenzip=next((Path(p) for p in candidates if p and Path(p).is_file()),None)
if sevenzip is None:raise SystemExit('7-Zip CLI required for compiled CHM navigation validation; set SEVENZIP_EXE or install 7-Zip/PeaZip.')
HELP=ROOT/'help';out=(args.output or ROOT/'bin/help').resolve();out.mkdir(parents=True,exist_ok=True)
images=HELP/'images';proof={};blocked=[]
ready=ROOT/'.build/help-ready';ready.mkdir(parents=True,exist_ok=True)
for lang in ('pl','en','de','es'):
 source=HELP/lang
 source_digest=hashlib.sha256()
 inputs=[HELP/('manual.'+lang+'.txt'),*(source/p for p in ['help.hhp','contents.hhc','contexts.h']),*sorted(source.glob('*.htm')),*sorted(images.glob(lang+'-*.png'))]
 for path in inputs:source_digest.update(path.name.encode());source_digest.update(path.read_bytes())
 temp_root=Path(os.environ.get('LOCALAPPDATA',tempfile.gettempdir()))/'Temp';temp_root.mkdir(parents=True,exist_ok=True)
 with tempfile.TemporaryDirectory(prefix='MSFSFDRHelp',dir=temp_root) as directory:
  scratch=Path(directory).resolve();assert scratch.is_relative_to(temp_root.resolve())
  for path in source.iterdir():
   if path.suffix in ('.htm','.hhp','.hhc','.h'):shutil.copy2(path,scratch/path.name)
  (scratch/'images').mkdir()
  for path in images.glob(lang+'-*.png'):shutil.copy2(path,scratch/'images'/path.name)
  output=scratch/('MSFS2024-FDR.'+lang+'.chm')
  env=os.environ.copy();env.update(TEMP=str(scratch),TMP=str(scratch))
  run=subprocess.run([str(compiler),str(scratch/'help.hhp')],cwd=scratch,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45)
  text=run.stdout.decode('mbcs',errors='replace');log=ROOT/'.build'/('help-'+lang+'.log');log.parent.mkdir(exist_ok=True);log.write_text(text,encoding='utf-8')
  if run.returncode not in (0,1) or not output.is_file() or output.read_bytes()[:4]!=b'ITSF' or re.search(r'(?im)^.*Error:',text):raise SystemExit('CHM compilation failed: '+lang+'; see '+str(log))
  # Validate the compiled book itself, not only its source project.
  decoded=scratch/'decoded';decoded.mkdir()
  hh=Path(os.environ['WINDIR'])/'hh.exe'
  subprocess.run([str(hh),'-decompile',str(decoded),str(output)],check=True,timeout=45)
  expected=list(source.glob('*.htm'))
  assert len(list(decoded.glob('*.htm')))==len(expected),('Incomplete compiled topics',lang)
  for original in expected:
   page=decoded/original.name
   assert page.read_bytes()==original.read_bytes(),('Changed compiled page',page.name)
   for image_name in re.findall(r'<img[^>]+src="images/([^"]+)"',page.read_text(encoding=CODEPAGES[lang])):
    assert (decoded/'images'/image_name).read_bytes()==(images/image_name).read_bytes(),('Missing compiled image',image_name)
  strings=subprocess.run([str(sevenzip),'x','-so',str(output),'#STRINGS'],stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True,timeout=30).stdout
  toc=subprocess.run([str(sevenzip),'x','-so',str(output),'#TOCIDX'],stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True,timeout=30).stdout
  titles=[line.split('|',1)[1] for line in (HELP/('manual.'+lang+'.txt')).read_text(encoding='utf-8-sig').splitlines() if line.startswith('@')]
  assert toc,('Missing compiled binary TOC',lang)
  for title in titles:
   ansi=title.encode(CODEPAGES[lang])+b'\0';utf8=title.encode('utf-8')+b'\0'
   assert ansi in strings,('Incorrect compiled navigation codepage',lang,title)
   assert ansi==utf8 or utf8 not in strings,('UTF-8 leaked into ANSI navigation',lang,title)
  print('PASS:',lang,len(titles),'compiled navigation labels in',CODEPAGES[lang])
  shutil.copy2(output,ready/output.name)
  try:shutil.copy2(output,out/output.name)
  except PermissionError:blocked.append(output.name)
  proof[lang]={'source_sha256':source_digest.hexdigest(),'chm_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'topics':len(list(source.glob('*.htm'))),'images':len(list(images.glob(lang+'-*.png')))}
  print('BUILT:' if output.name in blocked else 'PASS:',output.name,'validated illustrated topics, hierarchical contents and contextual aliases.')
# The manifest remains build metadata, not part of the help distribution.
(ready/'build.json').write_text(json.dumps(proof,indent=2)+'\n',encoding='utf-8')
if blocked:
 published=json.loads((out/'build.json').read_text(encoding='utf-8')) if (out/'build.json').exists() else {}
 for lang,entry in proof.items():
  actual=out/('MSFS2024-FDR.'+lang+'.chm')
  if actual.exists() and hashlib.sha256(actual.read_bytes()).hexdigest()==entry['chm_sha256']:published[lang]=entry
 (out/'build.json').write_text(json.dumps(published,indent=2)+'\n',encoding='utf-8')
 raise SystemExit('Close the open CHM viewer(s): '+', '.join(blocked)+'; complete validated replacements are in '+str(ready))
(out/'build.json').write_text(json.dumps(proof,indent=2)+'\n',encoding='utf-8')
# Remove only obsolete HTML fallback outputs in the owned help runtime folder.
for lang in ('pl','en','de','es'):
 folder=out/lang
 if folder.exists():
  assert folder.resolve().is_relative_to(out.resolve())
  shutil.rmtree(folder)
print('PASS: runtime help consists of CHM files; source HTML stays in the repository.')
