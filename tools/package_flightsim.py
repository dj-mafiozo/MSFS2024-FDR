"""Build the complete unencrypted portable runtime for GitHub Releases/flightsim.to.
No installer implementation, password provider, private key or upload is involved.
"""
from pathlib import Path
import argparse,ctypes,hashlib,json,re,shutil,struct,subprocess,sys,zipfile
ROOT=Path(__file__).resolve().parents[1]
def exe_version(path):
    lib=ctypes.WinDLL('version',use_last_error=True)
    lib.GetFileVersionInfoSizeW.argtypes=[ctypes.c_wchar_p,ctypes.c_void_p]
    lib.GetFileVersionInfoW.argtypes=[ctypes.c_wchar_p,ctypes.c_uint,ctypes.c_uint,ctypes.c_void_p]
    lib.VerQueryValueW.argtypes=[ctypes.c_void_p,ctypes.c_wchar_p,ctypes.POINTER(ctypes.c_void_p),ctypes.POINTER(ctypes.c_uint)]
    size=lib.GetFileVersionInfoSizeW(str(path),None)
    if not size:raise RuntimeError('Missing/unreadable executable VersionInfo: '+str(path))
    data=ctypes.create_string_buffer(size)
    if not lib.GetFileVersionInfoW(str(path),0,size,data):raise RuntimeError('Cannot read VersionInfo')
    pointer=ctypes.c_void_p();length=ctypes.c_uint()
    if not lib.VerQueryValueW(data,'\\',ctypes.byref(pointer),ctypes.byref(length)):raise RuntimeError('Invalid VersionInfo')
    fixed=struct.unpack('<13I',ctypes.string_at(pointer,52));a,b=fixed[2:4]
    return '.'.join(map(str,[a>>16,a&65535,b>>16,b&65535]))
