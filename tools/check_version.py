"""Validate shared, consistent VersionInfo without configuration overrides."""
from pathlib import Path
import re,xml.etree.ElementTree as E
r=Path(__file__).resolve().parents[1];ns={'m':'http://schemas.microsoft.com/developer/msbuild/2003'}
t=E.parse(r/'src/MSFS2024-FDR.dproj').getroot();groups=t.findall('m:PropertyGroup',ns)
base=next(g for g in groups if g.get('Condition')=="'$(Base)'!=''")
v=[int(base.findtext('m:'+k,'0',ns)) for k in ['VerInfo_MajorVer','VerInfo_MinorVer','VerInfo_Release','VerInfo_Build']]
assert all(0<=n<=65535 for n in v)
for g in groups:
 if g is base:continue
 assert not any(c.tag.split('}')[-1].startswith('VerInfo_') for c in g),'Version overrides must not shadow All Configurations'
keys=base.findtext('m:VerInfo_Keys','',ns);assert 'FileVersion='+'.'.join(map(str,v))+';' in keys
s=(r/'src/MSFS2024-FDR.dpr').read_text(encoding='utf-8-sig');assert "{$R 'MSFS2024-FDR.res'}" in s
assert 'VersionU' in s and 'ProductVersion=' in keys
print('PASS: shared VersionInfo '+'.'.join(map(str,v))+'; no platform/config overrides; project resource linked.')
