"""Build a binary-only flightsim.to REVIEW ZIP; no upload or source publication.

Uses an explicit runtime allowlist; Community add-ons are excluded.
The current AGPL-derived project needs a Corresponding Source arrangement before
public distribution; see docs/flightsim-to/Publication-readiness.en.txt.
"""
from pathlib import Path
import argparse, ctypes, hashlib, json, struct, zipfile, re

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, default=ROOT/'dist/flightsim-to')
a = p.parse_args()
assets = ROOT/'docs/flightsim-to'
out = a.output
out.mkdir(parents=True, exist_ok=True)
version = re.search(r'FileVersion=([^;]+)', (ROOT/'src/MSFS2024-FDR.dproj').read_text(encoding='utf-8-sig')).group(1)
name = 'MSFS2024-FDR-Win64-'+version
entries = {}
def add(path, destination):
    path = Path(path)
    assert path.is_file(), path
    assert destination not in entries, destination
    entries[destination] = path.read_bytes()
def runtime(relative):
    add(ROOT/'bin'/relative, 'MSFS2024-FDR/'+relative)
for n in ['MSFS2024-FDR.exe','MSFS2024-FDR.pdb','SimConnect.dll','sqlite3.dll','WebView2Loader.dll','MSFS2024-FDR.i18n']:
    runtime(n)
assert entries['MSFS2024-FDR/MSFS2024-FDR.pdb'].startswith(b'Microsoft C/C++ MSF 7.00'), 'Missing/invalid diagnostics PDB'
for n in ['MSFS2024-FDR.exe','SimConnect.dll','sqlite3.dll','WebView2Loader.dll']:
    b = entries['MSFS2024-FDR/'+n]
    pe = struct.unpack_from('<I', b, 0x3c)[0]
    assert b[pe:pe+4] == b'PE\0\0' and struct.unpack_from('<H', b, pe+4)[0] == 0x8664, n
assert (ROOT/'bin/MSFS2024-FDR.exe').stat().st_mtime >= max(
    x.stat().st_mtime for x in (ROOT/'src').rglob('*')
    if x.suffix.lower() in {'.pas','.dfm','.dpr','.dproj'} and not any(y in ('__history','__recovery') for y in x.parts)
), 'Release executable is older than a source file; rebuild Release first'
for f in (ROOT/'bin/fonts').glob('*'):
    if f.is_file(): runtime('fonts/'+f.name)
font_manifest=json.loads((ROOT/'assets/fonts/manifest.json').read_text(encoding='utf-8'))
for font_name,info in font_manifest.items():
    key='MSFS2024-FDR/fonts/'+font_name
    assert key in entries and hashlib.sha256(entries[key]).hexdigest()==info['sha256'], ('Font package incomplete',font_name)
for f in ROOT.glob('Translation.*.md'): add(f,'MSFS2024-FDR/'+f.name)
for f in (ROOT/'bin/help').rglob('*'):
    if f.is_file() and f.suffix.lower() in {'.chm','.htm'}:
        runtime(f.relative_to(ROOT/'bin').as_posix())
add(assets/'START-HERE.en.txt','MSFS2024-FDR/START-HERE.en.txt')
add(ROOT/'bin/settings.example.ini','MSFS2024-FDR/settings.example.ini')
add(ROOT/'LICENSE','MSFS2024-FDR/LICENSE')
add(ROOT/'NOTICE.en.md','MSFS2024-FDR/NOTICE.en.md')
add(ROOT/'vendor/WebView4Delphi-main/LICENSE','MSFS2024-FDR/licenses/WebView4Delphi-LICENSE.txt')
add(ROOT/'support/i18n/LICENSE','MSFS2024-FDR/licenses/i18n-LICENSE.txt')
add(ROOT/'vendor/Delphi-StackTrace/License','MSFS2024-FDR/licenses/Delphi-StackTrace-LICENSE.txt')
add(ROOT/'support/flightpad/LICENSE.md','MSFS2024-FDR/licenses/FlightPadFMC-LICENSE.txt')
add(assets/'WebView2Loader-LICENSE.txt','MSFS2024-FDR/licenses/WebView2Loader-LICENSE.txt')
for f in (ROOT/'support').rglob('*.en.md'):
    add(f,'MSFS2024-FDR/docs/support/'+f.relative_to(ROOT/'support').as_posix())
