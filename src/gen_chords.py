import os
os.makedirs("build",exist_ok=True)
os.makedirs("packs",exist_ok=True)

from mido import MidiFile, MidiTrack, Message, MetaMessage, bpm2tempo
import os, csv, zipfile, shutil

TPQ, BAR, STRUM, PROGRAM = 480, 1920, 14, 25
OPEN = [40, 45, 50, 55, 59, 64]          # E2 A2 D3 G3 B3 E4
NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']

ROOTS = ['A','Bb','B','C','Db','D','Eb','E','F','Gb','G','Ab']
ROOT_PC = {n: i for i, n in enumerate(NAMES)}

# quality -> intervals from root (semitones)
QUALITIES = [
    ("maj",   [0,4,7]),
    ("m",     [0,3,7]),
    ("7",     [0,4,7,10]),
    ("m7",    [0,3,7,10]),
    ("maj7",  [0,4,7,11]),
    ("m7b5",  [0,3,6,10]),
    ("dim7",  [0,3,6,9]),
    ("dim",   [0,3,6]),
    ("aug",   [0,4,8]),
    ("sus2",  [0,2,7]),
    ("sus4",  [0,5,7]),
    ("7sus4", [0,5,7,10]),
    ("6",     [0,4,7,9]),
    ("m6",    [0,3,7,9]),
    ("9",     [0,2,4,7,10]),
    ("add9",  [0,2,4,7]),
    # --- extended voicings, added for the progression library ---
    # A guitarist can't fret every tone of an extended chord, so more than the
    # 5th gets dropped here: the OPTIONAL map below records exactly which tones a
    # given quality is allowed to omit. Intervals list ALL chord tones; the shape
    # picks a playable subset that keeps the essential ones.
    ("maj9",  [0,4,7,11,14]),          # R 3 5 7 9
    ("m9",    [0,3,7,10,14]),          # R b3 5 b7 9
    ("m11",   [0,3,7,10,14,17]),       # R b3 5 b7 (9) 11
    ("13",    [0,4,7,10,14,21]),       # R 3 5 b7 (9) 13
    ("13sus4",[0,5,7,10,14,21]),       # R 4 5 b7 (9) 13, no 3rd
    ("9sus4", [0,5,7,10,14]),          # R 4 5 b7 9
    ("6/9",   [0,4,7,9,14]),           # R 3 5 6 9
    ("m6/9",  [0,3,7,9,14]),           # R b3 5 6 9
    ("add11", [0,4,7,17]),             # R 3 5 11 (Niko's "add4")
    ("mMaj7", [0,3,7,11]),             # R b3 5 maj7
    ("7alt",  [0,4,7,10,15]),          # R 3 5 b7 #9 (altered dominant, 7#9 voiced)
    ("5",     [0,7]),                  # power chord: root + 5th, no 3rd
]

# Tones a quality may omit from its voicing, as intervals mod 12. Everything
# defaults to {7} — the perfect 5th, the one tone guitarists routinely drop.
# Extended chords additionally shed the 9th and 11th when the hand runs out of
# fingers; those tones are colour, not identity. The validator enforces this.
OPTIONAL = {
    "maj9": {7}, "m9": {7}, "m11": {7, 2}, "13": {7, 2}, "13sus4": {7, 2},
    "9sus4": {7}, "6/9": {7}, "m6/9": {7}, "add11": {7}, "mMaj7": {7}, "7alt": {7},
    "5": set(),
}

X = None  # muted string

