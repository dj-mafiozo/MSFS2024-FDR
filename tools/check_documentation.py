"""Check four-language navigation for project-owned README and test documentation."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
excluded={'.git','.build','vendor','node_modules','__history','__recovery'}
bases=[p for p in root.rglob('README.md') if not excluded.intersection(p.relative_to(root).parts)]
bases += [p for p in root.glob('*.md') if p.stem.lower() in {'testy','tests'}]
assert bases,'No documentation found'
count=0
for base in bases:
    versions=[base.with_name(base.stem+suffix+'.md') for suffix in ['','.en','.de','.es']]
    for path in versions:
        assert path.is_file(),f'Missing translation: {path.relative_to(root)}'
        text=path.read_text(encoding='utf-8-sig')
        assert len(text.strip())>200,f'Incomplete documentation: {path}'
        assert '\ufffd' not in text,f'Invalid Unicode: {path}'
        for sibling in versions:
            assert f']({sibling.name})' in text,f'Missing language link: {path} -> {sibling.name}'
        for target in re.findall(r'\]\(([^)]+)\)',text):
            if re.match(r'^(?:https?:|mailto:|#)',target):continue
            target=target.split('#')[0]
            if not target:continue
            # Documentation may name optional local sources; check the actual language navigation unconditionally.
            if Path(target).name in {v.name for v in versions}:
                assert (path.parent/target).is_file(),f'Broken language link: {path}: {target}'
        count+=1
print(f'PASS: {len(bases)} project documentation sets, {count} PL/EN/DE/ES files with valid language navigation.')
