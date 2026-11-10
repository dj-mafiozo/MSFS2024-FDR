"""Inventory Fenix model L-var candidates, including modular attachment variants.

Only names, contexts and hashes are emitted. Proprietary XML is not copied.
Template parameters are candidates, not proof of live variable availability.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

NAME = re.compile(r'[A-Za-z_][A-Za-z_0-9]*')

def inventory(xml, package_root=None, previous=None, cockpit_only=False):
    xml = Path(xml).resolve()
    if xml.is_dir():
        package_root = xml
        matches = sorted(xml.glob('SimObjects/Airplanes/*/attachments/*/Part_Interior_Cockpit/model/Cockpit_Behavior.xml'))
        if len(matches) != 1:
            raise ValueError('Expected exactly one common cockpit behavior; pass its XML path explicitly')
        xml = matches[0]
    if package_root is None and not cockpit_only:
        package_root = next((p for p in xml.parents if (p/'manifest.json').is_file() and (p/'SimObjects').is_dir()), None)
    package_root = Path(package_root).resolve() if package_root else None
    roots = [package_root] if package_root else []
    if package_root and not cockpit_only and package_root.name == 'fnx-aircraft-a32x-common':
        version = json.loads((package_root/'manifest.json').read_text(encoding='utf-8-sig')).get('package_version')
        for sibling in sorted(package_root.parent.glob('fnx-aircraft-*')):
            manifest = sibling/'manifest.json'
            if sibling == package_root or 'liveries' in sibling.name or not manifest.is_file():
                continue
            if json.loads(manifest.read_text(encoding='utf-8-sig')).get('package_version') == version:
                roots.append(sibling)
    files = [(xml, package_root)]
    if package_root and not cockpit_only:
        files += [(p, base) for base in roots for p in sorted((base/'SimObjects/Airplanes').rglob('*.xml')) if p.resolve() != xml]
    variables, sources, references = {}, [], 0
    for path, owner in files:
        raw = path.read_bytes()
        root = ET.fromstring(raw)
        relative = path.relative_to(owner).as_posix() if owner else path.name
        if len(roots) > 1: relative = owner.name+'/'+relative
        names, count = set(), 0
        for template in root.iter('UseTemplate'):
            for child in template:
                if not child.tag.startswith('VAR_NAME'):
                    continue
                name = (child.text or '').strip()
                if not NAME.fullmatch(name):
                    continue
                count += 1
                names.add(name)
                context = {'template': template.get('Name', ''), 'parameter': child.tag, 'source_file': relative}
                animation = template.findtext('ANIM_NAME')
                if animation:
                    context['animation'] = animation
                contexts = variables.setdefault(name, [])
                if context not in contexts:
                    contexts.append(context)
        references += count
        sources.append({'path': relative, 'sha256': hashlib.sha256(raw).hexdigest(), 'reference_count': count, 'variable_count': len(names)})
    manifest = json.loads((package_root/'manifest.json').read_text(encoding='utf-8-sig')) if package_root else {}
    previous = previous or {}
    retired = dict(previous.get('retired_variables', {}))
    retired.update({n: c for n, c in previous.get('variables', {}).items() if n not in variables})
    retired = {n: c for n, c in retired.items() if n not in variables}
    old = set(previous.get('variables', {}))
    current = set(variables)
    return {
        'source_file': xml.name,
        'sha256': hashlib.sha256(xml.read_bytes()).hexdigest(),
        'catalog_sha256': hashlib.sha256(json.dumps(sources, sort_keys=True, separators=(',', ':')).encode()).hexdigest(),
        'package_version': manifest.get('package_version', ''),
        'scope': 'cockpit-only' if len(files) == 1 else 'matching-version common and aircraft package models/attachment variants',
        'source_packages': [{'name': p.name, 'version': json.loads((p/'manifest.json').read_text(encoding='utf-8-sig')).get('package_version','')} for p in roots],
        'meaning': 'L-var candidates from literal VAR_NAME* template parameters. Units and active modes need template/live validation. Variant-specific names may be absent; transported zero is not proof of existence. Not an official Fenix SDK. Retired names are for historical decoding only and are not subscribed.',
        'source_files': sources,
        'reference_count': references,
        'variable_count': len(variables),
        'variables': variables,
        'retired_variables': retired,
        'changes': {'previous_sha256': previous.get('sha256', ''), 'previous_variable_count': len(old), 'added': sorted(current-old), 'removed_from_current': sorted(old-current)},
    }

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('xml', type=Path)
    p.add_argument('output', type=Path)
    p.add_argument('--package-root', type=Path)
    p.add_argument('--previous', type=Path)
    p.add_argument('--cockpit-only', action='store_true')
    a = p.parse_args()
    baseline = a.previous or (a.output if a.output.is_file() else None)
    previous = json.loads(baseline.read_text(encoding='utf-8-sig')) if baseline else None
    result = inventory(a.xml, a.package_root, previous, a.cockpit_only)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(result, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    print(f'Extracted {result["variable_count"]} current candidates, {len(result["retired_variables"])} historical-only names, {len(result["source_files"])} XML files.')

if __name__ == '__main__':
    main()
