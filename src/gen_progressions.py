#!/usr/bin/env python3
"""Build src/progressions.json — the mood-tagged chord-progression library.

Source: the user's Niko MIDI pack. The chord sequence of every progression is
encoded in the MIDI *filename* (e.g. `..._Am-F-C-G_...`), so nothing here reads
a single MIDI byte — it parses names. Two folders carry chord progressions:

  <key>/2 - Best Progresions/<Mood>/   curated, one clean mood per folder
  <key>/4 - Top 100 Chord Progs/       tagged with a descriptive word per file

Each progression is stored **relative to its own first chord**: a list of
[semitones-above-the-start-root, quality]. That makes it key-agnostic (the tool
transposes it to whatever root the user picks) and transposition-invariant (the
same shape filed under twelve keys collapses to one entry). Qualities are
normalised to the 28 the voicing set ships; anything that can't map is dropped
and logged, so the library never points at a chord the tool can't play.

Not shipped: the Niko/Kotoulas name, song titles, or the MIDI itself — only the
mood tag and the relative chord shape, which is not copyrightable.
"""
import os, re, json, collections

PACK = os.path.expanduser("~/Documents/_MIDI PACKS/chords/Niko_MIDI_Pack")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "progressions.json")

NOTE_PC = {'C':0,'C#':1,'Db':1,'D':2,'D#':3,'Eb':3,'E':4,'Fb':4,'E#':5,'F':5,
           'F#':6,'Gb':6,'G':7,'G#':8,'Ab':8,'A':9,'A#':10,'Bb':10,'B':11,'Cb':11,'B#':0}

# the 28 qualities the pack voices — every progression chord must land in here
SUPPORTED = {'maj','m','7','m7','maj7','m7b5','dim7','dim','aug','sus2','sus4','7sus4',
             '6','m6','9','add9','maj9','m9','m11','13','13sus4','9sus4','6/9','m6/9',
             'add11','mMaj7','7alt','5'}


def canon_quality(q):
    """Normalise a raw filename chord-suffix to one of SUPPORTED, or None."""
    inner = (q.replace('.mid','').replace('Maj','maj').replace('MAJ','maj')
              .replace('min','m').replace('Min','m').replace('Sus','sus').replace('SUS','sus')
              .replace('Add','add').replace('ADD','add').replace('Alt','alt').replace('ALT','alt')
              .replace('Dim','dim').replace('(','').replace(')','').replace(',','').strip())
    table = [
        (('','maj'), 'maj'), (('m','mb'), 'm'), (('5',), '5'), (('7',), '7'),
        (('6','maj6'), '6'), (('m6',), 'm6'), (('m7',), 'm7'),
        (('maj7','maj7#11','maj7no3','maj7b5','maj7add2'), 'maj7'), (('9',), '9'),
        (('sus2','7sus2','m7sus2','msus2','sus2b5','sus2#11'), 'sus2'),
        (('sus4','msus4','sus','sus1'), 'sus4'), (('7sus4',), '7sus4'),
        (('dim','mdim','mb5','m5'), 'dim'), (('dim7',), 'dim7'), (('aug','maug'), 'aug'),
        (('m7b5','min7b5','m7b5add4'), 'm7b5'),
        (('add2','add24','add2#11','madd2','m7add2','maj6add2','maj7add2'), 'add9'),
        (('add4','madd4','m7add4','m7sus4'), 'add11'),
        (('maj9','maj9#11','maj9#5','maj9add4'), 'maj9'),
        (('m9','m9sus4','m9add4','min9'), 'm9'), (('m11',), 'm11'),
        (('69','6/9'), '6/9'), (('m69',), 'm6/9'),
        (('9sus4','9sus4b13'), '9sus4'),
        (('sus13','sus13b9','sus13b9b13','msus13'), '13sus4'), (('13',), '13'),
        (('alt','7#9','7b9','7b5','b5'), '7alt'),
        (('mmaj7','mmaj9','mbmaj9'), 'mMaj7'),
    ]
    for keys, name in table:
        if inner in keys:
            return name if name in SUPPORTED else None
    return None


ROOT_RE = re.compile(r'^([A-G][#b]?)(.*)$')
RUN_RE = re.compile(r'((?:[A-G][#b]?[^\s_-]*)(?:-(?:[A-G][#b]?[^\s_-]*))+)')


