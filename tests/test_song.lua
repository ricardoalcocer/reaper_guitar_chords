-- The arrangement engine must place every block correctly and never emit a bad bar.
-- A block reuses the same generators the tabs use, so this guards the *assembly*:
-- each block tiles across its stretched length, gaps stay empty, and every rendered
-- bar still satisfies the event invariants (velocity, length, containment, pitch,
-- and no string restruck before it stops — within a single block's bars).
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}

assert(G.renderSongBars and G.songLen and G.S and G.SCALES and G.POWER, 'song engine not exposed')

local n, bad, BQN = 0, 0, 4
local function fail(...) bad = bad + 1; print('FAIL', ...) end

local function checkBar(evlist, tag)
  table.sort(evlist, function(a,b) return a.qn < b.qn end)
  local last = {}
  for _, e in ipairs(evlist) do
    n = n + 1
    if e.vel < 1 or e.vel > 127 then fail('velocity', tag, e.vel) end
    if e.len <= 0 then fail('length', tag, e.len) end
    if e.qn < 0 or e.qn + e.len > BQN + 0.05 then fail('outside bar', tag, e.qn, e.len) end
    if e.pitch < 40 or e.pitch > 90 then fail('pitch', tag, e.pitch) end
    if last[e.pitch] and e.qn < last[e.pitch] - 1e-6 then fail('same-string overlap', tag, e.pitch) end
    last[e.pitch] = e.qn + e.len
  end
end

-- render one block as a one-block song and verify placement + every rendered bar
local function checkBlock(b, tag)
  G.S.song = {b}
  local bars = G.renderSongBars(BQN)
  if G.songLen() ~= b.startBar + b.bars then fail('songLen', tag) end
  if #bars ~= b.startBar + b.bars then fail('bar count', tag) end
  for i = 1, b.startBar do
    if #bars[i] ~= 0 then fail('gap not empty', tag, i) end
  end
  for i = b.startBar + 1, b.startBar + b.bars do
    if #bars[i] == 0 then fail('empty block bar', tag, i) end
    checkBar(bars[i], tag .. ' bar' .. i)
  end
end

for _, root in ipairs(NAMES) do
  for _, q in ipairs({'maj','m','7','m7','5','sus4'}) do
    checkBlock({kind='chord', startBar=2, bars=3, g={root=root, qual=q, strumIdx=7}},
               'chord ' .. root .. q)
  end
  for pi = 1, #G.POWER do
    checkBlock({kind='power', startBar=0, bars=2, g={proot=root, three=true, powerIdx=pi}},
               'power ' .. root)
  end
  for _, sc in ipairs(G.SCALES) do
    checkBlock({kind='riff', startBar=1, bars=3, g={rroot=root, scale=sc.key, rhythmIdx=4, riffSeed=5}},
               'riff ' .. root .. sc.key)
  end
end

for pi, p in ipairs(G.PROGS.progressions) do
  for key = 0, 11, 4 do
    checkBlock({kind='prog', startBar=0, bars=#p.chords,
                g={prog=p, keyPC=key, keyMode='min', strumIdx=1}}, 'prog ' .. pi)
  end
end

-- a mixed arrangement laid end to end: every non-empty bar must still be sane
G.S.song = {
  {kind='power', startBar=0, bars=2, g={proot='E', three=false, powerIdx=4}},
  {kind='riff',  startBar=2, bars=2, g={rroot='E', scale='phrygian', rhythmIdx=3, riffSeed=1}},
  {kind='chord', startBar=4, bars=1, g={root='A', qual='m7', strumIdx=6}},
  {kind='prog',  startBar=5, bars=#G.PROGS.progressions[1].chords,
                 g={prog=G.PROGS.progressions[1], keyPC=0, keyMode='min', strumIdx=1}},
}
do
  local bars = G.renderSongBars(BQN)
  if #bars < 6 then fail('mixed song too short', #bars) end
  for i, ev in ipairs(bars) do if #ev > 0 then checkBar(ev, 'mixed bar' .. i) end end
end

print(string.format('%d song events checked, %d problems', n, bad))
os.exit(bad == 0 and 0 or 1)
