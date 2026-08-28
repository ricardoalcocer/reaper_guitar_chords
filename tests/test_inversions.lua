-- Inversions must be REAL, hand-playable shapes: the requested chord tone in the
-- bass, every essential tone still sounding, a span/finger count a hand can reach,
-- and sane MIDI events (incl. no unison). invertShape returns nil where no clean
-- shape exists; those are simply not offered. This test also prints coverage.
_G.GCP_TEST = true
reaper = {GetCursorPosition=function() return 0 end,
  TimeMap_GetTimeSigAtTime=function() return 4,4 end,
  Master_GetTempo=function() return 120 end, time_precise=function() return 0 end,
  StuffMIDIMessage=function() end, defer=function() end, atexit=function() end}
gfx = setmetatable({}, {__index=function() return function() end end})
dofile('reaper/GuitarChordPack.lua')
local G = _G.GCP
local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local OPEN = {40,45,50,55,59,64}

assert(G.invertShape and G.INV_QUALS and G.CHORDS, 'inversion engine not exposed')

local n, bad, found, tried = 0, 0, 0, 0
local function fail(...) bad = bad + 1; print('FAIL', ...) end
local function pcOf(nm) for i,x in ipairs(NAMES) do if x==nm then return i-1 end end end

local function pitches(frets)
  local t = {} for i=1,6 do if frets[i] then t[#t+1]=OPEN[i]+frets[i] end end return t
end
-- distinct chord-tone intervals of the stored voicing, ascending (root first)
local function baseIvs(frets, rootPc)
  local seen, ivs = {}, {}
  for _,p in ipairs(pitches(frets)) do
    local iv=(p-rootPc)%12; if not seen[iv] then seen[iv]=true; ivs[#ivs+1]=iv end
  end
  table.sort(ivs); return ivs
end

for root, qs in pairs(G.CHORDS) do
  for q in pairs(qs) do
    if G.INV_QUALS[q] then
      local rootPc = pcOf(root)
      local base = G.CHORDS[root][q].frets
      local ivs = baseIvs(base, rootPc)
      for inv = 1, 3 do
        tried = tried + 1
        local shape = G.invertShape(root, q, inv)
        if shape then
          found = found + 1
          local ps = pitches(shape)
          -- bass note is the inv-th chord tone
          local lo = ps[1]; for _,p in ipairs(ps) do if p < lo then lo = p end end
          local tgt = ivs[inv+1]
          if tgt and (lo - rootPc) % 12 ~= tgt then
            fail('bass not the target tone', root, q, inv, (lo-rootPc)%12, 'want', tgt)
          end
          -- span <= 4 and <= 4 distinct fretted positions (barre = one finger)
          local hi, low, fg = 0, 99, {}
          for i=1,6 do local f=shape[i]
            if f and f>0 then if f>hi then hi=f end; if f<low then low=f end; fg[f]=true end end
          local nf=0; for _ in pairs(fg) do nf=nf+1 end
          if hi>0 and (hi-low>4 or nf>4) then fail('not playable', root, q, inv, 'span', hi-low, 'fingers', nf) end
          -- essential tones (5th may drop unless it is the bass) all present
          local have={} for _,p in ipairs(ps) do have[(p-rootPc)%12]=true end
          for _,iv in ipairs(ivs) do
            local isFifth = (iv==6 or iv==7 or iv==8)
            if not have[iv] and not (isFifth and iv ~= tgt) then
              fail('missing tone', root, q, inv, iv)
            end
          end
          -- and it builds sane events with no unison / same-string overlap
          local ev = G.buildEvents(shape, G.STRUM[1], 4)
          if #ev == 0 then fail('no events', root, q, inv) end
          table.sort(ev, function(a,b) return a.qn < b.qn end)
          local last = {}
          for _, e in ipairs(ev) do
            n = n + 1
            if e.vel<1 or e.vel>127 then fail('velocity', root, q, e.vel) end
            if e.len<=0 then fail('length', root, q) end
            if e.pitch<40 or e.pitch>90 then fail('pitch', root, q, e.pitch) end
            if last[e.pitch] and e.qn < last[e.pitch]-1e-6 then fail('unison/overlap', root, q, inv, e.pitch) end
            last[e.pitch] = e.qn + e.len
          end
        end
      end
    end
  end
end

print(string.format('%d inversion events checked, %d problems', n, bad))
print(string.format('coverage: %d of %d requested inversions have a playable shape (%.0f%%)',
                    found, tried, 100*found/tried))
os.exit(bad == 0 and 0 or 1)