def parse_chords(fname):
    """-> list of (pc, quality) or None if the name has no clean chord run."""
    base = fname[:-4] if fname.lower().endswith('.mid') else fname
    runs = RUN_RE.findall(base)
    if not runs:
        return None
    seq = max(runs, key=len)
    out = []
    for tok in seq.split('-'):
        m = ROOT_RE.match(tok)
        if not m:
            return None
        q = canon_quality(m.group(2))
        if q is None:
            return None
        out.append((NOTE_PC[m.group(1)], q))
    return out


# consolidate Niko's many tags (folder names + Top-100 words) into a few moods.
# first substring that matches wins, so order is priority.
MOOD_RULES = [
    ('jazz', 'Jazz'), ('neosoul', 'Jazz'), ('soul', 'Jazz'), ('smooth', 'Jazz'),
    ('funk', 'Jazz'), ('r&b', 'Jazz'),
    ('sad', 'Sad'), ('melanchol', 'Sad'),
    ('sexy', 'Sexy'), ('sixnine', 'Sexy'), ('spice', 'Sexy'),
    ('edm', 'EDM'),
    ('pop', 'Pop'),
    ('dark', 'Dark'), ('myster', 'Dark'), ('suspen', 'Dark'), ('trap', 'Dark'),
    ('hiphop', 'Dark'), ('unresolv', 'Dark'),
    ('inspir', 'Inspiring'), ('resolv', 'Inspiring'), ('moving', 'Inspiring'),
    ('dramatic', 'Inspiring'), ('cinematic', 'Inspiring'), ('epic', 'Inspiring'),
    ('intense', 'Dark'),
    ('gospel', 'Jazz'), ('church', 'Jazz'), ('7th', 'Jazz'), ('ninth', 'Jazz'),
    ('happy', 'Pop'), ('feelgood', 'Pop'), ('goodmorning', 'Pop'), ('country', 'Pop'),
    ('beautif', 'Beautiful'), ('gorgeous', 'Beautiful'), ('pretty', 'Beautiful'),
    ('dreamy', 'Beautiful'), ('sus', 'Beautiful'),
    ('emotional', 'Emotional'),
    ('cool', 'Unique'), ('interesting', 'Unique'), ('great', 'Unique'),
    ('unique', 'Unique'),
]
MOOD_ORDER = ['Rock', 'Metal', 'Phrygian', 'Blues',
              'Emotional', 'Beautiful', 'Sad', 'Jazz', 'Pop', 'Dark', 'Sexy',
              'Inspiring', 'EDM', 'Unique', 'Other']

# Hand-authored rock/metal archetypes — the 60-year canon a rock/metal writer
# reaches for. Unlike the mood progressions these are NAMED, and the metal ones
# default to power chords ('5'), the sound the genre is actually built on.
# Degrees are semitones above the tonic (which is chord 0), so the tool drops
# them at whatever root the player picks. `♭` in names is just the display.
ARCHETYPES = [
    # --- Metal: Aeolian / power-chord canon ---
    ('Metal', 'Aeolian vamp · i-♭VI-♭VII',      [(0,'5'),(8,'5'),(10,'5')]),
    ('Metal', 'Descending · i-♭VII-♭VI-♭VII',[(0,'5'),(10,'5'),(8,'5'),(10,'5')]),
    ('Metal', 'Epic cadence · ♭VI-♭VII-i',      [(8,'5'),(10,'5'),(0,'5')]),
    ('Metal', 'Aeolian four · i-♭VI-♭III-♭VII',[(0,'5'),(8,'5'),(3,'5'),(10,'5')]),
    ('Metal', 'Minor drive · i-iv-♭VII',             [(0,'5'),(5,'5'),(10,'5')]),
    ('Metal', 'Gallop · i-♭VII-♭VI-V',          [(0,'5'),(10,'5'),(8,'5'),(7,'5')]),
    ('Metal', 'Power anthem · i-♭III-♭VI-♭VII',[(0,'5'),(3,'5'),(8,'5'),(10,'5')]),
    ('Metal', 'Doom · i-♭VI',                        [(0,'5'),(8,'5')]),
    # --- Phrygian / neoclassical ---
    ('Phrygian', 'Phrygian · i-♭II',                 [(0,'5'),(1,'5')]),
    ('Phrygian', 'Phrygian dominant · I-♭II',        [(0,'maj'),(1,'maj')]),
    ('Phrygian', 'Neoclassical · i-♭II-♭III-♭II',[(0,'5'),(1,'5'),(3,'5'),(1,'5')]),
    ('Phrygian', 'Andalusian · i-♭VII-♭VI-V',   [(0,'m'),(10,'maj'),(8,'maj'),(7,'maj')]),
    # --- Classic / hard rock (triads) ---
    ('Rock', 'Mixolydian rock · I-♭VII-IV',          [(0,'maj'),(10,'maj'),(5,'maj')]),
    ('Rock', 'Three-chord · I-IV-V',                      [(0,'maj'),(5,'maj'),(7,'maj')]),
    ('Rock', 'The anthem · I-V-vi-IV',                    [(0,'maj'),(7,'maj'),(9,'m'),(5,'maj')]),
    ('Rock', 'Sad-punk · vi-IV-I-V',                      [(9,'m'),(5,'maj'),(0,'maj'),(7,'maj')]),
    ('Rock', 'Classic · I-♭VII-IV-I',                [(0,'maj'),(10,'maj'),(5,'maj'),(0,'maj')]),
    ('Rock', 'Grunge · I-♭III-♭VI-♭VII',   [(0,'maj'),(3,'maj'),(8,'maj'),(10,'maj')]),
    ('Rock', 'Lift · I-V-♭VII-IV',                   [(0,'maj'),(7,'maj'),(10,'maj'),(5,'maj')]),
    # --- Blues-rock ---
    ('Blues', '12-bar blues',
        [(0,'7'),(0,'7'),(0,'7'),(0,'7'),(5,'7'),(5,'7'),(0,'7'),(0,'7'),
         (7,'7'),(5,'7'),(0,'7'),(7,'7')]),
    ('Blues', 'Minor blues · i-iv-i-v',                   [(0,'m7'),(5,'m7'),(0,'m7'),(7,'7')]),
]


