#!/usr/bin/env python3
"""The download zip must hold exactly the files just built, under one versioned folder."""
import os, sys, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'src'))
import dist

path, version = dist.build_zip()
z = zipfile.ZipFile(path)
names = sorted(z.namelist())
folder = 'GuitarSongwriter-' + version.split('+')[0] + '/'
expected = sorted(folder + n for n in
                  ['README.txt', 'GuitarChordPack.lua', 'guitar-audition.html', 'LICENSE'])
assert names == expected, f'zip contents {names} != {expected}'

for src, name in dist.FILES:
    assert z.read(folder + name) == open(os.path.join(ROOT, src), 'rb').read(), \
        f'{name} in zip differs from {src}'

readme = z.read(folder + 'README.txt').decode()
assert '{VERSION}' not in readme, 'README.txt version placeholder not filled'
assert version in readme, 'README.txt does not name the built version'
assert '\r\n' in readme, 'README.txt should use CRLF for Windows Notepad'

print(f'dist zip          ok ({len(names)} files, {version})')
