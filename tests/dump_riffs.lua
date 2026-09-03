-- Dumps every riff's generated line (scale x rhythm x seed) so the JS port can be diffed
-- against it. The line is root-independent (root only affects fretFor), so we fix root='E'.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
assert(G.makeRiff and G.SCALES and G.POWER, 'riff engine not exposed')

local SEEDS = 8
local out = {}
for _, sc in ipairs(G.SCALES) do
  for ri = 1, #G.POWER do
    for seed = 1, SEEDS do
      local r = G.makeRiff('E', sc.key, ri, seed)
      local parts = {}
      for i = 1, #r.steps do
        local st = r.steps[i]
        parts[i] = st and (st.iv .. ':' .. tostring(st.art)) or '.'
      end
      out[#out+1] = string.format('%s|%d|%d|%s', sc.key, ri, seed, table.concat(parts, ','))
    end
  end
end
local f = io.open('build/lua_riffs.txt', 'w')
f:write(table.concat(out, '\n')) f:close()
print(#out .. ' riff lines -> build/lua_riffs.txt')
