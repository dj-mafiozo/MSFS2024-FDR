"""Convert public.pem to a compile-time RSA-3072 CNG public blob. No private input."""
from pathlib import Path
import base64,re,struct,argparse
p=argparse.ArgumentParser();p.add_argument('public',type=Path);p.add_argument('include',type=Path);a=p.parse_args()
b=base64.b64decode(''.join(x for x in a.public.read_text().splitlines() if not x.startswith('---')),validate=True)
def node(data,pos=0):
 tag=data[pos];length=data[pos+1];pos+=2
 if length&128:
  count=length&127;length=int.from_bytes(data[pos:pos+count],'big');pos+=count
 return tag,data[pos:pos+length],pos+length
tag,seq,end=node(b);assert tag==48 and end==len(b)
_,alg,pos=node(seq);assert alg==bytes.fromhex('06092a864886f70d0101010500'),'RSA key required'
tag,bit,end=node(seq,pos);assert tag==3 and bit[0]==0 and end==len(seq)
tag,rsa,end=node(bit[1:]);assert tag==48
tag,n,pos=node(rsa);assert tag==2;n=n.lstrip(b'\0')
tag,e,end=node(rsa,pos);assert tag==2 and end==len(rsa);e=e.lstrip(b'\0')
assert len(n)==384 and n[0]&128,'RSA-3072 required'
blob=struct.pack('<6I',0x31415352,3072,len(e),len(n),0,0)+e+n
content='{ FLD+ }\nConst PinnedPublicKey:array[0..%d] of Byte=(\n'% (len(blob)-1)+',\n'.join('$%02X'%v for v in blob)+');\n{ FLD- }\n'
if not a.include.exists() or a.include.read_text(encoding='utf-8-sig')!=content:a.include.write_text(content,encoding='utf-8-sig')
print('Pinned RSA-3072 public key; installer verification never reads a PEM file.')
