"""Build local HTML/CHM help. HTML remains usable without HTML Help Workshop."""
from pathlib import Path
import os, shutil, subprocess, sys, re, tempfile
root=Path(__file__).resolve().parents[1]
compiler=Path(os.environ.get('HHC_EXE',r'C:\Program Files (x86)\HTML Help Workshop\hhc.exe'))
for lang in ('pl','en','de','es'):
    source=root/'help'/lang
    out=root/'bin/help';out.mkdir(parents=True,exist_ok=True)
    html_out=out/lang;html_out.mkdir(exist_ok=True)
    for path in source.glob('*.htm'):shutil.copy2(path,html_out/path.name)
    if not compiler.exists():
        if '--require-chm' in sys.argv:raise SystemExit('HTML Help Workshop hhc.exe not found; set HHC_EXE.')
        print('HTML only:',lang,'(install HTML Help Workshop to generate CHM)');continue
    # Old HTML Help Workshop misparses some dotted/long project paths; compile in an owned temp directory.
    temp_root=Path(os.environ.get('LOCALAPPDATA',tempfile.gettempdir()))/'Temp'
    temp_root.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='MSFSFDRHelp',dir=temp_root) as directory:
        scratch=Path(directory).resolve()
        assert scratch.is_relative_to(temp_root.resolve())
        for path in source.iterdir():
            if path.suffix in ('.htm','.hhp','.hhc','.h'):shutil.copy2(path,scratch/path.name)
        output=scratch/('MSFS2024-FDR.'+lang+'.chm')
        environment=os.environ.copy();environment.update(TEMP=str(scratch),TMP=str(scratch))
        run=subprocess.run([str(compiler),str(scratch/'help.hhp')],cwd=scratch,env=environment,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45)
        message=run.stdout.decode('mbcs',errors='replace')
        log=root/'.build'/('help-'+lang+'.log');log.parent.mkdir(exist_ok=True);log.write_text(message,encoding='utf-8')
        if run.returncode not in (0,1) or not output.exists() or output.read_bytes()[:4]!=b'ITSF' or re.search(r'(?im)^.*Error:',message):
            raise SystemExit('CHM compilation failed: '+lang+'; see '+str(log))
        shutil.copy2(output,out/output.name)
        print('PASS: compiled',output.name,'with six context topics; HTML fallback deployed')
