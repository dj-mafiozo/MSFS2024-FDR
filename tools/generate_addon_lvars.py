"""Generate read-only literal L-var catalogs from local installed model XML/aircraft.cfg.
Only metadata, variable identifiers and hashes are emitted; source XML is not redistributed.
"""
from pathlib import Path
import argparse,hashlib,html,json,re
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--models-root',type=Path,required=True,help='Subdirectories named PMDGDC6/CSS737/MaddogX/SkySimDC9/SkySimMD11/TFDiMD11, containing XML and aircraft CFG copies')
p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);a=p.parse_args()
profiles=[('PMDGDC6','PMDG DC-6'),('CSS737','CSS 737 Classic'),('MaddogX','Leonardo Maddog X'),('SkySimDC9','SkySim DC-9'),('SkySimMD11','SkySim MD-11'),('TFDiMD11','TFDi Design MD-11')]
fields=[];defs=[];known=[];metadata=[]
def pas(s):return "'"+s.replace("'","''")+"'"
for index,(provider,title) in enumerate(profiles):
 found={};sources=[];excluded=set();titles=set()
 for src in sorted((a.models_root/provider).glob('*.xml')):
  raw=src.read_bytes();text=html.unescape(re.sub(r'<!--[\s\S]*?-->','',raw.decode('utf-8-sig')))
  for name,unit in re.findall(r'\(\s*L:([^,)]+)(?:,([^)]*))?\)',text,re.I):
   name=name.strip();unit=unit.strip()
   if re.fullmatch(r'[A-Za-z_][A-Za-z0-9_ .:\-\[\]]*',name):found.setdefault(name,unit)
   else:excluded.add(name)
  sources.append({'file':src.name,'sha256':hashlib.sha256(raw).hexdigest()})
 for src in sorted((a.models_root/provider).glob('*.cfg')):
  raw=src.read_bytes();text=raw.decode('utf-8-sig',errors='replace')
  for match in re.finditer(r'^\s*title\s*=\s*"?([^";\r\n]+)',text,re.I|re.M):
   if src.name.lower().endswith('aircraft.cfg'):titles.add(match[1].strip())
  sources.append({'file':src.name,'sha256':hashlib.sha256(raw).hexdigest()})
 assert found,provider
 start=len(fields)
 for name in sorted(found,key=str.casefold):fields.append((provider,name,found[name]))
 defs.append((provider,title,start,len(found)))
 known.extend((index,t) for t in sorted(titles))
 metadata.append({'provider':provider,'label':title,'sources':sources,'literal_read_count':len(found),'excluded_dynamic_or_invalid':sorted(excluded),'aircraft_titles':sorted(titles),'fields':[{'name':n,'source_units':found[n]} for n in sorted(found,key=str.casefold)]})

# Official profiles contain only cross-locale verified literal numeric bindings.
official=a.root/'support/official-aircraft/binding-profiles.json'
if official.exists():
 for profile in json.loads(official.read_text(encoding='utf8')):
  provider=profile['provider'];start=len(fields)
  fields.extend((provider,f['name'],f['source_units']) for f in profile['fields'])
  defs.append((provider,profile['label'],start,len(profile['fields'])))
  profile['literal_read_count']=len(profile['fields']);profile['excluded_dynamic_or_invalid']=[];metadata.append(profile)
types=a.root/'src/Aircraft/AddonLVarTypesU.pas'
types.write_text("{$StackFrames On}\nUnit AddonLVarTypesU;\nInterface\nType TAddonLVarField = Record Provider,Name,SourceUnits,DisplayValue : String; End;\n TAddonLVarProfile = Record Provider,Title : String; First,Count : Integer; End;\n TAddonTitle = Record Profile : Integer; Title : String; End;\nImplementation\nEnd.\n",encoding='utf-8-sig')
unitnames=[]
for provider,title,start,count in defs:
 unit=provider+'LVarsU';unitnames.append(unit)
 folder=a.root/'src/Aircraft'/provider;folder.mkdir(parents=True,exist_ok=True)
 text='{$StackFrames On}\nUnit '+unit+';\nInterface\nUses AddonLVarTypesU;\nConst\n '+provider+'Fields : Array[0..'+str(count-1)+'] Of TAddonLVarField = (\n'
 text+=',\n'.join(f" (Provider:{pas(x)};Name:{pas(y)};SourceUnits:{pas(z)};DisplayValue:'')" for x,y,z in fields[start:start+count])+');\nImplementation\nEnd.\n'
 (folder/(unit+'.pas')).write_text(text,encoding='utf-8-sig')
