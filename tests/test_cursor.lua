-- The play/insert cursor: "+ Add to Song" drops a block at S.cursor (not always the end),
-- then advances the cursor past it so adds stack. This checks that insert-at-cursor logic.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
assert(G.addToSong and G.S and G.songLen, 'cursor test needs addToSong/S/songLen exposed')

local S = G.S
local bad = 0
local function eq(got, want, msg) if got ~= want then bad = bad + 1; print('FAIL', msg, 'got', got, 'want', want) end end

S.song = {}; S.cursor = 0
G.addToSong('chord')                       -- drops at bar 0 (bar 1)
eq(S.song[1].startBar, 0, 'first add at cursor 0')
eq(S.cursor, S.song[1].bars, 'cursor advanced past block 1')

G.addToSong('chord')                       -- appends after (cursor tracked the end)
eq(S.song[2].startBar, S.song[1].bars, 'second add stacks after the first')

local endBar = G.songLen()
S.cursor = 1                               -- move the cursor back to bar 2
G.addToSong('chord')                       -- must insert AT bar 1, not at the end
eq(S.song[3].startBar, 1, 'insert lands at the cursor, not the end')
eq(S.cursor, 1 + S.song[3].bars, 'cursor advanced from the insert point')

-- gap placement: cursor past the end drops a block there, leaving a gap
S.cursor = endBar + 3
G.addToSong('chord')
eq(S.song[4].startBar, endBar + 3, 'block can be placed past the end (gap)')

print(bad == 0 and ('cursor: all checks passed ('..#S.song..' blocks placed)') or (bad..' FAILURES'))
os.exit(bad == 0 and 0 or 1)
