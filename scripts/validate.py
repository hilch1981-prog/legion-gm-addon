"""Validate source integrity, Lua 5.1 and mocked APIs; no game client is run."""
from pathlib import Path
import hashlib
import json
import re
import time
import xml.etree.ElementTree as ET

from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / 'GMminibar'


def validate_files():
    release = json.loads((ROOT / 'release.json').read_text(encoding='utf-8'))
    manifest = json.loads((ROOT / 'addon-manifest.json').read_text(encoding='utf-8'))
    actual = {p.relative_to(ROOT).as_posix() for p in ADDON.rglob('*') if p.is_file()}
    assert actual == set(manifest), 'Addon manifest has missing or extra files'
    assert len(actual) == release['addonFiles']
    for name, expected in manifest.items():
        path = ROOT / name
        assert path.resolve().is_relative_to(ADDON.resolve()), name
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, name
        assert path.suffix.lower() not in {'.exe', '.dll', '.mpq', '.sql', '.zip', '.7z', '.dbc', '.db2'}, name

    toc_text = (ADDON / 'GMminibar.toc').read_text(encoding='utf-8')
    assert f'## Interface: {release["interface"]}' in toc_text
    assert f'## Version: {release["version"]}' in toc_text
    toc = [line.strip().replace('\\', '/') for line in toc_text.splitlines()
           if line.strip() and not line.lstrip().startswith('#')]
    available = {p.relative_to(ADDON).as_posix() for p in ADDON.rglob('*') if p.is_file()}
    for name in toc:
        assert name in available, f'Missing or case-mismatched TOC entry: {name}'
        if name.endswith('.xml'):
            ET.parse(ADDON / name)

    screenshots = json.loads((ROOT / 'docs/screenshots.json').read_text(encoding='utf-8'))
    for name, expected in screenshots.items():
        assert hashlib.sha256((ROOT / 'docs/images' / name).read_bytes()).hexdigest() == expected, name
    for doc in ROOT.rglob('*.md'):
        if 'GMminibar' in doc.relative_to(ROOT).parts or 'dist' in doc.relative_to(ROOT).parts:
            continue
        for target in re.findall(r'!?\[[^\]]*\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
            if '://' in target or target.startswith('#'):
                continue
            local = target.split('#', 1)[0]
            assert (doc.parent / local).is_file(), f'Broken local link in {doc.name}: {target}'
    return toc


def main():
    start = time.perf_counter()
    toc = validate_files()
    compiler = LuaRuntime(unpack_returned_tuples=True)
    compile_lua = compiler.eval('function(s,n) local f,e=loadstring(s,n); return f~=nil,e end')
    files = sorted(ADDON.rglob('*.lua'))
    for path in files:
        ok, error = compile_lua(path.read_text(encoding='utf-8'), path.relative_to(ROOT).as_posix())
        assert ok, error
    counts = {}
    for locale in ('koKR', 'enUS'):
        lua = LuaRuntime(unpack_returned_tuples=True)
        for name in ('wow_mock.lua', 'legion_mock.lua'):
            lua.execute((ROOT / 'tests' / name).read_text(encoding='utf-8'))
        lua.globals().MOCK.locale = locale
        fixtures = json.loads((ROOT / 'tests/fixtures/quest_server_strings_koKR.json').read_text(encoding='utf-8'))
        lua.globals().MOCK.questServerStrings = lua.table_from(fixtures['strings'])
        for name in toc:
            if name.endswith('.lua'):
                lua.execute((ADDON / name).read_text(encoding='utf-8'))
        for name in ('contracts.lua', 'bag_contracts.lua', 'settings_contracts.lua',
                     'quest_contracts.lua', 'objective_contracts.lua', 'utility_contracts.lua',
                     'quest_locale_contracts.lua'):
            lua.execute((ROOT / 'tests' / name).read_text(encoding='utf-8'))
        counts[locale] = int(lua.globals().MOCK.passed)
        print(f'{locale}: {counts[locale]} mocked API contracts passed')
    report = {'syntaxFiles': len(files), 'contracts': counts,
              'elapsedSeconds': round(time.perf_counter() - start, 2), 'inGameVerified': False}
    (ROOT / 'dist').mkdir(exist_ok=True)
    (ROOT / 'dist/validation.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
