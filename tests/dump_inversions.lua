-- Dumps every inversion shape (root x quality x inv 0..3) from the Lua invertShape so the
-- JS port in src/web_template.html can be diffed against it byte-for-byte. Muted strings are
-- 'x', an absent shape is 'nil'. The search is deterministic, so the two must agree exactly.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
assert(G.invertShape and G.INV_QUALS and G.CHORDS, 'inversion engine not exposed')

local out = {}
for root, qs in pairs(G.CHORDS) do
  for q in pairs(qs) do
    for inv = 0, 3 do
      local shape = G.invertShape(root, q, inv)
      local s
      if shape then
        local t = {}
        for i = 1, 6 do t[i] = shape[i] and tostring(shape[i]) or 'x' end
        s = table.concat(t, ',')
      else
        s = 'nil'
      end
      out[#out+1] = string.format('%s|%s|%d|%s', root, q, inv, s)
    end
  end
end
table.sort(out)
local f = io.open('build/lua_inversions.txt', 'w')
f:write(table.concat(out, '\n')) f:close()
print(#out .. ' inversion shapes -> build/lua_inversions.txt')
