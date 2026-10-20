import pathlib,re
for p in (pathlib.Path(__file__).resolve().parents[1]/'src').rglob('*.pas'):
    s=p.read_text()
    def split(m):
        value=m[0][1:-1].replace("''","'")
        if len(value)<=250:return m[0]
        return '+'.join("'"+value[i:i+200].replace("'","''")+"'" for i in range(0,len(value),200))
    p.write_text(re.sub(r"'(?:''|[^'])*'",split,s))