# Movable shapes as fret offsets from the barre fret, low->high string.
# E-shape: root on 6th string.  A-shape: root on 5th string.
E_SHAPES = {
    "maj":   [0,2,2,1,0,0],
    "m":     [0,2,2,0,0,0],
    "7":     [0,2,0,1,0,0],
    "m7":    [0,2,0,0,0,0],
    "maj7":  [0,X,1,1,0,X],
    "m7b5":  [0,1,0,0,X,X],
    "dim7":  [0,1,-1,0,X,X],
    "dim":   [0,1,X,0,X,X],
    "aug":   [0,3,2,1,X,X],
    "sus2":  [0,2,2,X,0,2],
    "sus4":  [0,2,2,2,0,0],
    "7sus4": [0,2,0,2,0,0],
    "6":     [0,2,2,1,2,X],
    "m6":    [0,2,2,0,2,X],
    "add9":  [0,2,2,1,X,2],
    # extended shapes (solved for a clean 4-5 string voicing, no doubled colour tones)
    "maj9":  [0,-1,X,-1,0,-1],
    "m9":    [0,-2,X,-1,0,-2],
    "m11":   [0,X,0,0,-2,0],
    "13":    [0,-1,-1,X,0,-2],
    "13sus4":[0,X,-1,-1,-2,-2],
    "9sus4": [0,X,0,-1,-2,0],
    "6/9":   [0,-1,-1,-1,X,0],
    "m6/9":  [0,-2,-1,-1,X,0],
    "add11": [0,0,X,1,0,0],
    "mMaj7": [0,X,1,0,0,0],
    "7alt":  [0,-1,X,0,0,-2],
    "5":     [0,2,2,X,X,X],           # root, 5th, octave — the canonical power chord
}
A_SHAPES = {
    "maj":   [X,0,2,2,2,0],
    "m":     [X,0,2,2,1,0],
    "7":     [X,0,2,0,2,0],
    "m7":    [X,0,2,0,1,0],
    "maj7":  [X,0,2,1,2,0],
    "m7b5":  [X,0,1,0,1,X],
    "dim7":  [X,0,1,-1,1,X],
    "dim":   [X,0,1,2,1,X],
    "aug":   [X,0,3,2,2,1],
    "sus2":  [X,0,2,2,0,0],
    "sus4":  [X,0,2,2,3,0],
    "7sus4": [X,0,2,0,3,0],
    "6":     [X,0,2,2,2,2],
    "m6":    [X,0,2,2,1,2],
    "9":     [X,0,-1,0,0,0],
    "add9":  [X,0,2,4,2,0],
    # extended shapes (root on the 5th string)
    "maj9":  [X,0,-1,1,0,0],
    "m9":    [X,0,-2,0,0,0],
    "m11":   [X,0,-2,0,-2,-2],
    "13":    [X,0,-1,0,-2,2],
    "13sus4":[X,0,0,0,-2,2],
    "9sus4": [X,0,0,0,0,0],
    "6/9":   [X,0,-1,-1,0,0],
    "m6/9":  [X,0,-2,-1,0,0],
    "add11": [X,0,0,2,2,0],
    "mMaj7": [X,0,-2,1,-2,0],
    "7alt":  [X,0,-1,0,1,0],
    "5":     [X,0,2,2,X,X],           # root, 5th, octave
}

# Iconic open voicings that beat any barre shape. Absolute frets, low->high.
OPEN_VOICINGS = {
    ("D","maj"):  [X,X,0,2,3,2], ("D","m"):    [X,X,0,2,3,1],
    ("D","7"):    [X,X,0,2,1,2], ("D","m7"):   [X,X,0,2,1,1],
    ("D","maj7"): [X,X,0,2,2,2], ("D","sus2"): [X,X,0,2,3,0],
    ("D","sus4"): [X,X,0,2,3,3], ("D","6"):    [X,X,0,2,0,2],
    ("G","maj"):  [3,2,0,0,0,3], ("G","7"):    [3,2,0,0,0,1],
    ("G","maj7"): [3,2,0,0,0,2],
    ("C","maj"):  [X,3,2,0,1,0], ("C","7"):    [X,3,2,3,1,0],
    ("C","maj7"): [X,3,2,0,0,0], ("C","add9"): [X,3,2,0,3,0],
    ("B","7"):    [X,2,1,2,0,2],
    ("A","9"):    [X,0,2,4,2,3],
    ("E","maj7"): [0,2,1,1,0,0], ("E","6"):    [0,2,2,1,2,0],
    ("E","m6"):   [0,2,2,0,2,0], ("G","6"):    [3,2,0,0,0,0],
}

def to_pitches(frets):
    return [o + f for o, f in zip(OPEN, frets) if f is not None]

def validate(root_pc, intervals, frets, label, optional={7}):
    """pitches must all belong to the chord; every essential tone must be present.

    `optional` is the set of intervals (mod 12) the voicing may omit. It defaults
    to {7}, the perfect 5th — the only tone a plain triad or 7th chord may drop.
    Extended chords pass a wider set (adding the 9th/11th) so a four-finger hand
    can still voice a 13th; see OPTIONAL. Anything not optional is essential."""
    opt = {i % 12 for i in optional}
    pcs = {p % 12 for p in to_pitches(frets)}
    allowed = {(root_pc + i) % 12 for i in intervals}
    essential = {(root_pc + i) % 12 for i in intervals if i % 12 not in opt}
    problems = []
    if not pcs <= allowed:
        problems.append(f"foreign notes {sorted(pcs - allowed)}")
    if not essential <= pcs:
        problems.append(f"missing essential {sorted(essential - pcs)}")
    if min(f for f in frets if f is not None) < 0:
        problems.append("negative fret")
    span = [f for f in frets if f is not None and f > 0]
    if span and max(span) - min(span) > 4:
        problems.append(f"stretch {max(span)-min(span)}")
    return problems

