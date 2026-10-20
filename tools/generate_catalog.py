import pathlib,re
root=pathlib.Path(__file__).resolve().parents[1]
up=root.parent/'MSFS-Flight-Data-Recorder-master/MSFS-Flight-Data-Recorder/recording'
s=(up/'simconnect_defs.h').read_text()
body=s.split('#define FLIGHT_DATA_FIELDS(',1)[1].split('struct FLIGHT_DATA_RECORD',1)[0]
fields=[]; offset=0
def add(name,var,units='',length=8):
    global offset
    if var.startswith('GEAR POSITION:'): units='Percent Over 100'
    dtype={8:5,32:6,64:7,256:9}.get(length,4) if not units else 4
    fields.append((name,var,units,dtype,offset,length));offset+=length
for m in re.finditer(r'\b(NUM|ENGINES|COORD|STR|TIME)\(([^\n]+?)\)',body):
    kind=m[1]; args=[a.strip().strip('"') for a in m[2].split(',')]
    if kind=='NUM': add(*args)
    elif kind=='ENGINES':
        for i in range(16):add(f'{args[0]}[{i}]',f'{args[1]}:{i+1}',args[2])
    elif kind=='COORD':
        add(args[0]+'.latitude',args[1],'Degrees');add(args[0]+'.longitude',args[2],'Degrees')
    elif kind=='STR':add(args[0],args[1],length=int(args[2]))
    else:
        for suffix,var in [('year','YEAR'),('month','MONTH OF YEAR'),('day','DAY OF MONTH'),('weekday','DAY OF WEEK'),('seconds','TIME')]:add(args[0]+'.'+suffix,args[1]+' '+var,'Seconds' if suffix=='seconds' else 'Number')
        if args[2]!='nullptr':add(args[0]+'.offset',args[2],'Seconds')
idx={f[0]:i for i,f in enumerate(fields)}
t=(up/'trip_data_fields.h').read_text()
nums=re.findall(r'X\((\w+),\s*([\w.]+),\s*(INTEGER|REAL)\)',t.split('#define TRIP_DATA_NUM_FIELDS')[1].split('#define TRIP_DATA_BOOL_FIELDS')[0])
nums=[(n,m,'REAL' if n in ('gear_position_0','gear_position_1','gear_position_2') else typ) for n,m,typ in nums]
bools=re.findall(r'X\((\w+),\s*(\d+),\s*(\d+)\)',t.split('#define TRIP_DATA_BOOL_FIELDS')[1].split('#define TRIP_ENGINE_FIELDS')[0])
engines=re.findall(r'X\((\w+),\s*(INTEGER|REAL),\s*(true|false)\)',t.split('#define TRIP_ENGINE_FIELDS')[1].split('// Each TRIP_ENGINE_FIELDS')[0])
events=re.findall(r'X\(\w+,\s*"([^"]+)"\)',s.split('#define COCKPIT_EVENTS')[1].split('enum EVENT_ID')[0])
q=lambda x:"'"+x.replace("'","''")+"'"
lines=['unit TelemetryCatalogU;','interface',
 'type TSimField = record Name, SimVar, Units: string; DataType, Offset, Size: Integer; end;',
 'TNumericColumn = record Name, SQLType: string; FieldIndex: Integer; end;',
 'TBooleanColumn = record Name: string; FieldIndex, Group, Bit: Integer; end;',
 'TEngineColumn = record Name, SQLType: string; FieldIndex: Integer; end;',
 f'const FieldCount={len(fields)}; PayloadSize={offset};',
 f'SimFields: array[0..{len(fields)-1}] of TSimField = (']
lines += [f' (Name:{q(n)}; SimVar:{q(v)}; Units:{q(u)}; DataType:{dt}; Offset:{off}; Size:{size})'+(',' if i<len(fields)-1 else ');') for i,(n,v,u,dt,off,size) in enumerate(fields)]
lines += [f'NumericColumns: array[0..{len(nums)-1}] of TNumericColumn = (']
lines += [f' (Name:{q(n)}; SQLType:{q(typ)}; FieldIndex:{idx[member]})'+(',' if i<len(nums)-1 else ');') for i,(n,member,typ) in enumerate(nums)]
lines += [f'BooleanColumns: array[0..{len(bools)-1}] of TBooleanColumn = (']
lines += [f' (Name:{q(n)}; FieldIndex:{idx[n]}; Group:{g}; Bit:{b})'+(',' if i<len(bools)-1 else ');') for i,(n,g,b) in enumerate(bools)]
lines += [f'EngineColumns: array[0..{len(engines)-1}] of TEngineColumn = (']
lines += [f' (Name:{q(n)}; SQLType:{q(typ)}; FieldIndex:{idx[n+"[0]"]})'+(',' if i<len(engines)-1 else ');') for i,(n,typ,b) in enumerate(engines)]
lines += [f'CockpitEvents: array[0..{len(events)-1}] of string = ('+','.join(map(q,events))+');','implementation','end.']
(root/'src').mkdir(parents=True,exist_ok=True)
(root/'src/telemetry/TelemetryCatalogU.pas').write_text('\n'.join(lines)+'\n')
print(len(fields),'SimConnect fields;',len(nums),'numeric columns;',len(bools),'booleans;',len(engines),'engine columns;',len(events),'events')
