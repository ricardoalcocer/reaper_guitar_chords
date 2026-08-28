-- Analysis must resolve for every chord in every key, with no gaps.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local pc = {} for i,n in ipairs(NAMES) do pc[n] = i-1 end

local n, bad = 0, 0
for key = 0, 11 do
  for _, mode in ipairs({'maj','min'}) do
    for root, qs in pairs(G.CHORDS) do
      for q in pairs(qs) do
        local a = G.analyze(key, mode, pc[root], q)
        n = n + 1
        if not a.numeral or a.numeral == '' or not a.func or a.func == '' then
          bad = bad + 1
          print('FAIL empty analysis', NAMES[key+1], mode, root, q)
        end
      end
    end
    -- the seven diatonic chords must all be distinct degrees
    local seen = {}
    for _, dc in ipairs(G.diatonicChords(key, mode, false)) do
      if seen[dc.pc] then bad = bad + 1; print('FAIL duplicate degree', NAMES[key+1], mode) end
      seen[dc.pc] = true
    end
  end
end
print(string.format('%d analyses checked, %d problems', n, bad))
os.exit(bad == 0 and 0 or 1)
