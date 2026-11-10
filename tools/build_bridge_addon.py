"""Stage the optional MSFS weather panel; rebuild its SPB with the SDK when requested."""
from pathlib import Path
import argparse,json,shutil,subprocess
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--compiler',type=Path);a=p.parse_args()
 source=ROOT/'community/Bridge';spb=source/'Compiled/InGamePanel_FDRBridge.spb'
 if a.compiler:
  output=ROOT/'.build/bridge-addon';temp=ROOT/'.build/bridge-addon-temp'
  subprocess.run([str(a.compiler),str(source/'Project.xml'),'-outputdir',str(output),'-tempdir',str(temp),'-rebuild','-nopause'],check=True)
  shutil.copy2(output/'Packages/msfs24-fdr-bridge/InGamePanels/InGamePanel_FDRBridge.spb',spb)
 if not spb.is_file() or spb.stat().st_size<100:raise SystemExit('Compile the panel SPB with the MSFS SDK first')
 target=ROOT/'bin/Optional-Community/MSFS24-FDR-Bridge';(target/'InGamePanels').mkdir(parents=True,exist_ok=True)
 shutil.copy2(spb,target/'InGamePanels'/spb.name)
 shutil.copytree(source/'html_ui',target/'html_ui',dirs_exist_ok=True)
 entries=[]
 for f in sorted(target.rglob('*')):
  if f.is_file() and f.name not in {'manifest.json','layout.json'}:
   entries.append({'path':f.relative_to(target).as_posix(),'size':f.stat().st_size,'date':int((f.stat().st_mtime+11644473600)*10000000)})
 manifest={'dependencies':[],'content_type':'INSTRUMENTS','title':'MSFS24-FDR-Bridge','manufacturer':'','creator':'DJ M@fi0z0','package_version':'1.0.0','minimum_game_version':'1.9.21','release_notes':{'neutral':{'LastUpdate':'','OlderHistory':''}},'total_package_size':sum(e['size'] for e in entries)}
 (target/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
 (target/'layout.json').write_text(json.dumps({'content':entries},indent=2),encoding='utf-8')
 print('PASS: optional weather package staged:',len(entries),'files')
if __name__=='__main__':main()
