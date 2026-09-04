# Changelog

All notable changes to **Guitar Songwriter** — the browser tool (`web/guitar-audition.html`)
and the REAPER script (`reaper/GuitarChordPack.lua`), built from one source. Both stamp the same
version, so a matching stamp means they came from the same build.

The format follows [Keep a Changelog](https://keepachangelog.com); versions are the `VERSION_BASE`
in `src/build.py` (the build appends a short source hash, e.g. `2.16.2+e0032f6`).

## [2.16.5]
### Changed
- **REAPER bar numbers moved to the top** of the song lane (a ruler row under the loop strip), like
  the web, instead of along the bottom.

## [2.16.4]
### Changed
- **REAPER arranger blocks restyled to match the web** — a dark fill with a coloured border and
  label per source (chord = blue, power = amber, prog = green, riff = purple, aligned with the web,
  which had chord/power swapped), plus a length sub-line ("3 bars"). The two lanes now read the same.

## [2.16.3]
### Fixed
- **Web: the arranger no longer shrinks when you click the lane.** Setting the cursor status was
  wrapping the transport row onto a second line, which stole height from the lane. The row now stays
  one line (the status truncates instead).
### Changed
- **REAPER progression blocks show the chord names** (e.g. `C — Bb — F`), matching the web block,
  instead of the generic label "progression".

## [2.16.2]
### Changed
- **Arranger cursor is far easier to place.** Click *anywhere* in the song lane — empty space **or
  on top of a block** — to move the play/insert cursor, and it snaps to the bar you clicked *in*
  (no more jumping to the next bar when you click past a bar's midpoint). Dragging a block still
  moves it; the × and the resize grip are unchanged. (web + REAPER)

## [2.16.1]
### Fixed
- **REAPER UI is sharp.** The interface used to render into a fixed 900-px bitmap that was then
  stretched to fill the window (blurry on large/HiDPI displays). It now draws at the window's real
  resolution.

## [2.16.0]
### Added
- **Play/insert cursor in the arranger.** Click the lane to place a cursor; **+ Song** drops the new
  block there instead of always at the end, and **Play** starts from the cursor. (web + REAPER)

## [2.15.0]
### Added
- **Guitar Songwriter logo** across the web splash, both app headers, the README, and the REAPER
  script (a dark-surface variant keeps the wordmark legible on dark backgrounds).
- **Launch splash** on the web tool — a dismissable intro that explains what it is and that it comes
  as both a browser tool and a REAPER script, with a "don't show again" option.
### Changed
- Rewrote the README around the two interactive tools; refreshed the screenshots. Home is
  **alco.rocks**; MIT is **alco.mit-license.org**.

## [2.14.0]
### Added
- **Whole-song MIDI export in REAPER** — an *Export .mid* button writes the entire arrangement to
  `GuitarChords/Song_<blocks>x<bars>bars.mid`.
- **Chord inversions on the web** — an INVERSION row on the Chord source puts the 3rd/5th/7th in the
  bass, offering only shapes a real hand can grab (parity-tested against the REAPER engine).
### Removed
- Dead pre-sidebar favorites toolbar (a duplicate Tempo slider, Save, a Favorites dropdown, Del) that
  had been left hidden in the web arranger.

## [2.13.0]
### Added
- **Undo** in both arrangers.
### Fixed
- iPad block-drag vs. scroll: a quick swipe scrolls the timeline, a hold-then-drag moves a block.

## [2.12.x]
### Changed
- Rebuilt the REAPER UI to mirror the browser tool (favorites sidebar, global Key + a source switch,
  a docked song lane). Standardized the name to **Guitar Songwriter** everywhere.
### Added
- Loop region on the arranger, per-block delete, resize/move cursors.
### Fixed
- iOS audio dropping out after an interruption (e.g. a screen recording); Safari bottom-address-bar
  safe-area layout.

## [2.11.0]
### Added
- Reconverged the REAPER script with the web tool: the song arranger, all 28 voiceable chord
  qualities, and named song favorites.

## [2.10.0]
### Added
- Procedural **riff generator** brought to the web tool, kept in lockstep with the REAPER engine by a
  parity test.
