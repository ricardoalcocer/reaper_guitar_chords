# Power Chord MIDI Pack

GM program 30 (overdriven guitar), 120 BPM, 4/4. Every loop is exactly one bar
and tiles cleanly. Voicings sit in the lowest available position: E5-Ab5 are
rooted on the 6th string, A5-Eb5 on the 5th.

## 2-note/  and  3-note/
Same 13 patterns for every root, twice over:
  2-note = root + 5th          (tighter, cleaner under distortion)
  3-note = root + 5th + octave (fuller, better for clean or light drive)

## Patterns
  01_chug_8ths       straight eighth palm mutes
  02_chug_16ths      driving sixteenths
  03_gallop          eighth + two sixteenths per beat
  04_reverse_gallop  two sixteenths + eighth
  05_stutter         paired sixteenths, rest on the back half of each beat
  06_triplets        three per beat (triplet grid, not sixteenths)
  07_syncopated      off-beat accents pushing across the bar
  08_push            sparse, hits anticipating beats 3 and 4
  09_offbeat         muted downbeat, open chord on every off-beat
  10_open_accents    eighth chugs with the chord ringing on 2 and 4
  11_ring_and_chug   open hit rings two beats, then chugs
  12_sustained       one hit, rings the full bar
  13_ghosted_chug    chugs with dead-string clicks between them

## demos/
  gallop-riff_E-E-C-D    150 BPM
  punk-8ths_A-D-E        176 BPM
  triplet-gallop_E-G-E-D 140 BPM
  pedal-riff_E5-stabs    132 BPM, constant E5 chug with chord stabs layered over

## How the mutes are written
Palm mutes are short (~42% of the step) and hit at velocity 92-105, with the
strings only 4 ticks apart since a muted hit is nearly simultaneous. Open hits
are spread 9 ticks, land at 102-110, and ring until the next hit or the bar end.
Downbeats get a 5% accent. If your amp sim or library switches articulation by
note length or velocity this maps straight across; if it uses keyswitches, tell
me which library and I'll add them.