s='{$StackFrames On}\nUnit AddonLVarCatalogU;\nInterface\nUses AddonLVarTypesU;\nType TAddonLVarField = AddonLVarTypesU.TAddonLVarField;\n TAddonLVarProfile = AddonLVarTypesU.TAddonLVarProfile;\nConst\n'
s+=f' AddonProfileCount={len(defs)};\n AddonFieldCount={len(fields)};\n'
s+=' AddonProfiles : Array[0..AddonProfileCount-1] Of TAddonLVarProfile = (\n'+',\n'.join(f' (Provider:{pas(x)};Title:{pas(y)};First:{z};Count:{n})' for x,y,z,n in defs)+');\n'
s+=f' AddonTitles : Array[0..{len(known)-1}] Of TAddonTitle = (\n'+',\n'.join(f' (Profile:{i};Title:{pas(t)})' for i,t in known)+');\n'
s+='Var AddonFields : Array[0..AddonFieldCount-1] Of TAddonLVarField;\nFunction MatchesAddon(Profile : Integer; Const Title : String) : Boolean;\nImplementation\nUses System.SysUtils, '+', '.join(unitnames)+';\n'
s+="""Function MatchesAddon(Profile : Integer; Const Title : String) : Boolean;
Var T : String; I : Integer;
Begin
 Result := False;
 For I := Low(AddonTitles) To High(AddonTitles) Do
  If (AddonTitles[I].Profile=Profile) And SameText(Trim(Title),AddonTitles[I].Title) Then Exit(True);
 T := UpperCase(Title).Replace('-','').Replace('_','').Replace(' ','');
 Case Profile Of
  0: Result := (Pos('PMDG',T)>0) And (Pos('DC6',T)>0);
  1: Result := (Pos('CSS',T)>0) And ((Pos('737',T)>0) Or (Pos('B733',T)>0) Or (Pos('B734',T)>0) Or (Pos('B735',T)>0));
  2: Result := Pos('MADDOG',T)>0;
  3: Result := ((Pos('SKYSIM',T)>0) Or (Pos('SKYDC9',T)>0)) And (Pos('DC9',T)>0);
  4: Result := ((Pos('SKYSIM',T)>0) Or (Pos('SKYMD11',T)>0)) And (Pos('MD11',T)>0);
  5: Result := (Pos('TFDI',T)>0) And (Pos('MD11',T)>0);
  6: Result := (Pos('BELL407',T)>0) And (Pos('HPG',T)=0);
  7: Result := (Pos('EC135',T)>0) And (Pos('HPG',T)=0);
 End;
End;
Procedure InitializeFields;
Var I : Integer;
Begin
"""
for provider,title,start,count in defs:s+=f' For I:=0 To {count-1} Do AddonFields[{start}+I]:={provider}Fields[I];\n'
s+='End;\nInitialization\n InitializeFields;\nEnd.\n'
(a.root/'src/Aircraft/AddonLVarCatalogU.pas').write_text(s,encoding='utf-8-sig')
out=a.root/'support/addon-lvars/fields.json';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8')
print('Generated',len(fields),'fields;',len(known),'verified aircraft titles;',[(x[0],x[3]) for x in defs])

from apply_display_values import CATALOGS,update_catalog
for rel,kind in CATALOGS.items():
 if kind=='TAddonLVarField':update_catalog(a.root/rel)
