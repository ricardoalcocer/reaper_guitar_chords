-- Song favorites round-trip: serializing an arrangement to a string and back must preserve it,
-- so a saved favorite reloads to the exact same MIDI. We check the deserialized song renders
-- (renderSongBars) to byte-identical events as the original, for one block of every kind.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
assert(G.songSerialize and G.songDeserialize and G.renderSongBars, 'song favorites not exposed')

local original = {
  {kind='chord', startBar=0, bars=1, label='Cm9', g={root='C', qual='m9', strumIdx=1}},
  {kind='power', startBar=1, bars=2, label='E5',  g={proot='E', three=true, powerIdx=4}},
  {kind='riff',  startBar=3, bars=1, label='A riff', g={rroot='A', scale='phrygian', rhythmIdx=4, riffSeed=3}},
  {kind='prog',  startBar=4, bars=2, label='Test', g={prog={name='Test', chords={{0,'maj'},{7,'maj'},{9,'m'}}},
                 keyPC=0, keyMode='maj', strumIdx=1}},
}

local function renderOf(song) G.S.song = song; return G.renderSongBars(4) end

G.S.song = original
local wire = G.songSerialize()
local back  = G.songDeserialize(wire)

local bad = 0
local function ok(c,m) if not c then bad=bad+1; print('FAIL: '..m) end end

ok(#back == #original, 'block count preserved ('..#back..' vs '..#original..')')
for i,b in ipairs(back) do
  local o = original[i]
  ok(b.kind==o.kind and b.startBar==o.startBar and b.bars==o.bars,
     'block '..i..' header preserved ('..tostring(b.kind)..')')
end

-- the strongest check: same rendered MIDI events before and after the round-trip
local a, c = renderOf(original), renderOf(back)
ok(#a == #c, 'same bar count rendered ('..#a..' vs '..#c..')')
for bar=1,math.min(#a,#c) do
  ok(#a[bar] == #c[bar], 'bar '..bar..' event count matches')
  for k=1,math.min(#a[bar],#c[bar]) do
    local e1, e2 = a[bar][k], c[bar][k]
    ok(e1.pitch==e2.pitch and e1.vel==e2.vel
       and math.abs(e1.qn-e2.qn)<1e-9 and math.abs(e1.len-e2.len)<1e-9,
       'bar '..bar..' note '..k..' identical')
  end
end

print('song favorites: ' .. (bad==0 and 'round-trip preserves the arrangement' or bad..' FAILURES'))
os.exit(bad==0 and 0 or 1)
