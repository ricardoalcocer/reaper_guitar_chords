#!/usr/bin/env python3
"""Packages the built deliverables into one zip for people who just want to download.

  reaper/GuitarChordPack.lua + web/guitar-audition.html + LICENSE + src/dist_readme.txt
    -> build/dist/GuitarSongwriter.zip

The zip name carries no version on purpose: GitHub serves the latest release's asset
at a fixed URL (.../releases/latest/download/GuitarSongwriter.zip) only if the name
never changes. The version lives in the folder inside the zip and in README.txt.
Run after `make`, so the zip always holds the script that was just built.
"""
import os, re, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'build', 'dist', 'GuitarSongwriter.zip')
FILES = [('reaper/GuitarChordPack.lua', 'GuitarChordPack.lua'),
         ('web/guitar-audition.html', 'guitar-audition.html'),
         ('LICENSE', 'LICENSE')]


def built_version():
    """The version stamped into the built script, so the zip can't disagree with it."""
    lua = open(os.path.join(ROOT, 'reaper', 'GuitarChordPack.lua')).read()
    return re.search(r'^local VERSION = "([^"]+)"', lua, re.M).group(1)


def readme(version):
    text = open(os.path.join(ROOT, 'src', 'dist_readme.txt')).read()
    # CRLF so Notepad on Windows shows line breaks
    return text.replace('{VERSION}', version).replace('\n', '\r\n')


def build_zip():
    version = built_version()
    folder = 'GuitarSongwriter-' + version.split('+')[0] + '/'
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with zipfile.ZipFile(OUT, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr(folder + 'README.txt', readme(version))
        for src, name in FILES:
            z.write(os.path.join(ROOT, src), folder + name)
    return OUT, version


if __name__ == '__main__':
    path, version = build_zip()
    print(f'{os.path.relpath(path, ROOT):34} {os.path.getsize(path)/1024:6.1f} KB  ({version})')
