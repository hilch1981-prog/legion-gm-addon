"""Package only the byte-verified addon folder. Does not upload or change source."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    release = json.loads((ROOT / 'release.json').read_text(encoding='utf-8'))
    manifest = json.loads((ROOT / 'addon-manifest.json').read_text(encoding='utf-8'))
    files = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'GMminibar').rglob('*') if p.is_file()}
    assert files == set(manifest), 'Addon file set differs from manifest'
    payload = {}
    for name, expected in manifest.items():
        path = ROOT / name
        assert path.resolve().is_relative_to((ROOT / 'GMminibar').resolve()), name
        data = path.read_bytes()
        assert hashlib.sha256(data).hexdigest() == expected, name
        payload[name] = data
    (ROOT / 'dist').mkdir(exist_ok=True)
    output = ROOT / 'dist' / release['asset']
    with zipfile.ZipFile(output, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, data in sorted(payload.items()):
            info = zipfile.ZipInfo(name, date_time=(2026, 10, 10, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            archive.writestr(info, data, compresslevel=9)
    with zipfile.ZipFile(output) as archive:
        assert set(archive.namelist()) == set(manifest)
        assert all(n.startswith('GMminibar/') for n in archive.namelist())
        assert archive.testzip() is None
        for name, expected in manifest.items():
            assert hashlib.sha256(archive.read(name)).hexdigest() == expected, name
    print(json.dumps({'asset': output.name, 'files': len(manifest), 'singleAddonFolder': True,
                      'sha256': hashlib.sha256(output.read_bytes()).hexdigest()}))
    print('ZIP contents match the explicit source manifest. Gameplay evidence is recorded separately in GMminibar/GAME_TEST.md.')


if __name__ == '__main__':
    main()
