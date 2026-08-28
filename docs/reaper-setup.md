# Guitar Chord Pack — REAPER script

Native ReaScript. No ReaPack, no ReaImGui, no SWS required.

## Install

1. In REAPER: **Actions → Show action list → New action → Load ReaScript**, pick
   `GuitarChordPack.lua`. (Or drop it in `REAPER/Scripts/` first and load from there.)
2. Select it in the action list and hit **Run**. Assign a shortcut or toolbar button
   while you're in there — it's worth having on a key.

## Hearing the audition

Auditioning plays through the instrument on your **selected track**. REAPER sends
that preview through its virtual MIDI keyboard, and a track only receives it when
three things are true: the track is armed, input monitoring is on, and its input is
set to MIDI.

**Just click "Set up track".** Select your guitar track, click that button once, and
the script sets all three (input = all MIDI inputs / all channels, record armed,
monitoring on). Then press Audition.

If it's still silent, the script tells you why in the status bar at the bottom rather
than playing nothing:

- *"No track selected"* — click a track in the arrange view first.
- *"...has no instrument on it"* — the track is wired correctly but empty. Add your
  guitar VSTi to it.
- *"Click Set up track"* — the track isn't armed for MIDI input yet.

Two things the script can't check for you: your master volume, and whether the VSTi
itself is muted or still loading its samples.

Doing it by hand instead: right-click the track's input button, choose **Input: MIDI →
Virtual MIDI keyboard → All Channels**, arm the track, and click the monitor icon so
it's lit.

## Using it

**Chords tab** — pick a root and quality, then an articulation: four single strokes
(down, up, palm mute, arpeggio) or six strum patterns. Clicking anything auditions it
immediately, so you can browse by ear.

**Power chords tab** — root, 2-note or 3-note, and thirteen riff patterns.

**Space** re-triggers the current selection. **Escape** closes.

## Roman numerals

Pick a **key** (root plus major/minor) in the KEY row. Every chord then shows its Roman
numeral and what it's doing, top right of the window:

    in C major
    V7
    Dominant
    pulls back to I

The numeral follows normal convention — uppercase for major, lowercase for minor,
`°` diminished, `ø` half-diminished, `♭` for chromatic degrees. So in C major, G7 reads
`V7`, Dm7 reads `ii7`, Bm7b5 reads `viiø7`, and Ab reads `♭VI`.

It also spots chords that aren't native to the key:

- **Secondary dominants** — A7 in C major reads `V7/ii`, because it's the V of Dm.
  E7 reads `V7/vi`, and C7 reads `V7/IV`.
- **Borrowed chords** — ♭VI, ♭VII and ♭III come from the parallel minor and are marked
  "(borrowed)".
- **Neapolitan** — ♭II, a chromatic predominant.
- **Applied diminished** — a dim7 that resolves up a semitone names its target.

Functions are grouped the usual way: **Tonic** (I, iii, vi) is home, **Predominant**
(ii, IV) moves away, **Dominant** (V, vii°) pulls back. That's the tension-and-release
cycle in three words.

## In this key

Under the KEY row is a row of the seven chords belonging to it, labelled by numeral with
the actual chord name underneath. Click any one and it loads — so you can pick a key and
play through I–vi–IV–V without working out the names yourself. The **triads/7ths**
toggle at the right switches between plain triads and seventh chords (`Imaj7 ii7 iii7
IVmaj7 V7 vi7 viiø7`).

In minor keys the V is major, not minor — that's the harmonic minor dominant that
actually gets played, rather than the modal v.

The numeral rides along into your project: inserted items and exported files are named
like `G7 (V7) gallop`, so a glance at the arrange view tells you the function.

## Getting it into a track

**Insert at cursor** — builds the MIDI item directly on the selected track at the edit
cursor, one bar long, named after the chord and pattern. This is the fast path: audition,
insert, move on. It's a single undo step.

**Save .mid** — writes the current chord and pattern to
`<project folder>/GuitarChords/` as a MIDI file. Point the **Media Explorer** at that
folder and you can drag the file onto a track, which is the drag-and-drop workflow.
Handy for combinations the pre-built packs don't include, like `Ebm7b5` with a ghosted
strum.

Both follow your **project tempo and time signature**. In 3/4 or 6/8 you get a bar of
that length, with the pattern spread across it.

## What it shares with the MIDI packs

Same 192 validated voicings, same stroke spreads (14 ticks per string on a downstroke,
9 on an upstroke sweeping high to low across the top four strings), same velocity curve
with the bass strings loudest, same note gating — palm mutes at 42% of the step, open
hits ringing until the next stroke.

Exported files are written with GM program 26 for chords and 30 for power chords. If
your VSTi ignores program changes, that line does nothing.

## Notes

The fretboard lights up string by string as it strums, in the real sweep order — a quick
visual check that you're getting the voicing you think you are.

The script sends an all-notes-off when you stop, switch tabs, or close the window, so
nothing hangs.