add(assets/'Third-party-notices.en.txt','MSFS2024-FDR/licenses/Third-party-notices.en.txt')
assert not any('community/' in n.lower() or 'mateusz-efb-ifly' in n.lower() for n in entries), 'Community addon must not be bundled'
for loc in ['pl','en','de','es']:
    assert entries[f'MSFS2024-FDR/help/MSFS2024-FDR.{loc}.chm'][:4] == b'ITSF'
    assert f'MSFS2024-FDR/help/{loc}/overview.htm' in entries
for n in entries:
    assert not n.lower().endswith(('.pas','.dpr','.dfm','.dproj','.db','.db-wal','.db-shm','.log','.rsm','.dcu','.bpl','.zip')), n
    assert Path(n).name not in {'settings.ini','simbrief-latest.json'}, n
config=entries['MSFS2024-FDR/settings.example.ini'].decode('utf-8-sig').replace('\r\n','\n')
assert 'language=auto' in config and 'username=\n' in config and 'gemini_api_key=\n' in config
assert b'InzGermanista' not in b'\n'.join(v for k,v in entries.items() if k.endswith(('.ini','.txt','.md')))
entries['MSFS2024-FDR/BUILD-INFO.json'] = json.dumps({
    'build':version+' Win64 Release preview',
    'distribution_status':'binary-only review; resolve AGPL Corresponding Source before public distribution',
    'executable_sha256':hashlib.sha256(entries['MSFS2024-FDR/MSFS2024-FDR.exe']).hexdigest(),
    'source_included':False,'recordings_included':False,'private_settings_included':False,
    'community_addons_included':False,
},indent=2).encode()
archive=out/(name+'.zip')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for n,data in sorted(entries.items()):z.writestr(n,data)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert len(z.namelist())==len(set(z.namelist()))
    assert all(z.read(n)==data for n,data in entries.items())
    extract=out/'.verification'/name
    extract.mkdir(parents=True,exist_ok=True)
    z.extractall(extract)
    handles=[]
    for n in ['SimConnect.dll','sqlite3.dll','WebView2Loader.dll']:
        handles.append(ctypes.WinDLL(str(extract/'MSFS2024-FDR'/n)))
    sqlite=handles[1];sqlite.sqlite3_libversion.restype=ctypes.c_char_p
    sqlite_version=sqlite.sqlite3_libversion().decode('ascii')
shots=out/'MSFS2024-FDR-Screenshots.zip'
with zipfile.ZipFile(shots,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for f in sorted((assets/'screenshots').glob('*.png')):z.write(f,f.name)
    z.write(assets/'Screenshot-captions.en.txt','Screenshot-captions.en.txt')
assert len(list((assets/'screenshots').glob('*.png')))==5
for f in [archive,shots]:
    digest=hashlib.sha256(f.read_bytes()).hexdigest()
    (out/(f.name+'.sha256')).write_text(digest+'  '+f.name+'\n',encoding='ascii')
report=(f'PASS: fresh Win64 Release; {len(entries)} runtime ZIP files; CRC/read-back; all PEs x64; '
        f'three runtime DLLs load from extracted ZIP; SQLite {sqlite_version}; '
        'four CHMs and HTML help; no Community add-on; '
        'five English screenshots; no Pascal source, recordings, private configuration or account cache.\n'
        'No public upload. Binary-only review package still requires an AGPL source-distribution arrangement.\n')
(out/'Package-verification.en.txt').write_text(report,encoding='utf-8')
print(report)
print(archive, archive.stat().st_size)
print(shots, shots.stat().st_size)
