import pathlib,struct
root=pathlib.Path(__file__).resolve().parents[1]
data=(root/'bin/MSFS2024-FDR.exe').read_bytes()
pe=struct.unpack_from('<I',data,0x3c)[0]
machine,sections=struct.unpack_from('<HH',data,pe+4)
assert machine==0x8664,'Expected Win64 executable'
optional=pe+24;size=struct.unpack_from('<H',data,pe+20)[0]
def offset(rva):
    for i in range(sections):
        row=optional+size+i*40
        virtual,addr,raw,position=struct.unpack_from('<IIII',data,row+8)
        if addr<=rva<addr+max(virtual,raw):return position+rva-addr
    raise ValueError(rva)
import_rva=struct.unpack_from('<I',data,optional+120)[0]
p=offset(import_rva);names=[]
while any(data[p:p+20]):
    name_rva=struct.unpack_from('<I',data,p+12)[0];n=offset(name_rva)
    names.append(data[n:data.index(b'\0',n)].decode('ascii'));p+=20
assert not any(('qt' in n.lower()) or ('webview' in n.lower()) for n in names),names
for token in (b'WebView2Loader.dll',b'W\x00e\x00b\x00V\x00i\x00e\x00w\x002\x00L\x00o\x00a\x00d\x00e\x00r\x00.\x00d\x00l\x00l\x00'):
    assert token not in data,'Obsolete browser loader reference in EXE'
for source in (root/'src').rglob('*.pas'):
    if source.name not in ('ZipPasswordU.pas','ZipPassword-ExampleU.pas') and not any(part in ('__history','__recovery','MSFS24-FDR-Setup') for part in source.parts):
        assert 'uwvbrowser' not in source.read_text(encoding='utf-8-sig').lower(),source
result='PASS: Win64 PE imports contain no Qt. Reports and FMC displays use native VCL controls.\n'+', '.join(names)+'\n'
(root/'tests/dependencies.log').write_text(result)
print(result)
