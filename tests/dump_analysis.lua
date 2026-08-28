-- Dumps every analysis result so the JS port can be diffed against it.
local H = dofile('src/harmony.lua')
local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local QUALS = {'maj','m','7','m7','maj7','m7b5','dim7','dim','aug','sus2','sus4',
               '7sus4','6','m6','9','add9','5',
               'maj9','m9','m11','13','13sus4','9sus4','6/9','m6/9','add11','mMaj7','7alt'}
local out = {}
for key = 0, 11 do
  for _, mode in ipairs({'maj','min'}) do
    for chord = 0, 11 do
      for _, q in ipairs(QUALS) do
        local a = H.analyze(key, mode, chord, q)
        out[#out+1] = string.format('%d|%s|%d|%s|%s|%s', key, mode, chord, q, a.numeral, a.func)
      end
    end
  end
end
local f = io.open('build/lua_analysis.txt', 'w')
f:write(table.concat(out, '\n')) f:close()
print(#out .. ' results -> build/lua_analysis.txt')
