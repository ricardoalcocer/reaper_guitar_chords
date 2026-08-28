-- The metronome's time-signature cycler is pure maths (nextTimeSig); the click itself
-- is REAPER's native metronome, driven from the UI section, so it isn't reachable here.
-- What we can pin down is the cycling: every preset advances to the next and the last
-- wraps to the first, and any meter that isn't a preset (e.g. one set in REAPER by hand)
-- falls back to the first rather than getting stuck.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP

assert(G.nextTimeSig and G.TIME_SIGS, 'metronome time-sig cycler not exposed')

local n, bad = 0, 0
local function fail(...) bad = bad + 1; print('FAIL', ...) end

local sigs = G.TIME_SIGS
assert(#sigs >= 2, 'need at least two presets to cycle')

-- each preset advances to the one after it; the last wraps back to the first
for i, ts in ipairs(sigs) do
  local expect = sigs[i % #sigs + 1]
  local gn, gd = G.nextTimeSig(ts[1], ts[2])
  n = n + 1
  if gn ~= expect[1] or gd ~= expect[2] then
    fail(('%d/%d -> %d/%d, expected %d/%d'):format(ts[1], ts[2], gn, gd, expect[1], expect[2]))
  end
end

-- a full trip round the ring returns to where it started
do
  local num, den = sigs[1][1], sigs[1][2]
  for _ = 1, #sigs do num, den = G.nextTimeSig(num, den) end
  n = n + 1
  if num ~= sigs[1][1] or den ~= sigs[1][2] then
    fail(('full cycle did not return to start: got %d/%d'):format(num, den))
  end
end

-- an off-list meter (set directly in REAPER) falls back to the first preset
do
  local gn, gd = G.nextTimeSig(9, 8)
  n = n + 1
  if gn ~= sigs[1][1] or gd ~= sigs[1][2] then
    fail(('off-list 9/8 -> %d/%d, expected fallback %d/%d'):format(gn, gd, sigs[1][1], sigs[1][2]))
  end
end

print(('test_metronome: %d checks, %d failed'):format(n, bad))
if bad > 0 then os.exit(1) end