def build_voicing(root, quality, intervals):
    pc = ROOT_PC[root]
    if (root, quality) in OPEN_VOICINGS:
        return OPEN_VOICINGS[(root, quality)], "open"
    cands = []
    for shapes, string_pc, tag in ((E_SHAPES, 4, "E-shape"), (A_SHAPES, 9, "A-shape")):
        if quality not in shapes:
            continue
        offs = shapes[quality]
        base = (pc - string_pc) % 12
        for barre in (base, base + 12):
            frets = [None if o is None else barre + o for o in offs]
            if min(f for f in frets if f is not None) < 0:
                continue
            if max(f for f in frets if f is not None) > 14:
                continue
            cands.append((max(f for f in frets if f is not None), frets, f"{tag} @{barre}"))
    if not cands:
        return None, None
    cands.sort(key=lambda c: c[0])
    _, frets, tag = cands[0]
    return frets, tag

def diagram(frets):
    return "".join("x" if f is None else (str(f) if f < 10 else chr(ord('a') + f - 10))
                   for f in frets)

def note_names(frets):
    return " ".join(NAMES[p % 12] + str(p // 12 - 1) for p in to_pitches(frets))

def write_midi(path, name, chords):
    """chords = list of (label, frets)"""
    mid = MidiFile(ticks_per_beat=TPQ)
    tr = MidiTrack()
    mid.tracks.append(tr)
    tr.append(MetaMessage('track_name', name=name, time=0))
    tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(100), time=0))
    tr.append(MetaMessage('time_signature', numerator=4, denominator=4, time=0))
    tr.append(Message('program_change', program=PROGRAM, channel=0, time=0))
    carry = 0
    for label, frets in chords:
        notes = to_pitches(frets)
        vels = [96, 92, 88, 84, 80, 86][-len(notes):]
        tr.append(MetaMessage('marker', text=label, time=carry))
        ev = []
        for i, (n, v) in enumerate(zip(notes, vels)):
            ev.append((i * STRUM, 'note_on', n, v))
            ev.append((BAR - 20, 'note_off', n, 0))
        ev.sort(key=lambda e: (e[0], e[1] == 'note_on'))
        prev = 0
        for t, kind, n, v in ev:
            tr.append(Message(kind, note=n, velocity=v, channel=0, time=t - prev))
            prev = t
        carry = BAR - prev
    tr.append(MetaMessage('end_of_track', time=carry))
    mid.save(path)

# ---- build everything ----
work = "build/pack"
shutil.rmtree(work, ignore_errors=True)
rows, issues = [], []

for root in ROOTS:
    folder = os.path.join(work, root)
    os.makedirs(folder, exist_ok=True)
    all_for_root = []
    for quality, intervals in QUALITIES:
        frets, tag = build_voicing(root, quality, intervals)
        if frets is None:
            issues.append(f"{root}{quality}: NO SHAPE")
            continue
        p = validate(ROOT_PC[root], intervals, frets, root + quality,
                     OPTIONAL.get(quality, {7}))
        if p:
            issues.append(f"{root}{quality} {diagram(frets)} ({tag}): {'; '.join(p)}")
        label = f"{root}{quality if quality != 'maj' else ''}"
        rows.append([label, root, quality, diagram(frets), tag, note_names(frets)])
        all_for_root.append((label, frets))
        safe = label.replace('#', 's').replace('/', '-')
        write_midi(os.path.join(folder, f"{safe}.mid"), label, [(label, frets)])
    write_midi(os.path.join(folder, f"_{root}_all.mid"), f"{root} - all qualities",
               all_for_root)

print("VALIDATION ISSUES:", len(issues))
for i in issues:
    print("  ", i)
print("\ntotal chords:", len(rows))

# ---- chart + packaging ----
out = "packs"
os.makedirs(out, exist_ok=True)

with open(os.path.join(work, "chord-index.csv"), "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["chord", "root", "quality", "frets (low->high)", "shape", "notes"])
    w.writerows(rows)

by_root = {}
for r in rows:
    by_root.setdefault(r[1], []).append(r)

lines = ["# Guitar Chord Pack — voicing reference", "",
         "Fret strings low E -> high E. `x` = muted, `0` = open. Frets 10+ shown as a,b,c,d.", ""]
for root in ROOTS:
    lines += [f"## {root}", "", "| Chord | Frets | Shape | Notes |", "|---|---|---|---|"]
    for label, _, q, dia, tag, notes in by_root[root]:
        lines.append(f"| {label} | `{dia}` | {tag} | {notes} |")
    lines.append("")
chart = "\n".join(lines)
open(os.path.join(work, "CHORD-CHART.md"), "w").write(chart)
open(os.path.join(out, "CHORD-CHART.md"), "w").write(chart)

zpath = os.path.join(out, "guitar-chord-pack.zip")
with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
    for dirpath, _, files in os.walk(work):
        for fn in sorted(files):
            full = os.path.join(dirpath, fn)
            z.write(full, os.path.relpath(full, work))

n = sum(len(f) for _, _, f in os.walk(work))
print("files in zip:", n, "| zip size:", round(os.path.getsize(zpath)/1024, 1), "KB")
print()
for label, _, q, dia, tag, notes in by_root["A"]:
    print(f"{label:8} {dia:7} {tag:12} {notes}")
