"""Build an install-only ZIP from the tracked addon tree (stdlib only)."""
from pathlib import Path
import zipfile
root = Path(__file__).resolve().parents[1]
addon = root / 'ForeverRusse'
out = root / 'dist' / 'ForeverRusse-0.1.0-addon.zip'
out.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for file in sorted(addon.rglob('*')):
        if file.is_file() and (file.suffix in {'.lua', '.toc', '.xml', '.ttf', '.ogg'}
                               or file.relative_to(addon).as_posix() == 'Media/DejaVuSans-LICENSE.txt'):
            z.write(file, file.relative_to(root))
print(out)
