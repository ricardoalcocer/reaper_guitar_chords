-- Every root x scale x rhythm x a spread of seeds must produce a sane riff:
-- events in velocity/length range, contained in the bar, on a plausible pitch,
-- strictly in the chosen scale, and with no string restruck before it stops.
-- The riff engine reuses strokeEvents, so a regression here means the same-string
-- gating or the scale maths drifted.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}

assert(G.makeRiff and G.buildRiffEvents and G.SCALES and G.POWER, 'riff engine not exposed')

local n, bad = 0, 0
local function fail(...) bad = bad + 1; print('FAIL', ...) end

local function inScale(scale, semis)
  local pc = semis % 12
  for _,x in ipairs(scale.iv) do if x==pc then return true end end
  return false
end

for _, root in ipairs(NAMES) do
  local rootBase = G.rootBaseOf(root)
  for _, scale in ipairs(G.SCALES) do
    for ri = 1, #G.POWER do
      for seed = 1, 6 do
        local riff = G.makeRiff(root, scale.key, ri, seed)
        local ev = G.buildRiffEvents(riff, rootBase, 4)
        if #ev == 0 then fail('no events', root, scale.key, G.POWER[ri].name) end
        table.sort(ev, function(a,b) return a.qn < b.qn end)
        local last = {}
        for _, e in ipairs(ev) do
          n = n + 1
          if e.vel < 1 or e.vel > 127 then fail('velocity', root, scale.key, e.vel) end
          if e.len <= 0 then fail('length', root, scale.key, e.len) end
          if e.qn < 0 or e.qn + e.len > 4.05 then
            fail('outside bar', root, scale.key, G.POWER[ri].name) end
          if e.pitch < 40 or e.pitch > 90 then fail('pitch', root, scale.key, e.pitch) end
          if not inScale(scale, e.pitch - rootBase) then
            fail('out of scale', root, scale.key, e.pitch - rootBase) end
          -- a string may not be restruck before its previous note ends
          if last[e.pitch] and e.qn < last[e.pitch] - 1e-6 then
            fail('same-string overlap', root, scale.key, G.POWER[ri].name, e.pitch) end
          last[e.pitch] = e.qn + e.len
        end
      end
    end
  end
end

print(string.format('%d riff events checked, %d problems', n, bad))
os.exit(bad == 0 and 0 or 1)
