"""Check explicit project unit paths and DCCReference parity; --fix adds missing declarations.
Vendor/RTL/VCL units remain on their library search paths. XML is patched locally,
not reserialized, so existing IDE configuration and reference metadata survive.
"""
from pathlib import Path
import argparse, collections, os, re, xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
NS={'m':'http://schemas.microsoft.com/developer/msbuild/2003'}
TOKEN=re.compile(r"\{[\s\S]*?\}|\(\*[\s\S]*?\*\)|//[^\r\n]*|'(?:''|[^'])*'|[A-Za-z_][\w]*(?:\.[A-Za-z_][\w]*)*|[,;]",re.I)
def project_sources():
    excluded={'vendor','bin','dist','.build','.git','__history','__recovery'}
    return sorted(p for p in ROOT.rglob('*.dpr')
                  if not (set(p.relative_to(ROOT).parts)&excluded)
                  and p.relative_to(ROOT).parts[:2]!=('src','Common'))
def uses(text):
    tokens=[m for m in TOKEN.finditer(text) if not m[0].startswith(('{','(*','//'))]
    start=next((i for i,t in enumerate(tokens) if t[0].lower()=='uses'),None)
    if start is None:return []
    result=[];i=start+1
    while i<len(tokens) and tokens[i][0]!=';':
        name=tokens[i];i+=1
        if not re.fullmatch(r'[A-Za-z_][\w.]*',name[0]):raise ValueError('Unexpected uses token '+name[0])
        path=None
        if tokens[i][0].lower()=='in':
            i+=1;path=tokens[i][0][1:-1].replace("''", "'");i+=1
        result.append((name[0],name.end(),path))
        if tokens[i][0]==',':i+=1
        elif tokens[i][0]!=';':raise ValueError('Expected uses separator after '+name[0])
    return result

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--fix',action='store_true');args=parser.parse_args()
    roots=[ROOT/'tests',ROOT/'src',ROOT/'tools',ROOT.parent/'setup-core/src',ROOT.parent/'setup-common/src',ROOT.parent/'MSFS2024-FDR-Setup/src']
    index=collections.defaultdict(list)
    for root in roots:
        for path in root.rglob('*.pas'):
            if not any(x in path.parts for x in ('__history','__recovery','vendor')):index[path.stem.lower()].append(path.resolve())
    sources=project_sources();errors=[];path_count=ref_count=0
    for source in sources:
        project=source.with_suffix('.dproj')
        if not project.exists():errors.append(f'{source.relative_to(ROOT)}: missing DPROJ');continue
        text=source.read_text(encoding='utf-8-sig');xml=project.read_text(encoding='utf-8-sig')
        tree=E.fromstring(xml);refs={str((project.parent/n.get('Include').replace('\\',os.sep)).resolve()).lower():n for n in tree.findall('.//m:DCCReference',NS)}
        entries=uses(text)
        names={name.lower() for name,_,_ in entries}
        for ref in tree.findall('.//m:DCCReference',NS):
            filename=Path(ref.get('Include').replace('\\','/'))
            if filename.suffix.lower()=='.pas' and filename.stem.lower() not in names:
                errors.append(f'{project.name}: DCCReference absent from uses: {filename}')
        edits=[];additions=[]
        for name,end,declared in entries:
            matches=index.get(name.lower(),[])
            if declared:
                target=(source.parent/declared.replace('\\',os.sep)).resolve()
                if not target.is_file():errors.append(f'{source.name}: missing source {declared}');continue
            elif not matches:continue
            elif len(matches)>1:
                local=[p for p in matches if p.parent==source.parent.resolve()]
                if len(local)!=1:errors.append(f'{source.name}: ambiguous project unit {name}: {matches}');continue
                target=local[0]
            else:target=matches[0]
            if target.stem.lower()!=name.lower():
                errors.append(f'{source.name}: {name} points to a different unit filename {target.name}');continue
            relative=os.path.relpath(target,source.parent).replace('/', '\\')
            if not declared:
                if not args.fix:errors.append(f'{source.name}: {name} needs In {relative}')
                else:edits.append((end, " In '"+relative.replace("'", "''")+"'"));path_count+=1
            if str(target).lower() not in refs:
                if not args.fix:errors.append(f'{project.name}: missing DCCReference {relative}')
                else:
                    metadata=''
                    dfm=target.with_suffix('.dfm')
                    if dfm.exists():
                        first=dfm.read_text(encoding='utf-8-sig').splitlines()[0]
                        match=re.match(r'(?:object|inherited)\s+(\w+)\s*:\s*(\w+)',first,re.I)
                        if match:
                            metadata='<Form>'+match[1]+'</Form>'
                            if 'fra' in match[2].lower():metadata+='<FormType>dfm</FormType><DesignClass>TFrame</DesignClass>'
                    include=relative.replace('&','&amp;').replace('"','&quot;')
                    additions.append('<DCCReference Include="'+include+'">'+metadata+'</DCCReference>' if metadata else '<DCCReference Include="'+include+'"/>');ref_count+=1
        if args.fix:
            for position,value in reversed(edits):text=text[:position]+value+text[position:]
            if edits:source.write_text(text,encoding='utf-8-sig')
            if additions:
                pos=xml.find('<Import ')
                if pos<0:pos=xml.rfind('</Project>')
                xml=xml[:pos]+'<ItemGroup>\n        '+'\n        '.join(additions)+'\n    </ItemGroup>\n    '+xml[pos:]
                E.fromstring(xml)
                project.write_text(xml,encoding='utf-8-sig')
    if errors:raise SystemExit('\n'.join(errors))
    print(f'PASS: {len(sources)} DPR projects; explicit project unit paths and DCCReference parity. Added {path_count} paths, {ref_count} references.')
if __name__=='__main__':main()
