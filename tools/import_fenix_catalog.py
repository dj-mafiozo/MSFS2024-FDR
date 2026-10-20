"""Extract Fenix cockpit variable candidates; never infer units or active modes."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('xml', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
raw = args.xml.read_bytes()
root = ET.fromstring(raw)
variables = {}
references = 0
for template in root.iter('UseTemplate'):
    for child in template:
        if not child.tag.startswith('VAR_NAME'):
            continue
        name = (child.text or '').strip()
        if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', name):
            continue
        references += 1
        context = {'template': template.get('Name', ''), 'parameter': child.tag}
        animation = template.findtext('ANIM_NAME')
        if animation:
            context['animation'] = animation
        contexts = variables.setdefault(name, [])
        if context not in contexts:
            contexts.append(context)
result = {
    'source_file': args.xml.name,
    'sha256': hashlib.sha256(raw).hexdigest(),
    'meaning': 'Variable candidates from cockpit template parameters. Templates must confirm each L-var reference. Switches, encoders, animations and indicator values are not interchangeable. Units, availability and active modes require validation in the simulator. Not an official Fenix SDK.',
    'reference_count': references,
    'variable_count': len(variables),
    'variables': variables,
}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(result, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
print(f'Extracted {len(variables)} unique candidates from {references} references.')
