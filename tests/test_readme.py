#!/usr/bin/env python3
"""The README badges must match the build: version, voicing and progression counts."""
import json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
md = open(os.path.join(ROOT, 'README.md')).read()
base = re.search(r"^VERSION_BASE = '([^']+)'", open(os.path.join(ROOT, 'src', 'build.py')).read(), re.M).group(1)
lua = open(os.path.join(ROOT, 'reaper', 'GuitarChordPack.lua')).read()
stamped = re.search(r'^local VERSION = "([^"]+)"', lua, re.M).group(1)
voicings = sum(len(v) for v in json.load(open(os.path.join(ROOT, 'src', 'chorddata.json'))).values())
progs = len(json.load(open(os.path.join(ROOT, 'src', 'progressions.json')))['progressions'])


def badge(label):
    return re.search(rf'badge/{label}-([^-]+)-', md).group(1)


assert stamped.split('+')[0] == base, f'script stamped {stamped}, VERSION_BASE is {base}: run make'
for label, want in (('version', base), ('voicings', str(voicings)), ('progressions', str(progs))):
    assert badge(label) == want, f'README {label} badge says {badge(label)}, build says {want}: run make'
print(f'readme badges     ok (v{base}, {voicings} voicings, {progs} progressions)')
