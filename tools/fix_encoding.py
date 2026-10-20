"""Use Delphi character codes so Delphi 10.2/IDE ANSI defaults cannot corrupt labels."""
import pathlib,re
root=pathlib.Path(__file__).resolve().parents[1]/'src'
def literal(s):
    parts=[];chunk=''
    for c in s:
        if ord(c)<128:chunk+=c
        else:
            if chunk:parts.append("'"+chunk.replace("'","''")+"'");chunk=''
            parts.append('#'+str(ord(c)))
    if chunk:parts.append("'"+chunk.replace("'","''")+"'")
    return ''.join(parts) or "''"
captions={'OpenButton':'Otwórz bazę','RefreshButton':'Odśwież','FitButton':'Dopasuj trasę','DeleteButton':'Usuń wybrany lot','ApplyButton':'Pokaż wybrane wykresy (do 8)','RenameGroupButton':'Zmień nazwę grupy','DeleteGroupButton':'Usuń grupę (zachowaj loty)','AnalysisLandingButton':'Analiza AI ostatniego lądowania','AnalysisLiftoffButton':'Analiza AI ostatniego startu','ImageButton':'Zapisz mapę PNG'}
for p in root.glob('*'):
    if p.suffix.lower() not in ['.pas','.inc','.dfm']:continue
    s=p.read_text(encoding='utf-8-sig')
    if p.suffix.lower()=='.dfm':
        component=''
        lines=[]
        for line in s.splitlines():
            m=re.search(r'object (\w+):',line)
            if m:component=m[1]
            if re.match(r'\s*Caption\s*=',line) and component in captions:line=re.sub(r'=.*','= '+literal(captions[component]),line)
            lines.append(line)
        s='\n'.join(lines)+'\n'
    def encode(m):
        value=m[0][1:-1].replace("''","'")
        return literal(value) if any(ord(c)>127 for c in value) else m[0]
    p.write_text(re.sub(r"'(?:''|[^'])*'",encode,s),encoding='ascii',errors='backslashreplace')
