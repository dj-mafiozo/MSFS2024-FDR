"""Append replay visual SimVars without moving any existing field offset."""
from pathlib import Path
import re
EXTRA=[('trailing_edge_flaps_left_percent','TRAILING EDGE FLAPS LEFT PERCENT','Percent Over 100'),('trailing_edge_flaps_right_percent','TRAILING EDGE FLAPS RIGHT PERCENT','Percent Over 100'),('leading_edge_flaps_left_percent','LEADING EDGE FLAPS LEFT PERCENT','Percent Over 100'),('leading_edge_flaps_right_percent','LEADING EDGE FLAPS RIGHT PERCENT','Percent Over 100'),('flaps_handle_percent','FLAPS HANDLE PERCENT','Percent Over 100')]+[(f'gear_animation_position_{i}',f'GEAR ANIMATION POSITION:{i}','Percent Over 100') for i in range(3)]+[('visual_velocity_body_z','VELOCITY BODY Z','Feet per second'),('visual_rotation_velocity_body_y','ROTATION VELOCITY BODY Y','Radians per second')]
FAMILIES=[('eng_rpm_animation_percent','ENG RPM ANIMATION PERCENT','Percent'),('turb_eng_jet_thrust','TURB ENG JET THRUST','Pounds'),('turb_eng_reverse_nozzle_percent','TURB ENG REVERSE NOZZLE PERCENT','Percent')]
def append(path):
 text=path.read_text(encoding='utf-8-sig');count=int(re.search(r'FieldCount\s*=\s*(\d+)',text)[1]);offset=int(re.search(r'PayloadSize\s*=\s*(\d+)',text)[1])
 fields=[];numeric=[];engines=[]
 def add_array(text,name,rows):
  if not rows:return text
  pat=r'('+name+r'\s*:\s*Array\s*\[0\s*\.\.\s*)(\d+)(\]\s*Of\s*\w+\s*=\s*\()(.*?)(\);)'
  text,n=re.subn(pat,lambda m:m[1]+str(int(m[2])+len(rows))+m[3]+m[4].rstrip()+',\n'+',\n'.join(rows)+m[5],text,count=1,flags=re.S|re.I);assert n,name
  return text
 def add(name,var,units):
  nonlocal count,offset
  fields.append(f"   (Name: '{name}'; SimVar: '{var}'; Units: '{units}'; DataType: 4; Offset: {offset}; Size: 8; DisplayValue: '')");count+=1;offset+=8
 for name,var,units in EXTRA:
  if re.search(r"Name\s*:\s*'"+re.escape(name)+r"'",text):continue
  numeric.append(f"   (Name: '{name}'; SQLType: 'REAL'; FieldIndex: {count})");add(name,var,units)
 for name,var,units in FAMILIES:
  if re.search(r"Name\s*:\s*'"+re.escape(name)+r"\[15\]'",text):continue
  engines.append(f"   (Name: '{name}'; SQLType: 'REAL'; FieldIndex: {count})")
  for i in range(16):add(f'{name}[{i}]',f'{var}:{i+1}',units)
 text=add_array(text,'SimFields',fields);text=add_array(text,'NumericColumns',numeric);text=add_array(text,'EngineColumns',engines)
 text=re.sub(r'(FieldCount\s*=\s*)\d+',lambda m:m[1]+str(count),text,count=1);text=re.sub(r'(PayloadSize\s*=\s*)\d+',lambda m:m[1]+str(offset),text,count=1)
 path.write_text(text,encoding='utf-8-sig')
if __name__=='__main__':append(Path(__file__).resolve().parents[1]/'src/Telemetry/TelemetryCatalogU.pas')
