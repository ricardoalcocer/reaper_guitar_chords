import os
os.makedirs("build",exist_ok=True)
os.makedirs("packs",exist_ok=True)

from mido import MidiFile, MidiTrack, Message, MetaMessage, bpm2tempo
import os, shutil, zipfile

TPQ, PROGRAM = 480, 25
E8 = TPQ // 2            # eighth note
S16 = TPQ // 4           # sixteenth
BAR = TPQ * 4
OPEN = [40, 45, 50, 55, 59, 64]
NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']
X = None

def pitches(frets):
    return [o + f for o, f in zip(OPEN, frets) if f is not None]

# ---------------- articulation engine ----------------
# A "hit" = one strum. Returns list of (offset_tick, note, velocity, gate_ticks)

def strum(notes, kind, step, accent=1.0):
    """kind: D (down, all strings), U (up, top strings), d/u lighter,
             x (fret-hand mute click), P (palm-muted, bass strings, short)."""
    if kind in ('D', 'd'):
        order, spread = notes, 14
        vel = [96, 92, 88, 85, 82, 88][-len(order):]
        gate = step * 4
    elif kind in ('U', 'u'):
        order = list(reversed(notes[-4:]))       # upstrokes catch the top strings
        spread = 9
        vel = [78, 74, 72, 70][:len(order)]
        gate = step * 3
    elif kind == 'x':                            # percussive fret-hand mute
        order, spread = notes, 10
        vel = [46, 44, 42, 40, 38, 40][-len(order):]
        gate = S16 // 2
    elif kind == 'P':                            # palm mute: tight, short, chunky
        order, spread = notes, 4
        vel = [104, 100, 96, 92, 88, 88][-len(order):]
        gate = int(step * 0.42)
    if kind in ('d', 'u'):
        vel = [int(v * 0.78) for v in vel]
    vel = [max(1, min(127, int(v * accent))) for v in vel]
    return [(i * spread, n, v, gate) for i, (n, v) in enumerate(zip(order, vel))]

def render(frets, pattern, step, start, ring_out):
    """pattern: list of kind-or-None, one per step. Returns end tick."""
    notes = pitches(frets)
    ev = []
    slots = [i for i, k in enumerate(pattern) if k]
    for idx, i in enumerate(slots):
        kind = pattern[i]
        t0 = start + i * step
        nxt = start + slots[idx + 1] * step if idx + 1 < len(slots) else start + len(pattern) * step
        accent = 1.06 if i % 4 == 0 else 1.0
        for off, note, vel, gate in strum(notes, kind, step, accent):
            on = t0 + off
            if kind in ('P', 'x'):
                end = on + gate
            else:
                end = min(on + gate, nxt - 6) if idx + 1 < len(slots) else on + ring_out
            ev.append((on, 1, 'note_on', note, vel))
            ev.append((max(on + 20, end), 0, 'note_off', note, 0))
    return ev

def write(path, name, events, total, bpm=100, program=PROGRAM):
    mid = MidiFile(ticks_per_beat=TPQ)
    tr = MidiTrack(); mid.tracks.append(tr)
    tr.append(MetaMessage('track_name', name=name, time=0))
    tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(bpm), time=0))
    tr.append(MetaMessage('time_signature', numerator=4, denominator=4, time=0))
    tr.append(Message('program_change', program=program, channel=0, time=0))
    events = [e if e[2] != 'note_off' else (min(e[0], total - 6), e[1], e[2], e[3], e[4])
              for e in events]
    marks = [e for e in events if e[2] == 'marker']
    notes = sorted([e for e in events if e[2] != 'marker'], key=lambda e: (e[0], e[1]))
    allev = sorted(marks + notes, key=lambda e: (e[0], e[1]))
    prev = 0
    for e in allev:
        t = e[0]
        if e[2] == 'marker':
            tr.append(MetaMessage('marker', text=e[3], time=t - prev))
        else:
            tr.append(Message(e[2], note=e[3], velocity=e[4], channel=0, time=t - prev))
        prev = t
    tr.append(MetaMessage('end_of_track', time=max(0, total - prev)))
    mid.save(path)

# ---------------- content ----------------
PATTERNS = {                       # eight eighth-note slots per bar
    "01_downs":       ['D', None, 'D', None, 'D', None, 'D', None],
    "02_eighths":     ['D', 'U', 'D', 'U', 'D', 'U', 'D', 'U'],
    "03_classic":     ['D', None, 'D', 'U', None, 'U', 'D', 'U'],
    "04_pop":         ['D', None, 'D', 'U', None, 'U', 'D', None],
    "05_ghosted":     ['D', 'x', 'D', 'U', 'x', 'U', 'D', 'U'],
    "06_offbeat":     [None, 'U', 'D', 'U', None, 'U', 'D', 'U'],
}

