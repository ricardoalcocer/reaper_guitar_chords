#!/usr/bin/env python3
"""Rebuild src/chorddata.json from the validated chord table.

gen_chords.py validates all 192 voicings (no foreign notes, no missing chord
tones beyond an omitted 5th, no negative frets, no stretch over 4 frets) and
writes build/pack/chord-index.csv. This turns that into the JSON both targets
embed. If validation fails, gen_chords.py prints the offenders and this file
should not be regenerated until they are fixed.
"""
import csv, json, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

subprocess.run([sys.executable, 'src/gen_chords.py'], check=True)

rows = list(csv.reader(open('build/pack/chord-index.csv')))[1:]
data = {}
for label, root, quality, dia, shape, notes in rows:
    frets = [None if c == 'x' else int(c, 16) for c in dia]
    data.setdefault(root, {})[quality] = {
        'label': label, 'frets': frets, 'dia': dia, 'shape': shape, 'notes': notes,
    }
json.dump(data, open('src/chorddata.json', 'w'), separators=(',', ':'))
print(f'{len(rows)} voicings -> src/chorddata.json')
