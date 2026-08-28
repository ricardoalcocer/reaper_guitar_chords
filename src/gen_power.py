import os
os.makedirs("build",exist_ok=True)
os.makedirs("packs",exist_ok=True)

from mido import MidiFile, MidiTrack, Message, MetaMessage, bpm2tempo
import os, shutil, zipfile

TPQ, PROGRAM = 480, 30          # GM 30 = overdriven guitar (better fit for power chords)
S16, E8, BAR = TPQ // 4, TPQ // 2, TPQ * 4
TRIP = TPQ // 3
OPEN = [40, 45, 50, 55, 59, 64]
NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']
ROOT_PC = {n: i for i, n in enumerate(NAMES)}
ROOTS = ['E','F','Gb','G','Ab','A','Bb','B','C','Db','D','Eb']
X = None

def pitches(frets):
    return [o + f for o, f in zip(OPEN, frets) if f is not None]

def power_chord(root, notes=3):
    """Lowest available position; root on 6th or 5th string."""
    cands = []
    for string_pc, i in ((4, 0), (9, 1)):
        f = (ROOT_PC[root] - string_pc) % 12
        fr = [X] * 6
        fr[i] = f
        fr[i + 1] = f + 2
        if notes == 3:
            fr[i + 2] = f + 2
        cands.append((f, fr))
    cands.sort(key=lambda c: c[0])
    return cands[0][1]

def strum(notes, kind, step, accent):
    if kind == 'P':                              # palm mute: tight, short, chunky
        spread, gate = 4, int(step * 0.42)
        vel = [100, 96, 92][:len(notes)]
    elif kind == 'D':                            # open, let it ring
        spread, gate = 9, BAR
        vel = [110, 106, 102][:len(notes)]
    elif kind == 'x':                            # dead/ghost hit
        spread, gate = 6, S16 // 2
        vel = [48, 46, 44][:len(notes)]
    vel = [max(1, min(127, int(v * accent))) for v in vel]
    return [(i * spread, n, v, gate) for i, (n, v) in enumerate(zip(notes, vel))]

def render(frets, pattern, step, start, ring_out, per_beat=4):
    notes = pitches(frets)
    ev, slots = [], [i for i, k in enumerate(pattern) if k]
    for idx, i in enumerate(slots):
        kind = pattern[i]
        t0 = start + i * step
        nxt = start + (slots[idx + 1] if idx + 1 < len(slots) else len(pattern)) * step
        accent = 1.05 if i % per_beat == 0 else (0.94 if kind == 'P' else 1.0)
        for off, n, v, gate in strum(notes, kind, step, accent):
            on = t0 + off
            end = on + gate if kind in ('P', 'x') else (
                  min(on + gate, nxt - 6) if idx + 1 < len(slots) else on + ring_out)
            ev.append((on, 1, 'note_on', n, v))
            ev.append((max(on + 20, end), 0, 'note_off', n, 0))
    return ev

def write(path, name, events, total, bpm=120):
    events = [e if e[2] != 'note_off' else (min(e[0], total - 6), *e[1:]) for e in events]
    mid = MidiFile(ticks_per_beat=TPQ)
    tr = MidiTrack(); mid.tracks.append(tr)
    tr.append(MetaMessage('track_name', name=name, time=0))
    tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(bpm), time=0))
    tr.append(MetaMessage('time_signature', numerator=4, denominator=4, time=0))
    tr.append(Message('program_change', program=PROGRAM, channel=0, time=0))
    prev = 0
    for e in sorted(events, key=lambda e: (e[0], e[1])):
        if e[2] == 'marker':
            tr.append(MetaMessage('marker', text=e[3], time=e[0] - prev))
        else:
            tr.append(Message(e[2], note=e[3], velocity=e[4], channel=0, time=e[0] - prev))
        prev = e[0]
    tr.append(MetaMessage('end_of_track', time=max(0, total - prev)))
    mid.save(path)

def beat(p):                     # expand a one-beat cell to a full bar
    return p * 4

