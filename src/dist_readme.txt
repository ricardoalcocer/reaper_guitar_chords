Guitar Songwriter {VERSION}
==========================

Chords that sound like a guitar: audition real fretboard voicings, progressions
and riffs through your own guitar VSTi, arrange them, and drop the MIDI into
REAPER at the cursor.

What's in this folder
---------------------
  GuitarChordPack.lua    the REAPER script (one file, no extensions needed)
  guitar-audition.html   the same tool in your browser, with a built-in synth.
                         Double-click to open; works offline.
  LICENSE                MIT

Install in REAPER
-----------------
1. Move GuitarChordPack.lua somewhere permanent. REAPER's Scripts folder is a
   good home (Options > Show REAPER resource path... > Scripts).
2. Actions > Show action list > New action > Load ReaScript...
   and choose GuitarChordPack.lua.
3. Select it in the action list and click Run. Tip: give it a shortcut or a
   toolbar button while you're there.

First steps
-----------
1. Select a track that has your guitar VSTi on it.
2. Press Tab (or click "Set up track"). This arms the track, turns on input
   monitoring and sets its input to MIDI, which REAPER needs before it will
   play the audition. If it's still silent, the status bar says why.
3. Press space to audition. Change root / quality / strum, then
   "Send to REAPER" to insert the MIDI at the edit cursor.
4. The home row keys a s d f g h j play the seven chords of the current key,
   so you can hold a chord and sing over it.

Updating
--------
Download the new zip and replace GuitarChordPack.lua with the new one. If the
script window is open, close it and run the action again.

More
----
Full guide, source and latest version:
  https://github.com/ricardoalcocer/reaper_guitar_chords
Browser version online:
  https://alco.rocks/guitar-songwriter
