"""Generate the four-language manual, hierarchical CHM contents and context map."""
from pathlib import Path
import json,html,re
ROOT=Path(__file__).resolve().parents[1]
HELP=ROOT/'help'
# Existing public context IDs are stable.
CONTEXTS={100:'overview',200:'map',300:'charts',400:'analysis',500:'settings',600:'about',
310:'chart-options',510:'settings-general',520:'settings-units',530:'settings-analysis',540:'settings-ai',541:'settings-ai',542:'settings-ai',543:'settings-ai',550:'settings-instruments',560:'ghost',610:'release',700:'instruments',710:'b38m-pfd',711:'b38m-eicas',720:'engines',730:'a320-pfd',731:'ecam-recorded',800:'fmc',900:'simbrief',1000:'flight-plan',1100:'atc',1200:'gsx',1300:'weather',1400:'recordings',1410:'recordings',1420:'recordings',1500:'ghost',1600:'workspace',1700:'values',1710:'events',1720:'contacts',1800:'playback',1900:'recording'}
CONTEXTS.update({733:'a320-ewd',739:'ecam-recorded',740:'ecam-engine',741:'ecam-bleed',742:'ecam-press',743:'ecam-elec',744:'ecam-hyd',745:'ecam-fuel',746:'ecam-apu',747:'ecam-cond',748:'ecam-door',749:'ecam-wheel',750:'ecam-fctl',751:'ecam-sts',752:'ecam-cruise'})
ECAM=['engine','bleed','press','elec','hyd','fuel','apu','cond','door','wheel','fctl','sts','cruise']
TREE=[('overview',[]),('recordings',['recording']),('workspace',['playback','ghost','map','flight-plan',('charts',['chart-options','simvars']),('data',['values','events','contacts'])]),('instruments',['sixpack','ga-glass','airliner-classic','generic-pfd',('engines',['engine-piston','engine-turboprop','engine-jet']),('boeing',['b38m-pfd','b38m-eicas']),('airbus',['a320-pfd','a320-ewd',('ecam-recorded',['ecam-'+p for p in ECAM])]),('fmc',['fmc-b737','fmc-a320','fmc-b777'])]),('simbrief',['atc','gsx','weather']),('analysis',[]),('settings',['settings-general','settings-units','settings-analysis','settings-ai','settings-instruments']),('about',['release','troubleshooting'])]
IMAGES={key:['{lang}-'+image] for key,image in {'overview':'workspace','workspace':'workspace','map':'map-view','charts':'charts-view','chart-options':'charts','settings-general':'settings-generalpage','settings-units':'settings-unitspage','settings-analysis':'settings-analysispage','settings-instruments':'settings-debugpage','ghost':'settings-ghostpage','gsx':'gsx','flight-plan':'plan','values':'values','events':'events','contacts':'contacts','atc':'atc','weather':'weather','analysis':'analysis-report','b38m-eicas':'b38m-eicas','a320-pfd':'a320-pfd','a320-ewd':'a320-ewd','ecam-recorded':'ecam-recorded'}.items()}
IMAGES.update({key:['{lang}-'+key] for key in ['sixpack','ga-glass','airliner-classic','generic-pfd','engine-piston','engine-turboprop','engine-jet']+['ecam-'+p for p in ECAM]})
IMAGES['ecam-recorded']=['{lang}-ecam-controls','{lang}-ecam-recorded']
IMAGES.update({'settings-ai':['{lang}-settings-ai-'+str(i) for i in range(3)],'b38m-pfd':['{lang}-b38m-cpt','{lang}-b38m-fo'],'simbrief':['{lang}-simbrief','{lang}-simbrief-ofp']})
IMAGES.update({key:['{lang}-'+key,'{lang}-'+key+'-right'] for key in ['fmc-b737','fmc-a320','fmc-b777']})
IMAGES['analysis']=['{lang}-analysis-report','{lang}-analysis-report-details']
LANGS={'pl':('0x415 Polish','Spis treści','Ilustracja interfejsu z danymi demonstracyjnymi. To nie jest zapis rzeczywistego lotu.','Opcja / czynność','Działanie i ograniczenia'), 'en':('0x409 English (United States)','Contents','Interface illustration with synthetic demonstration data; not a real flight recording.','Option / action','Behavior and limitations'), 'de':('0x407 German (Germany)','Inhalt','Oberflächenbeispiel mit synthetischen Demonstrationsdaten, keine echte Flugaufzeichnung.','Option / Aktion','Verhalten und Einschränkungen'), 'es':('0x40a Spanish (Traditional Sort)','Contenido','Ejemplo de interfaz con datos sintéticos de demostración; no es un vuelo real.','Opción / acción','Funcionamiento y limitaciones')}
CODEPAGES={'pl':'cp1250','en':'cp1252','de':'cp1252','es':'cp1252'}
CSS='body{font:15px Segoe UI,Arial,sans-serif;line-height:1.55;margin:24px;max-width:1100px;color:#172c42;background:white}h1{font-size:26px}h2{font-size:20px;margin-top:28px}table{border-collapse:collapse;width:100%}td,th{border:1px solid #c5ced8;padding:9px;text-align:left;vertical-align:top}th{background:#eaf0f5}td:first-child{width:26%;font-weight:bold}.screenshot{display:block;clear:both;margin:24px 0 30px 0;page-break-inside:avoid}.screenshot img{display:block;clear:both;max-width:100%;height:auto;border:1px solid #b4c0cc}.image-caption{display:block;clear:both;margin-top:8px;font-size:12px;line-height:1.5;color:#526273}code{font-family:Consolas,monospace}a{color:#075da0}'
def generate():
 data={}
 for lang in LANGS:
  text=(HELP/('manual.'+lang+'.txt')).read_text(encoding='utf-8-sig')
  for block in text.split('@')[1:]:
   lines=block.strip().splitlines();key,title=lines[0].split('|',1)
   item={'title':title,'intro':[],'options':[]}
   for line in lines[1:]:
    if ' :: ' in line:item['options'].append(line.split(' :: ',1))
    elif line.strip():item['intro'].append(line)
   data.setdefault(key,{})[lang]=item
 assert all(set(value)==set(LANGS) for value in data.values()),'Missing translated manual chapter'

 def flatten(items):
  for item in items:
   if isinstance(item,str):yield item
   else:
    yield item[0]
    yield from flatten(item[1])
 keys=set(flatten(TREE))
 assert keys==set(data),'Manual topics do not match navigation'
 for lang,(locale,contents,caption,col1,col2) in LANGS.items():
  folder=HELP/lang;folder.mkdir(exist_ok=True)
  encoding=CODEPAGES[lang];charset='windows-'+encoding[2:]
  files=[]
  for key,entry in data.items():
   item=entry[lang];title=item['title'];body=['<h1>'+html.escape(title)+'</h1>']
   for paragraph in item.get('intro',[]):body.append('<p>'+html.escape(paragraph)+'</p>')
   rows=item.get('options',[])
   if rows:
    body.append('<table><tr><th>'+col1+'</th><th>'+col2+'</th></tr>')
    for label,text in rows:body.append('<tr><td>'+html.escape(label)+'</td><td>'+html.escape(text)+'</td></tr>')
    body.append('</table>')
   if key=='simvars':
    catalog=json.loads((HELP/('simvars.'+lang+'.json')).read_text(encoding='utf-8-sig'))
    body.append('<p>'+str(len(catalog))+' SimVars</p><table><tr><th>ID</th><th>'+col1+'</th><th>Unit</th></tr>')
    for entry in catalog:
     body.append('<tr><td><code>'+html.escape(str(entry.get('name',entry.get('Name',''))))+'</code></td><td>'+html.escape(str(entry.get('caption',entry.get('Caption',''))))+'</td><td>'+html.escape(str(entry.get('unit',entry.get('Unit',''))))+'</td></tr>')
    body.append('</table>')
   for source in IMAGES.get(key,[]):
    name=source.format(lang=lang)+'.png'
    if not (HELP/'images'/name).exists():raise RuntimeError('Missing documentation screenshot: '+name)
    body.append('<div class="screenshot"><img src="images/'+name+'" alt="'+html.escape(title,quote=True)+'"><div class="image-caption">'+caption+'</div></div>')
   for paragraph in item.get('notes',[]):body.append('<p>'+html.escape(paragraph)+'</p>')
   text='<!DOCTYPE html><html lang="'+lang+'"><head><meta http-equiv="Content-Type" content="text/html; charset='+charset+'"><title>'+html.escape(title)+' — MSFS24-FDR</title><style>'+CSS+'</style></head><body>'+''.join(body)+'</body></html>'
   (folder/(key+'.htm')).write_text(text,encoding=encoding,errors='xmlcharrefreplace');files.append(key+'.htm')
  def node(key,children):
   title=html.escape(data[key][lang]['title'],quote=True)
   return '<li><object type="text/sitemap"><param name="Name" value="'+title+'"><param name="Local" value="'+key+'.htm"></object>'+('<ul>'+''.join(node(c,[]) if isinstance(c,str) else node(*c) for c in children)+'</ul>' if children else '')+'</li>'
  (folder/'contents.hhc').write_text('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><html><head><meta http-equiv="Content-Type" content="text/html; charset='+charset+'"></head><body><ul>'+''.join(node(k,c) for k,c in TREE)+'</ul></body></html>',encoding=encoding)
  local_images=folder/'images';local_images.mkdir(exist_ok=True)
  import shutil
  for path in (HELP/'images').glob(lang+'-*.png'):shutil.copy2(path,local_images/path.name)
  headers=[];aliases=[]
  legacy={100:'OVERVIEW',200:'MAP',300:'CHARTS',400:'ANALYSIS',500:'SETTINGS',600:'ABOUT'}
  for number,key in CONTEXTS.items():
   symbol='IDH_'+legacy.get(number,'TOPIC_'+str(number));headers.append('#define '+symbol+' '+str(number));aliases.append(symbol+'='+key+'.htm')
  (folder/'contexts.h').write_text('\n'.join(headers)+'\n',encoding='ascii')
  pictures=sorted({v.format(lang=lang)+'.png' for values in IMAGES.values() for v in values})
  project='[OPTIONS]\nCompatibility=1.1 or later\nBinary TOC=Yes\nCompiled file=MSFS2024-FDR.'+lang+'.chm\nContents file=contents.hhc\nDefault topic=overview.htm\nDisplay compile progress=No\nFull-text search=Yes\nLanguage='+locale+'\nTitle=MSFS24-FDR\n[FILES]\n'+'\n'.join(files+['images/'+n for n in pictures])+'\n[ALIAS]\n'+'\n'.join(aliases)+'\n[MAP]\n#include contexts.h\n'
  (folder/'help.hhp').write_text(project,encoding=encoding)
 # Reject orphan DFM contexts before CHM compilation.
 for dfm in (ROOT/'src').rglob('*.dfm'):
  if any(x in dfm.parts for x in ['__history','__recovery']):continue
  for context in re.findall(r'\bHelpContext\s*=\s*(\d+)',dfm.read_text(encoding='utf-8-sig')):
   assert int(context) in CONTEXTS,(dfm,context)
 print('PASS:',len(data),'topics in four languages, hierarchical contents,',len(CONTEXTS),'context aliases and DFM coverage.')
if __name__=='__main__':generate()
