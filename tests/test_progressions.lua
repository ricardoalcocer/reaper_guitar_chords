-- Every shipped progression must resolve to real voicings in all 12 keys, and
-- every resulting chord must build sane MIDI events. A progression that names a
-- chord quality the pack doesn't voice would strand the user with a dead button.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}

assert(G.PROGS and G.PROGS.progressions, 'PROGS not exposed')
local nprog, nchord, bad = 0, 0, 0
local function fail(...) bad = bad + 1; print('FAIL', ...) end

-- every mood chip must map to at least one progression
for _, mood in ipairs(G.PROGS.moods) do
  local any = false
  for _, p in ipairs(G.PROGS.progressions) do if p.mood == mood then any = true break end end
  if not any then fail('empty mood', mood) end
end

for _, p in ipairs(G.PROGS.progressions) do
  nprog = nprog + 1
  if #p.chords < 2 then fail('too short', p.mood, p.name) end
  for start = 0, 11 do
    for _, c in ipairs(p.chords) do
      nchord = nchord + 1
      local root = NAMES[(start + c[1]) % 12 + 1]
      local v = G.CHORDS[root][c[2]]
      if not v then
        fail('unvoiced', p.mood, p.name, root, c[2])
      else
        -- the default strum must yield playable events for this voicing
        local ev = G.buildEvents(v.frets, G.STRUM[1], 4)
        if #ev == 0 then fail('no events', root, c[2]) end
      end
    end
  end
end

print(string.format('%d progressions, %d chord instances checked, %d problems',
                    nprog, nchord, bad))
os.exit(bad == 0 and 0 or 1)
