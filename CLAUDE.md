# Working in this repo

Guitar chord voicings shipped three ways: MIDI packs, a REAPER script, and a browser
tool. The hard-won part is not the code, it is the musical constants. Read this before
changing them.

## Architecture

Everything derives from `src/chorddata.json` — 192 validated voicings. Nothing else
should hardcode a fret shape.

```
src/gen_chords.py  --validates-->  build/pack/chord-index.csv
src/make_data.py   --converts-->   src/chorddata.json
src/gen_progressions.py --reads--> src/progressions.json   (from the Niko MIDI pack)
src/build.py       --injects-->    reaper/GuitarChordPack.lua   (+ src/harmony.lua, src/reaper_template.lua)
                                   web/guitar-audition.html     (+ src/web_template.html)
```

`chorddata.json` holds the 336 voicings (16 core + 12 extended qualities × 12 roots).
`progressions.json` holds the progression library: 21 named rock/metal archetypes plus
mood-tagged progressions mined from the Niko pack's filenames, each stored **relative to
its first chord** (`[semitones-above-start, quality]`) so the tool drops it at any root.
Both JSON files are embedded into both build outputs.

`reaper/` and `web/` are **build outputs**. Never edit them directly; edit the template
in `src/` and run `make`. Both files are committed anyway so users can download one file
and run it.

## Always run `make test`

Five suites, all fast:

- `tests/test_harmony.lua` — 22 textbook analysis cases (V7 is dominant, A7 in C is
  `V7/ii`, and so on). These encode music theory, not implementation details. If one
  fails, the theory is wrong, not the test.
- `tests/test_events.lua` — 62k generated events. Asserts velocity range, positive
  length, containment in the bar, plausible pitch, and **no two notes overlapping on the
  same string** (a *unison* — two strings at the same pitch — trips this too; the extended
  voicings are solved to avoid it).
- `tests/test_analysis.lua` — 8,064 analyses, no empty results, no duplicate degrees.
- `tests/test_progressions.lua` — every shipped progression must resolve to real voicings
  in all 12 keys and build valid events. A progression naming an unvoiced quality is a bug.
- `tests/test_parity.js` — the JS harmony in `web_template.html` must match
  `src/harmony.lua` on all 8,064 cases. **Two implementations of the same theory drift
  silently.** If you change one, change both — likewise the JS progression UI mirrors the
  Lua one, so change both there too.

## Musical invariants

Do not "simplify" these. Each one is the difference between sounding like a guitar and
sounding like a MIDI keyboard.

- **Voicings are fretboard shapes.** Chords have 4–6 notes, not always 6. The root is
  not always in the bass. `G` is `320003`. Muted strings are `false` in the frets array,
  low E first.
- **Strum spreads**: downstroke 14/480 QN per string low→high; upstroke 9/480 high→low
  and only the top four strings; palm mute 4/480 (nearly simultaneous); ghost 10/480.
- **Velocity by string index, not stroke order**, for downstrokes and palm mutes — bass
  strings are louder. Upstrokes are the exception: velocity follows stroke order, since
  the sweep itself fades. Getting this backwards makes power chords sound thin.
- **Note gating**: palm mutes 42% of the step; open hits ring until the next hit minus a
  small gap. The gap must be measured **from each string's own staggered start**, not
  from the stroke start, or strings collide with themselves.
- **Only the perfect 5th may be omitted** from a plain triad or 7th chord. Any other
  missing chord tone there is a bug. **Extended chords are the exception:** a guitar hand
  can't hold every tone of a 9th/11th/13th, so `gen_chords.py`'s `OPTIONAL` map lets each
  extended quality also drop its 9th and/or 11th (never the root, 3rd, 7th, or the
  characteristic extension). The default stays `{5th}`, so the 16 core qualities validate
  exactly as before.
- **Minor keys use the harmonic-minor V** (major), because that is what gets played.

## REAPER specifics

- `I_RECINPUT = 4096 | (63 << 5)` is MIDI, all inputs, all channels. 4096 is the MIDI
  flag, the next bits are the physical input.
- Audition uses `StuffMIDIMessage(0, ...)` — the virtual keyboard. It only reaches a
  track that is armed, monitored, and set to a MIDI input. The `Set up track` button and
  the `Tab` key configure all three; `checkAudible()` explains failures rather than
  playing silence. The home-row keys `a s d f g h j` play the seven diatonic chords of
  the current key (I..vii°) through that same audition path, for singing along.
- The UI is immediate-mode over `gfx`. No external dependencies — not ReaImGui, not SWS.
  Keep it that way; the point is that users can run one file.
- Test the script headlessly by setting `_G.GCP_TEST` before `dofile`, which exposes
  internals and returns before the UI section. See any test for the reaper/gfx stubs.

## Style

Lua and Python here favour short functions and explicit constants over cleverness.
Comments explain *why* a musical choice was made, not what a line does. When adding a
feature, add its test in the same commit.

## Versioning

`VERSION_BASE` in `src/build.py` is semver `MAJOR.MINOR.PATCH`, bumped by hand for
*meaning*: patch = fix, minor = feature, major = a breaking or musical-constant change.
`build.py` appends a 7-char hash of the shared sources, so the stamped version (e.g.
`2.1.0+414abd3`) changes automatically whenever any source does — two builds can never
look identical even if you forget to bump the base. The same string is stamped into both
deliverables and shown in each window/title, so matching stamps confirm the REAPER script
and the browser tool came from one build. Bump `VERSION_BASE` in the same commit as the
change it describes.
