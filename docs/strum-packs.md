# Advanced Guitar MIDI Pack

Tempo 100 BPM (demo riff 140), 4/4, GM program 26 (steel acoustic).
All loops are exactly one bar and tile cleanly; progressions are four bars.

## 1_strum-loops/
One bar per chord, per pattern. Nine chords x six patterns.
Eighth-note grid, D = downstroke, U = upstroke, x = fret-hand mute:

  01_downs      D - D - D - D -        quarter notes, all downstrokes
  02_eighths    D U D U D U D U        constant eighths
  03_classic    D - D U - U D U        the standard folk/pop pattern
  04_pop        D - D U - U D -
  05_ghosted    D x D U x U D U        muted clicks fill the gaps
  06_offbeat    - U D U - U D U        starts on the & of 1

Downstrokes sweep low string to high (14 ticks apart), upstrokes sweep high to
low (9 ticks) and only catch the top four strings, which is what a hand actually
does. Bass strings are louder on downstrokes, the whole upstroke is quieter, and
beats 1 and 3 are accented. Notes ring until the next strum retriggers them.

## 2_progressions/
Am-F-C-G and Em-C-G-D, one bar per chord, in all six patterns.

## 3_palm-muted-chords/
The full chords reduced to their lowest three strings, straight eighths, notes
gated to ~42% length. This is palm muting on an open/barre chord shape.

## 4_power-chords/
All twelve roots, root-fifth-octave, lowest available position. Four articulations:

  _sustained          one ringing whole-bar hit
  _palmmute_8ths      straight eighth chugs
  _palmmute_gallop    eighth + two sixteenths, repeated (gallop)
  _mute-open          chugs with open accented hits on beats 2 and 4

## 5_demo/
E5-G5-A5-G5 palm-muted riff at 140 BPM.

## Notes for your sampler
Palm mutes here are written as short, high-velocity notes. Libraries that switch
articulation by note length or velocity will pick this up automatically. If yours
uses keyswitches instead (Ample, Shreddage, Kontakt libraries), the keyswitch
notes are not included - ask and I can add them for your specific library.
