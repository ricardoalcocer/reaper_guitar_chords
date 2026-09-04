<div align="center">

# 🎸 Guitar Songwriter

**Chords that sound like a guitar — a browser tool and a REAPER script, built from one source.**

Audition real fretboard voicings, browse progressions and metal riffs in any key, arrange them on a
timeline, and export the result as MIDI. Every chord is an actual hand shape, not a stacked triad — a
`D` is `xx0232`, four notes with the bass strings muted — so it sounds *played*, not typed.

[![license](https://img.shields.io/badge/license-MIT-3b82f6)](https://alco.mit-license.org)
![version](https://img.shields.io/badge/version-2.15.0-f59e0b)
![browser](https://img.shields.io/badge/browser-standalone_HTML-2a9d8f)
![REAPER](https://img.shields.io/badge/REAPER-ReaScript-2a9d8f)
![runtime deps](https://img.shields.io/badge/runtime_deps-none-22c55e)
![voicings](https://img.shields.io/badge/voicings-336-64b5f6)
![progressions](https://img.shields.io/badge/progressions-231-64b5f6)

<img src="docs/images/screenshot-chords.png?v=3" alt="Guitar Songwriter — auditioning a C major voicing with its diatonic chords, strum patterns, inversions, and the song arranger docked below" width="880">

</div>

## What is this?

A songwriting tool for anyone who thinks on the guitar but works in a DAW. Pick a chord, hear it as a
real guitar shape, see how it functions in your key, stack chords, strums, power riffs and progressions
onto a timeline, loop and tweak them — then export the whole thing as MIDI.

## Two ways to use it

Both are built from the **same 336 validated voicings and the same rhythm engine**, so they stay in
perfect sync — same shapes, same strokes, same MIDI. Pick whichever fits how you're working:

| | | |
|---|---|---|
| 🌐 **Browser tool** | the full tool, played by a built-in plucked-string synth — nothing to install | one `.html` file · [**alco.rocks**](https://alco.rocks) |
| 🎛️ **REAPER script** | the same tool inside REAPER — audition through your own guitar VSTi and drop MIDI at the cursor | one `.lua` file, no extensions |

It also writes **MIDI packs** — `make packs` renders ~500 `.mid` files (every chord, six strum patterns,
power chords in thirteen riff patterns) to drag straight into any DAW.

## Why it sounds like a guitar

Most "chord to MIDI" tools stack a triad in root position. Real guitarists don't play that way, and it
shows the moment you hear it. This tool encodes the parts that actually matter:

- **Real fretboard shapes** — 4 to 6 notes, the root often *not* in the bass, muted strings where a hand would mute them (`G` = `320003`).
- **Real strum mechanics** — downstrokes sweep low→high, upstrokes high→low and only catch the top strings, bass strings ring louder, palm mutes choke to 42% of the beat.
- **No collisions** — the voicings are solved so no two notes ever fight on the same string, and 62,000+ generated events are tested to prove it.
- **Validated harmony** — no note outside the chord, no missing chord tone (only the perfect 5th may drop, as guitarists do). A shape that breaks the rules refuses to ship.

## Features

- 🎼 **336 voicings** — 12 roots × 28 qualities (16 core + 12 extended), each an E-shape barre, A-shape barre, or open position, always the lowest on the neck.
- 🔄 **Playable inversions** — put the 3rd, 5th or 7th in the bass; only shapes a real hand can grab are offered, so an inversion is never unplayable.
- 🧠 **Roman-numeral analysis** in any key — secondary dominants (`V7/ii`), borrowed chords (`♭VI`), Neapolitan (`♭II`), applied diminished, plus a one-click row of the key's seven diatonic chords.
- 🎵 **Progression library** — 21 named rock/metal archetypes (Aeolian vamp, Andalusian cadence, Phrygian dominant, 12-bar…) plus mood-tagged progressions (Emotional, Beautiful, Jazz, Dark, Sexy…). Stored key-agnostically, so any one drops onto any root.
- 🥁 **Power chords & procedural riffs** — thirteen metal rhythm patterns (chug 8ths, gallop, triplets…) over Phrygian / Phrygian-dominant / Aeolian scales.
- 🎚️ **Song arranger** — stack chords, strums, riffs and progressions onto a timeline as loop blocks, drag to arrange, set a loop range, then export the whole song as MIDI (or, in REAPER, commit it at the cursor). Save arrangements as named favorites.
- ⌨️ **Play-along keyboard** — the home row plays the seven diatonic chords of the current key, so you can hold a chord and sing over it without touching the mouse.
- 🎧 **Audition anywhere** — through your real guitar VSTi in REAPER, or the plucked-string synth in the browser.

## Quick start

### 🌐 Browser

Open it at [**alco.rocks**](https://alco.rocks), or run the file locally: [`web/guitar-audition.html`](web/guitar-audition.html).
Nothing to install — audio starts on your first tap.

> On an iPad or phone, open the hosted page — mobile browsers can't open a local `.html` file directly.
> (To preview a local build on a phone, serve the repo folder over your network: `python3 -m http.server`,
> then browse to `http://<your-computer-ip>:8000/web/guitar-audition.html`.)

### 🎛️ REAPER

1. **Actions → Show action list → New action → Load ReaScript…** and choose [`reaper/GuitarChordPack.lua`](reaper/GuitarChordPack.lua).
2. Select a track that has your guitar VSTi on it.
3. Press **`Tab`** (or click **Set up track**) to arm it, enable input monitoring, and set MIDI input.
4. Press **`space`** to audition, tweak root / quality / strum, then **Send to REAPER** to commit the MIDI.

Full walkthrough: [docs/reaper-setup.md](docs/reaper-setup.md).

#### Sing and accompany yourself

The home row plays the seven diatonic chords of the current key, left to right — hold a chord, sing over
it, and move on without touching the mouse:

```
 key:     a    s    d    f    g    h    j
 degree:  I    ii   iii  IV   V    vi   vii°
```

Set the key and major/minor, press a home-row key, sing, press the next one. Each chord plays with the
current strum and loops while you hold the idea.

### 🎹 MIDI packs

```sh
make packs   # writes ~500 .mid files to packs/
```

Every chord, six strum patterns, and power chords in thirteen riff patterns — drag them straight into any DAW.

## The progression library

Pick a style, click a progression, and audition or insert it in any key. Metal archetypes voice as power chords automatically.

<div align="center">
<img src="docs/images/screenshot-progressions.png?v=3" alt="The progression library, filtered by mood, auditioning a progression in the current key" width="880">
</div>

## What's in the box

**336 voicings** — 12 roots × 28 qualities. The 16 core (`maj`, `m`, `7`, `m7`, `maj7`, `m7b5`, `dim7`,
`dim`, `aug`, `sus2`, `sus4`, `7sus4`, `6`, `m6`, `9`, `add9`) plus 12 extended (`maj9`, `m9`, `m11`,
`13`, `13sus4`, `9sus4`, `6/9`, `m6/9`, `add11`, `mMaj7`, `7alt`, and the power chord `5`). Inversions
are offered only where a real hand can grab the shape.

See the full [chord chart](docs/chord-chart.md), [strum packs](docs/strum-packs.md), and [power packs](docs/power-packs.md).

## Repo layout

| path | what |
|---|---|
| `web/guitar-audition.html` | the standalone browser tool (a build output — don't edit directly) |
| `reaper/GuitarChordPack.lua` | the REAPER script (a build output — don't edit directly) |
| `src/` | generators, templates, and `chorddata.json` — the single source of truth |
| `tests/` | voicing, event, harmony, progression and cross-implementation checks |
| `docs/` | setup guide and the full fret charts |

## Building from source

```sh
make          # build both targets from src/
make data     # regenerate + revalidate chord data, then build
make test     # full suite (harmony, 62k events, analysis, progressions, JS parity)
make packs    # generate the MIDI packs
```

Requires `python3` with `mido`, `lua5.4`, and `node` (for the parity tests). `reaper/` and `web/` are
generated from the templates in `src/` — edit the template and run `make`, never the outputs.

The tool exists as two implementations of the same music theory (Lua and JavaScript), kept in lockstep by
the parity tests: `tests/test_parity.js` compares all 8,064 harmonic analyses, and the riff and inversion
engines are diffed shape-for-shape between the two. If they ever drift, the build fails.

## License

[MIT](https://alco.mit-license.org) © 2026 Ricardo Alcocer