# ---- riff patterns on a 16th grid unless noted ----
PATTERNS = {
    "01_chug_8ths":      (beat(['P', None, 'P', None]), S16, 4),
    "02_chug_16ths":     (beat(['P', 'P', 'P', 'P']), S16, 4),
    "03_gallop":         (beat(['P', None, 'P', 'P']), S16, 4),
    "04_reverse_gallop": (beat(['P', 'P', None, 'P']), S16, 4),
    "05_stutter":        (beat(['P', 'P', None, None]), S16, 4),
    "06_triplets":       (['P'] * 12, TRIP, 3),
    "07_syncopated":     (['P', None, 'P', 'P', None, None, 'P', None,
                           'P', None, 'P', 'P', None, None, 'P', None], S16, 4),
    "08_push":           (['P', None, None, None, None, None, 'P', 'P',
                           None, None, 'P', None, None, None, 'P', None], S16, 4),
    "09_offbeat":        (['P', None, 'D', None] * 4, S16, 4),
    "10_open_accents":   (['P', None, 'P', None, 'D', None, 'P', None,
                           'P', None, 'P', None, 'D', None, 'P', None], S16, 4),
    "11_ring_and_chug":  (['D', None, None, None, None, None, None, None,
                           'P', None, 'P', None, 'P', None, 'P', None], S16, 4),
    "12_sustained":      (['D'] + [None] * 15, S16, 4),
    "13_ghosted_chug":   (['P', 'x', 'P', 'x', 'P', 'x', 'P', 'x',
                           'P', 'x', 'P', 'x', 'P', 'x', 'P', 'x'], S16, 4),
}

work = "build/pc"
shutil.rmtree(work, ignore_errors=True)
count = 0

for label, n_notes in (("2-note", 2), ("3-note", 3)):
    for root in ROOTS:
        d = os.path.join(work, label, root)
        os.makedirs(d, exist_ok=True)
        frets = power_chord(root, n_notes)
        for pname, (pat, step, per_beat) in PATTERNS.items():
            ev = [(0, -1, 'marker', f"{root}5 {pname[3:]}")]
            ev += render(frets, pat, step, 0, BAR, per_beat)
            write(os.path.join(d, f"{root}5_{pname}.mid"), f"{root}5 {pname}", ev, BAR)
            count += 1

# ---- demo riffs ----
demo = os.path.join(work, "demos"); os.makedirs(demo, exist_ok=True)

def multibar(seq, pattern, step, per_beat, notes=2):
    ev, t = [], 0
    for root in seq:
        ev.append((t, -1, 'marker', f"{root}5"))
        ev += render(power_chord(root, notes), pattern, step, t, BAR, per_beat)
        t += BAR
    return ev, t

p, s, pb = PATTERNS["03_gallop"]
ev, tot = multibar(["E", "E", "C", "D"], p, s, pb)
write(os.path.join(demo, "gallop-riff_E-E-C-D.mid"), "gallop riff", ev, tot, bpm=150)

p, s, pb = PATTERNS["01_chug_8ths"]
ev, tot = multibar(["A", "A", "D", "E"], p, s, pb)
write(os.path.join(demo, "punk-8ths_A-D-E.mid"), "punk riff", ev, tot, bpm=176)

p, s, pb = PATTERNS["06_triplets"]
ev, tot = multibar(["E", "G", "E", "D"], p, s, pb)
write(os.path.join(demo, "triplet-gallop_E-G-E-D.mid"), "triplet riff", ev, tot, bpm=140)

# pedal riff: constant low E5 chug with stabs of other chords layered on top
ev, t = [], 0
pedal = ['P', None, 'P', None] * 4
stab_slots = {2: [None]*6 + ['D'] + [None]*9, 3: [None]*10 + ['D'] + [None]*5}
for bar, stab in enumerate(["G", "G", "Bb", "A"]):
    ev.append((t, -1, 'marker', f"E5 pedal / {stab}5"))
    ev += render(power_chord("E", 2), pedal, S16, t, BAR, 4)
    hits = [None] * 16
    hits[6] = 'D'; hits[12] = 'D'
    ev += render(power_chord(stab, 2), hits, S16, t, BAR, 4)
    t += BAR
write(os.path.join(demo, "pedal-riff_E5-stabs.mid"), "pedal riff", ev, t, bpm=132)

print(count, "pattern files +", len(os.listdir(demo)), "demos")
