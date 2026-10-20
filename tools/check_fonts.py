"""Validate redistributable font files, provenance hashes and OFL licenses."""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parents[1]
fonts=root/'assets/fonts'
manifest=json.loads((fonts/'manifest.json').read_text(encoding='utf-8'))
required={'NotoSans-Regular.ttf','NotoSansArabic-Regular.ttf','NotoSansHebrew-Regular.ttf','NotoSansDevanagari-Regular.ttf','NotoSansCJK-Regular.ttc','OFL-Noto.txt','OFL-NotoCJK.txt'}
assert set(manifest)==required
for name,info in manifest.items():
 data=(fonts/name).read_bytes()
 assert len(data)==info['bytes'] and hashlib.sha256(data).hexdigest()==info['sha256'],name
 assert info['url'].startswith('https://raw.githubusercontent.com/notofonts/'),name
 if name.endswith(('.ttf','.ttc')):assert data[:4] in (b'\0\1\0\0',b'OTTO',b'ttcf'),name
 else:assert b'SIL OPEN FONT LICENSE' in data,name
print('PASS: five official Noto font files, two OFL licenses and provenance hashes.')