def validate_manifest(path):
    # Parse the actual EXE manifest without starting the recorder or touching user data.
    class Context(ctypes.Structure):
        _fields_=[('cbSize',ctypes.c_uint),('dwFlags',ctypes.c_uint),('lpSource',ctypes.c_wchar_p),('wProcessorArchitecture',ctypes.c_ushort),('wLangId',ctypes.c_ushort),('lpAssemblyDirectory',ctypes.c_wchar_p),('lpResourceName',ctypes.c_void_p),('lpApplicationName',ctypes.c_wchar_p),('hModule',ctypes.c_void_p)]
    lib=ctypes.WinDLL('kernel32',use_last_error=True)
    lib.CreateActCtxW.argtypes=[ctypes.POINTER(Context)];lib.CreateActCtxW.restype=ctypes.c_void_p
    lib.ReleaseActCtx.argtypes=[ctypes.c_void_p]
    context=Context();context.cbSize=ctypes.sizeof(Context);context.dwFlags=8
    context.lpSource=str(path);context.lpResourceName=1
    handle=lib.CreateActCtxW(ctypes.byref(context))
    if handle==ctypes.c_void_p(-1).value:raise ctypes.WinError(ctypes.get_last_error())
    lib.ReleaseActCtx(handle)
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def build(output=None):
    help_output=ROOT/'.build/help-ready'
    subprocess.run([sys.executable,str(ROOT/'tools/build_help.py'),'--require-chm','--output',str(help_output)],check=True)
    binary=ROOT/'bin'
    version=re.search(r'FileVersion=([^;]+)',(ROOT/'src/MSFS2024-FDR.dproj').read_text(encoding='utf-8-sig'))[1]
    out=Path(output) if output else ROOT/'dist'/('portable-'+version)
    out.mkdir(parents=True,exist_ok=True)
    archive=out/('MSFS2024-FDR-Win64-'+version+'.zip')
    if archive.exists():raise RuntimeError('Refusing to overwrite release ZIP: '+str(archive))
    for name in ['MSFS2024-FDR.exe','MSFS24-FDR-Setup.exe']:
        if exe_version((binary/name).resolve())!=version:raise RuntimeError('Version mismatch: '+name)
        validate_manifest((binary/name).resolve())
    subprocess.run([sys.executable,str(ROOT/'tools/build_bridge_addon.py')],check=True)
    required={'MSFS2024-FDR.exe','MSFS24-FDR-Setup.exe','MSFS2024-FDR.pdb','SimConnect.dll','sqlite3.dll','MSFS2024-FDR.i18n','settings.example.ini','LICENSE','NOTICE.en.md'}
    allowed={'.md','.txt','.png','.svg','.html','.htm','.css','.js','.chm','.ttf','.ttc','.spb'}
    directories={'Assets','fonts','help','licenses','support','translations','runtime','community','Optional-Community'}
    entries={}
    for path in binary.rglob('*'):
        if not path.is_file():continue
        relative=path.relative_to(binary);parts=relative.parts
        if any(x.lower() in {'logs','recordings','cache','__history','__recovery','.git'} for x in parts):continue
        if len(parts)==1:include=path.name in required or path.suffix.lower() in {'.md','.txt'}
        else:
            include=parts[0] in directories and path.suffix.lower() in allowed
            if parts[0]=='help':include=len(parts)==2 and path.suffix.lower()=='.chm'
            if relative.as_posix()=='fonts/manifest.json':include=True
            if parts[0]=='Optional-Community':
                include=len(parts)>2 and parts[1]=='MSFS24-FDR-Bridge' and (path.suffix.lower() in allowed or path.name in {'manifest.json','layout.json'})
        if include:entries[relative.as_posix()]=path
    for locale in ['pl','en','de','es']:
        entries['help/MSFS2024-FDR.'+locale+'.chm']=help_output/('MSFS2024-FDR.'+locale+'.chm')
    for name in required:assert name in entries,name
    for image in ['A320-MCDU.png','B737-FMC.png','B777-FMC.png']:assert 'Assets/'+image in entries,image
    for locale in ['pl','en','de','es']:
        name='help/MSFS2024-FDR.'+locale+'.chm';assert entries[name].read_bytes()[:4]==b'ITSF',name
    fonts=json.loads((binary/'fonts/manifest.json').read_text(encoding='utf-8-sig'))
    for name,info in fonts.items():
        data=entries['fonts/'+name].read_bytes()
        if name.endswith('.txt'):data=data.replace(b'\r\n',b'\n')
        assert hashlib.sha256(data).hexdigest()==info['sha256'],name
    for name in ['MSFS2024-FDR.exe','MSFS24-FDR-Setup.exe','SimConnect.dll','sqlite3.dll']:
        data=entries[name].read_bytes();pe=struct.unpack_from('<I',data,0x3c)[0]
        assert data[pe:pe+4]==b'PE\0\0' and struct.unpack_from('<H',data,pe+4)[0]==0x8664,name
    # Current repository docs replace any stale generated copies in bin.
    for path in ROOT.glob('*.md'):
        if path.name!='AGENTS.md':entries[path.name]=path
    for base in ['support','translations','runtime']:
        for path in (ROOT/base).rglob('*.md'):entries[path.relative_to(ROOT).as_posix()]=path
    for name in ['START-HERE.en.txt','Optional-Community-INSTALL.en.txt']:
        entries[name]=ROOT/'docs/flightsim-to'/name
    for path in (ROOT/'docs/releases').glob('0.1.1.*.md'):
        entries['Release-notes'+path.name[len('0.1.1'):]]=path
    for folder,name in [(ROOT/'src/Common','Common-LICENSE.txt'),(ROOT.parent/'setup-common','setup-common-LICENSE.txt')]:
        entries['licenses/'+name]=folder/'LICENSE'
    config=entries['settings.example.ini'].read_text(encoding='utf-8-sig')
    assert re.search(r'^username=\s*$',config,re.M) and re.search(r'^gemini_api_key=\s*$',config,re.M),'Nonempty example credentials'
    for name in entries:
        assert Path(name).name.lower() not in {'settings.ini','simbrief-latest.json','private.pem','zippasswordu.pas','congratulations.mfz'}
        assert Path(name).suffix.lower() not in {'.res','.rsm','.pas','.dcu','.db','.mfzr','.mfzi','.pem'}
        assert 'mateusz-efb-ifly' not in name.lower()
    info={'version':version,'platform':'Win64','distribution':'portable','password_required':False,'setup':'notice-only placeholder','updates_enabled':False,'recordings_included':False,'personal_settings_included':False,'optional_community_addon':'MSFS24-FDR-Bridge','executable_sha256':digest(entries['MSFS2024-FDR.exe'])}
    temporary=Path(str(archive)+'.partial')
    try:
        with zipfile.ZipFile(temporary,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
            for name,path in sorted(entries.items()):z.write(path,'MSFS2024-FDR/'+name)
            z.writestr('MSFS2024-FDR/BUILD-INFO.json',json.dumps(info,indent=2)+'\n')
        with zipfile.ZipFile(temporary) as z:
            assert not any('/help/' in n and not n.lower().endswith('.chm') for n in z.namelist()),'Only CHM may ship as help'
            assert z.testzip() is None,'CRC failure'
            assert not any(i.flag_bits&1 for i in z.infolist()),'Unexpected encryption'
            names=z.namelist();assert len(names)==len(set(names))
            prefix='MSFS2024-FDR/Optional-Community/MSFS24-FDR-Bridge/'
            for item in json.loads(z.read(prefix+'layout.json'))['content']:
                assert len(z.read(prefix+item['path']))==item['size'],item['path']
            for doc in ['changelog.md','CHANGELOG.en.md','Release-notes.en.md','Release-notes.pl.md']:
                assert z.read('MSFS2024-FDR/'+doc)==entries[doc].read_bytes(),'Stale documentation: '+doc
        temporary.rename(archive)
    finally:
        if temporary.exists():temporary.unlink()
    checksum=digest(archive)
    Path(str(archive)+'.sha256').write_text(checksum+'  '+archive.name+'\n',encoding='ascii')
    report=f"""MSFS2024-FDR {version} portable Win64
Archive: {archive.name}
Size: {archive.stat().st_size} bytes
Files: {len(names)}
SHA-256: {checksum}

PASS: no encryption, all CRCs/decompression valid.
PASS: app/stub versions match and native activation contexts validate; application, stub and DLLs are Win64.
PASS: runtime, PDB, help, graphics, fonts, translations and licenses present.
PASS: optional plain bridge complete; current changelog and release notes included.
PASS: no RES/source, recordings, personal settings, private provider, keys or decoy.
Setup is a notice-only stub; update checks remain disabled.
Same archive for GitHub Releases and flightsim.to. No upload performed.
"""
    (out/'Package-verification.en.txt').write_text(report,encoding='utf-8')
    for path in (ROOT/'docs/releases').glob('0.1.1.*.md'):shutil.copy2(path,out/path.name)
    print(json.dumps({'archive':str(archive),'bytes':archive.stat().st_size,'MiB':round(archive.stat().st_size/1048576,2),'files':len(names),'sha256':checksum},indent=2))
    return archive
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path);args=p.parse_args();build(args.output)
