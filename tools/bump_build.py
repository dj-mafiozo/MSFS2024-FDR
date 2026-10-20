"""Increment only the shared Delphi VersionInfo Build number once per change set."""
from pathlib import Path
import argparse,re,xml.etree.ElementTree as E
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--project',type=Path,default=Path(__file__).resolve().parents[1]/'src/MSFS2024-FDR.dproj')
a=p.parse_args();text=a.project.read_text(encoding='utf-8-sig');ns={'m':'http://schemas.microsoft.com/developer/msbuild/2003'}
tree=E.fromstring(text);base=next(g for g in tree.findall('m:PropertyGroup',ns) if g.get('Condition')=="'$(Base)'!=''")
values=[int(base.findtext('m:'+tag,'0',ns)) for tag in ['VerInfo_MajorVer','VerInfo_MinorVer','VerInfo_Release','VerInfo_Build']]
assert values[3]<65535,'Build cannot exceed 65535';values[3]+=1
# Never roll over or rewrite Major/Minor/Release/ProductVersion/company metadata.
block=re.search(r'<PropertyGroup Condition="\'\$\(Base\)\'!=\'\'">[\s\S]*?</PropertyGroup>',text)
assert block,'Shared Base configuration not found';updated=block.group()
updated=re.sub(r'<VerInfo_Build>\d+</VerInfo_Build>',f'<VerInfo_Build>{values[3]}</VerInfo_Build>',updated)
number='.'.join(map(str,values));updated=re.sub(r'FileVersion=[^;]*;',f'FileVersion={number};',updated)
text=text[:block.start()]+updated+text[block.end():];a.project.write_text(text,encoding='utf-8-sig');print(number)
