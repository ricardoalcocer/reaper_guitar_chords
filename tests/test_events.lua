-- Every chord x every articulation must produce sane MIDI events.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP

local n, bad = 0, 0
local function fail(...) bad = bad + 1; print('FAIL', ...) end

for root, qs in pairs(G.CHORDS) do
  for q, d in pairs(qs) do
    for _, art in ipairs(G.STRUM) do
      local ev = G.buildEvents(d.frets, art, 4)
      if #ev == 0 then fail('no events', root, q, art.name) end
      local last = {}
      table.sort(ev, function(a,b) return a.qn < b.qn end)
      for _, e in ipairs(ev) do
        n = n + 1
        if e.vel < 1 or e.vel > 127 then fail('velocity', root, q, e.vel) end
        if e.len <= 0 then fail('length', root, q, e.len) end
        if e.qn < 0 or e.qn + e.len > 4.05 then fail('outside bar', root, q, art.name) end
        if e.pitch < 40 or e.pitch > 90 then fail('pitch', root, q, e.pitch) end
        -- a string may not be restruck before its previous note ends
        if last[e.pitch] and e.qn < last[e.pitch] - 1e-6 then
          fail('same-string overlap', root, q, art.name, e.pitch)
        end
        last[e.pitch] = e.qn + e.len
      end
    end
  end
end

for _, art in ipairs(G.POWER) do
  for _, three in ipairs({true, false}) do
    local ev = G.buildEvents(G.powerChord('E', three), art, 4)
    if #ev == 0 then fail('no events', 'E5', art.name) end
    n = n + #ev
  end
end

print(string.format('%d events checked, %d problems', n, bad))
os.exit(bad == 0 and 0 or 1)
