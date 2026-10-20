"""Validate the editable i18n package catalog, locale coverage and DFM bindings."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
path=root/'translations/MSFS2024-FDR.i18n'
catalog=ET.parse(path).getroot()
assert catalog.tag=='i18nCatalog' and catalog.get('Locale')=='pl-PL'
registry=(root/'src/i18n/LocalizationU.pas').read_text(encoding='utf-8-sig')
locale_block=re.search(r'UILanguageLocales\s*:[\s\S]*?=\s*\(([\s\S]*?)\);',registry).group(1)
locales=set(re.findall(r"'([^']+)'",locale_block))
components={}
for dfm in (root/'src').rglob('*.dfm'):
    if any(part in ('__history', '__recovery') for part in dfm.parts): continue
    text=dfm.read_text(encoding='utf-8-sig')
    match=re.match(r'object \w+: T(\w+)',text)
    if match: components[match[1]]=set(re.findall(r'object (\w+):',text))
placeholder=r'%(?:\d+:)?[-+0 #]*\d*(?:\.\d+)?[diuoxXfFeEgGnNmps]'
foreign_scripts={
 'he-IL':r'[\u0400-\u052f\u0600-\u06ff\u0900-\u097f\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]',
 'ar-SA':r'[\u0400-\u052f\u0590-\u05ff\u0900-\u097f\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]',
 'hi-IN':r'[\u0400-\u052f\u0590-\u06ff\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]',
 'vi-VN':r'[\u0400-\u052f\u0590-\u06ff\u0900-\u097f\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]',
 'id-ID':r'[\u0400-\u052f\u0590-\u06ff\u0900-\u097f\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]',
 'ja-JP':r'[\u0400-\u052f\u0590-\u06ff\u0900-\u097f\uac00-\ud7af]',
 'zh-CN':r'[\u0400-\u052f\u0590-\u06ff\u0900-\u097f\u3040-\u30ff\uac00-\ud7af]'}
count=0
for domain in catalog.findall('Domain'):
    name=domain.get('Name');seen=set()
    for entry in domain:
        key=(entry.tag,entry.get('ID'))
        assert key not in seen,('Duplicate definition',name,key)
        seen.add(key)
        values={e.get('Locale'):e.text or '' for e in entry.findall('Translation')}
        assert set(values)==locales,(name,key,'Locales',set(values))
        source=entry.findtext('Value') or ''
        for locale,value in values.items():
            assert value.strip(),(name,key,locale,'Empty translation')
            assert not re.search(r'\w\?\w',value),(name,key,locale,'Corrupted character')
            assert '\ufffd' not in value,(name,key,locale,'Invalid Unicode')
            script=foreign_scripts.get(locale)
            if script and not re.search(script,source):
                assert not re.search(script,value),(name,key,locale,'Unexpected script in translation')
            # Language menu names intentionally stay in their native script.
            if locale=='he-IL' and not re.search(r'[\u0600-\u06ff]',source):
                assert not re.search(r'[\u0600-\u06ff]',value),(name,key,locale,'Mixed Arabic in Hebrew')
            if locale=='ar-SA' and not re.search(r'[\u0590-\u05ff]',source):
                assert not re.search(r'[\u0590-\u05ff]',value),(name,key,locale,'Mixed Hebrew in Arabic')
            assert re.findall(placeholder,source)==re.findall(placeholder,value),(name,key,locale,'Format arguments')
        if entry.tag=='Property':
            assert name in components,('Unknown form',name)
            owner=entry.get('ID').split('.')[0]
            assert not owner or owner in components[name],('Stale component',name,entry.get('ID'))
        count+=1
assert count>500
parameter_domain=catalog.find("Domain[@Name='Parameters']")
assert parameter_domain is not None,'Missing parameter captions'
parameter_ids={node.findtext('Value') for node in parameter_domain.findall('Literal')}
telemetry=(root/'src/Telemetry/TelemetryCatalogU.pas').read_text(encoding='utf-8-sig')
for family in ('NumericColumns','BooleanColumns','EngineColumns'):
    part=telemetry[telemetry.index('  '+family):]
    part=part[:part.index('));')+3]
    required=set(re.findall(r"\(Name:\s*'([^']*)'",part))
    assert required.issubset(parameter_ids),('Missing readable parameter names',family,required-parameter_ids)
print(f'PASS: {count} catalog definitions in {len(locales)} locales; placeholders, Unicode and DFM bindings valid.')