CHORDS = {
    "E":  [0,2,2,1,0,0], "Em": [0,2,2,0,0,0],
    "F":  [1,3,3,2,1,1], "Fm": [1,3,3,1,1,1],
    "G":  [3,2,0,0,0,3], "Am": [X,0,2,2,1,0],
    "D":  [X,X,0,2,3,2], "Dm": [X,X,0,2,3,1],
    "C":  [X,3,2,0,1,0],
}

PROGRESSIONS = {
    "Am-F-C-G":  ["Am", "F", "C", "G"],
    "Em-C-G-D":  ["Em", "C", "G", "D"],
    "E-A-D" :    None,   # placeholder, skipped
}

ROOTS = ['E','F','Gb','G','Ab','A','Bb','B','C','Db','D','Eb']
ROOT_PC = {n: i for i, n in enumerate(NAMES)}

def power_chord(root, three_note=True):
    pc = ROOT_PC[root]
    cands = []
    for string_pc, base_idx in ((4, 0), (9, 1)):     # 6th string, 5th string
        f = (pc - string_pc) % 12
        frets = [X] * 6
        frets[base_idx] = f
        frets[base_idx + 1] = f + 2
        if three_note:
            frets[base_idx + 2] = f + 2
        cands.append((f, frets))
    cands.sort(key=lambda c: c[0])
    return cands[0][1]

work = "build/adv"
shutil.rmtree(work, ignore_errors=True)
made = []

def out(sub, fn):
    d = os.path.join(work, sub); os.makedirs(d, exist_ok=True)
    p = os.path.join(d, fn); made.append(os.path.relpath(p, work)); return p

# 1. one-bar strum loops, every chord x every pattern
for cname, frets in CHORDS.items():
    for pname, pat in PATTERNS.items():
        ev = [(0, -1, 'marker', f"{cname} {pname[3:]}")] + render(frets, pat, E8, 0, TPQ)
        write(out(f"1_strum-loops/{cname}", f"{cname}_{pname}.mid"),
              f"{cname} {pname}", ev, BAR)

# 2. four-bar progressions in each pattern
for prog, chords in PROGRESSIONS.items():
    if not chords: continue
    for pname, pat in PATTERNS.items():
        ev, t = [], 0
        for c in chords:
            ev.append((t, -1, 'marker', c))
            ev += render(CHORDS[c], pat, E8, t, TPQ)
            t += BAR
        write(out("2_progressions", f"{prog}_{pname}.mid"), f"{prog} {pname}", ev, t)

# 3. palm-muted open/barre chords (bass strings only, straight eighths + accents)
PM_BAR = ['P'] * 8
for cname, frets in CHORDS.items():
    low = [f for f in frets if f is not None][:3]
    idx = [i for i, f in enumerate(frets) if f is not None][:3]
    trimmed = [frets[i] if i in idx else X for i in range(6)]
    ev = [(0, -1, 'marker', f"{cname} palm mute")] + render(trimmed, PM_BAR, E8, 0, S16)
    write(out("3_palm-muted-chords", f"{cname}_palmmute.mid"), f"{cname} PM", ev, BAR)

# 4. power chords: sustained, palm-muted chug, gallop, and open/mute alternation
GALLOP = ['P', None, 'P', 'P'] * 4        # sixteenth grid: long-short-short
for root in ROOTS:
    pc3 = power_chord(root)
    tag = root.replace('#', 's')
    ev = [(0, -1, 'marker', f"{root}5")] + render(pc3, ['D'] + [None]*7, E8, 0, BAR)
    write(out(f"4_power-chords/{root}", f"{tag}5_sustained.mid"), f"{root}5", ev, BAR)

    ev = [(0, -1, 'marker', f"{root}5 PM chug")] + render(pc3, PM_BAR, E8, 0, S16)
    write(out(f"4_power-chords/{root}", f"{tag}5_palmmute_8ths.mid"), f"{root}5 PM", ev, BAR)

    ev = [(0, -1, 'marker', f"{root}5 PM gallop")] + render(pc3, GALLOP, S16, 0, S16)
    write(out(f"4_power-chords/{root}", f"{tag}5_palmmute_gallop.mid"), f"{root}5 gallop", ev, BAR)

    # mute/open dynamics: chugs with accented open hits on 2 and 4
    mix = ['P', 'P', 'D', 'P', 'P', 'P', 'D', 'P']
    ev = [(0, -1, 'marker', f"{root}5 mute+open")] + render(pc3, mix, E8, 0, S16)
    write(out(f"4_power-chords/{root}", f"{tag}5_mute-open.mid"), f"{root}5 mix", ev, BAR)

# 5. demo riff: palm-muted power chord progression
riff = [("E", 1), ("G", 1), ("A", 1), ("G", 1)]
ev, t = [], 0
for root, bars in riff:
    pc3 = power_chord(root)
    ev.append((t, -1, 'marker', f"{root}5"))
    ev += render(pc3, ['P','P','P','P','P','P','D',None], E8, t, S16)
    t += BAR
write(out("5_demo", "powerchord-riff_E-G-A-G.mid"), "PM riff", ev, t, bpm=140)

print(len(made), "files")
for m in sorted(made)[:6]: print("  ", m)