def mood_of(tag):
    t = tag.lower()
    for key, mood in MOOD_RULES:
        if key in t:
            return mood
    return 'Other'


def main():
    # (chords_tuple) -> best (mood, chords). curated Best-Progresions moods win
    # ties over the Top-100's looser tags.
    seen = {}
    dropped = collections.Counter()
    kept = 0
    for r, _, files in os.walk(PACK):
        parts = r.split(os.sep)
        curated = 'Best Progresions' in ' / '.join(parts)  # folder "2 - Best Progresions"
        top100 = any('Top 100 Chord Progs' in p for p in parts)
        if not (curated or top100):
            continue
        # source tag: for curated it's the mood subfolder; for top100 the file word
        folder_mood = parts[-1] if curated else None
        for f in files:
            if not f.lower().endswith('.mid'):
                continue
            chords = parse_chords(f)
            if not chords:
                dropped['unparsed'] += 1
                continue
            if curated:
                mood = mood_of(folder_mood)
                priority = 0
            else:
                m = re.match(r'^\d+_([A-Za-z&]+)', f)
                mood = mood_of(m.group(1)) if m else 'Other'
                priority = 1
            # first chord defines the tonic; store semitones above it
            root0 = chords[0][0]
            rel = tuple(((pc - root0) % 12, q) for pc, q in chords)
            if len(rel) < 2 or len(rel) > 12:
                continue
            prev = seen.get(rel)
            if prev is None or priority < prev[0]:
                seen[rel] = (priority, mood)
            kept += 1

    # bucket by mood, drop the tiny "Other" tail if you like — keep it, it's real
    progs = []
    for rel, (priority, mood) in seen.items():
        progs.append({'mood': mood, 'name': '', 'chords': [[d, q] for d, q in rel]})
    # stable, pleasant order: by mood, then by length, then lexically
    progs.sort(key=lambda p: (MOOD_ORDER.index(p['mood']),
                              len(p['chords']),
                              [c[0] for c in p['chords']]))

    # named rock/metal archetypes lead each of their categories, in authored order
    arche = [{'mood': m, 'name': n, 'chords': [[d, q] for d, q in ch]}
             for m, n, ch in ARCHETYPES]
    for a in arche:
        for c in a['chords']:
            if c[1] not in SUPPORTED:
                raise SystemExit(f"archetype {a['name']} uses unvoiced quality {c[1]}")
    progs = arche + progs

    moods_present = [m for m in MOOD_ORDER
                     if any(p['mood'] == m for p in progs)]
    data = {'moods': moods_present, 'progressions': progs}
    json.dump(data, open(OUT, 'w'), separators=(',', ':'))

    counts = collections.Counter(p['mood'] for p in progs)
    print(f'{len(progs)} unique progressions -> {os.path.relpath(OUT)}')
    print(f'  parsed {kept} files, dropped {dropped["unparsed"]} unparseable names')
    for m in moods_present:
        print(f'  {m:12} {counts[m]}')


if __name__ == '__main__':
    main()
