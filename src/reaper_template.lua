--[[
  Guitar Chord Pack - audition and insert
  @description Browse guitar-voiced chords, audition them through the selected
               track's instrument, and insert them as MIDI at the edit cursor.
  @author generated for REAPER, no extensions required
  @version __VERSION__
--]]

local VERSION = "__VERSION__"

----------------------------------------------------------------------
-- data
----------------------------------------------------------------------
local CHORDS = --[[CHORD_DATA]]
local PROGS = --[[PROG_DATA]]

local OPEN   = {40,45,50,55,59,64}                    -- low E -> high E
local NAMES  = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local ROOTS  = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local QUALS  = {'maj','m','7','m7','maj7','m7b5','dim7','dim','aug',
                'sus2','sus4','7sus4','6','m6','9','add9'}

-- strum patterns: 8 eighth-note slots
local STRUM = {
  {name='single down',  single='D'},
  {name='single up',    single='U'},
  {name='palm mute hit',single='P'},
  {name='arpeggio',     single='A'},
  {name='downs',    p={'D',0,'D',0,'D',0,'D',0}, div=2},
  {name='eighths',  p={'D','U','D','U','D','U','D','U'}, div=2},
  {name='classic',  p={'D',0,'D','U',0,'U','D','U'}, div=2},
  {name='pop',      p={'D',0,'D','U',0,'U','D',0}, div=2},
  {name='ghosted',  p={'D','x','D','U','x','U','D','U'}, div=2},
  {name='offbeat',  p={0,'U','D','U',0,'U','D','U'}, div=2},
}

local function rep4(t)
  local o={} for i=1,4 do for _,v in ipairs(t) do o[#o+1]=v end end return o
end
local POWER = {
  {name='sustained',      p={'D',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, div=4},
  {name='chug 8ths',      p=rep4{'P',0,'P',0}, div=4},
  {name='chug 16ths',     p=rep4{'P','P','P','P'}, div=4},
  {name='gallop',         p=rep4{'P',0,'P','P'}, div=4},
  {name='reverse gallop', p=rep4{'P','P',0,'P'}, div=4},
  {name='stutter',        p=rep4{'P','P',0,0}, div=4},
  {name='triplets',       p={'P','P','P','P','P','P','P','P','P','P','P','P'}, div=3},
  {name='syncopated',     p={'P',0,'P','P',0,0,'P',0,'P',0,'P','P',0,0,'P',0}, div=4},
  {name='push',           p={'P',0,0,0,0,0,'P','P',0,0,'P',0,0,0,'P',0}, div=4},
  {name='offbeat',        p=rep4{'P',0,'D',0}, div=4},
  {name='open accents',   p={'P',0,'P',0,'D',0,'P',0,'P',0,'P',0,'D',0,'P',0}, div=4},
  {name='ring and chug',  p={'D',0,0,0,0,0,0,0,'P',0,'P',0,'P',0,'P',0}, div=4},
  {name='ghosted chug',   p=rep4{'P','x','P','x'}, div=4},
}

----------------------------------------------------------------------
-- functional harmony
----------------------------------------------------------------------
--[[HARMONY]]

----------------------------------------------------------------------
-- voicings
----------------------------------------------------------------------
local function pcOf(name)
  for i,n in ipairs(NAMES) do if n==name then return i-1 end end
  return 0
end

local function powerChord(root, three)
  local pc for i,n in ipairs(NAMES) do if n==root then pc=i-1 end end
  local best
  for _,v in ipairs({{4,1},{9,2}}) do
    local f = (pc - v[1]) % 12
    if not best or f < best.f then
      local fr = {false,false,false,false,false,false}
      fr[v[2]] = f; fr[v[2]+1] = f+2
      if three then fr[v[2]+2] = f+2 end
      best = {f=f, fr=fr}
    end
  end
  return best.fr
end

local function pitchesOf(frets)
  local t = {}
  for i=1,6 do if frets[i] then t[#t+1] = {str=i, pitch=OPEN[i]+frets[i]} end end
  return t
end

local function noteNames(frets)
  local s = {}
  for _,n in ipairs(pitchesOf(frets)) do
    s[#s+1] = NAMES[n.pitch % 12 + 1] .. math.floor(n.pitch/12) - 1
  end
  return table.concat(s, ' ')
end

----------------------------------------------------------------------
-- chord inversions as REAL, hand-playable fret shapes. We search for a voicing
-- with the 3rd/5th/7th in the bass; only shapes a hand can actually grab are kept
-- (span <= 4 frets, <= 4 fingers counting a barre once), and the search returns
-- nil when none exists, so the UI never offers an unplayable inversion.
----------------------------------------------------------------------
local INV_QUALS = {         -- qualities we offer inversions for (standard triads + 7ths)
  maj=true, m=true, ['7']=true, m7=true, maj7=true, ['6']=true, m6=true,
  dim=true, aug=true, m7b5=true, dim7=true, mMaj7=true,
}
local FIFTHS = { [6]=true, [7]=true, [8]=true }    -- dim / perfect / aug 5th intervals

-- a hand can reach it: fretted span within 4, and no more than four fingers
-- (strings sharing a fret are one barre finger)
local function playableShape(frets)
  local hi, lo, fingers, n = 0, 99, {}, 0
  for i=1,6 do local f=frets[i]
    if f and f>0 then
      if f>hi then hi=f end; if f<lo then lo=f end
      if not fingers[f] then fingers[f]=true; n=n+1 end
    end
  end
  if hi==0 then return true end
  return (hi-lo <= 4) and (n <= 4)
end

-- best playable shape whose lowest note is `bassPc` and which sounds every pc in
-- needList; nil if none. Bass sits on strings 1..4, higher strings within a hand span.
local function searchInversion(rootPc, needList, bassPc)
  local need = {}; for _,pc in ipairs(needList) do need[pc]=true end
  local best
  local frets = {false,false,false,false,false,false}
  for bs=1,4 do
    for fb=0,12 do
      if (OPEN[bs]+fb)%12 == bassPc then
        local bassPitch = OPEN[bs]+fb
        for i=1,6 do frets[i]=false end
        frets[bs]=fb
        local function rec(str)
          if str>6 then
            local have, hi, sounding = {}, 0, 0
            for i=1,6 do if frets[i] then
              local p=OPEN[i]+frets[i]; have[p%12]=true; sounding=sounding+1
              if frets[i]>hi then hi=frets[i] end
            end end
            for _,pc in ipairs(needList) do if not have[pc] then return end end
            if not playableShape(frets) then return end
            local score = sounding*100 - hi*4       -- fuller and lower scores higher
            if not best or score>best.score then
              local c={}; for i=1,6 do c[i]=frets[i] end
              best = {frets=c, score=score}
            end
            return
          end
          frets[str]=false; rec(str+1)              -- mute this string
          for f=0,14 do                             -- or a chord tone above the bass
            local pitch=OPEN[str]+f
            if need[pitch%12] and pitch>bassPitch
               and (f==0 or (f>=fb-1 and f<=fb+4)) then
              local dup=false
              for i=1,str-1 do if frets[i] and OPEN[i]+frets[i]==pitch then dup=true; break end end
              if not dup then frets[str]=f; rec(str+1); frets[str]=false end
            end
          end
        end
        rec(bs+1)
      end
    end
  end
  return best and best.frets or nil
end

-- inv 0 = root position (the stored shape). 1/2/3 put the 3rd/5th/7th in the bass;
-- returns nil when no playable shape exists. Cached, since currentFrets runs each frame.
local _invCache = {}
local function invertShape(root, qual, inv)
  if inv==0 or not INV_QUALS[qual] then return CHORDS[root][qual].frets end
  local key = root..'|'..qual..'|'..inv
  local c = _invCache[key]
  if c ~= nil then return c or nil end
  local base, rootPc = CHORDS[root][qual].frets, pcOf(root)
  local seen, ivs = {}, {}
  for i=1,6 do if base[i] then
    local pc=(OPEN[i]+base[i])%12
    if not seen[pc] then seen[pc]=true; ivs[#ivs+1]=(pc-rootPc)%12 end
  end end
  table.sort(ivs)
  local tgtIv = ivs[inv+1]                          -- inv-th chord tone becomes the bass
  if not tgtIv then _invCache[key]=false; return nil end
  local bassPc = (rootPc+tgtIv)%12
  -- required tones: every chord tone, but the 5th may drop unless it is the bass
  local needList, added = {}, {}
  for i=1,6 do if base[i] then
    local pc=(OPEN[i]+base[i])%12
    if (pc==bassPc or not FIFTHS[(pc-rootPc)%12]) and not added[pc] then
      added[pc]=true; needList[#needList+1]=pc
    end
  end end
  local shape = searchInversion(rootPc, needList, bassPc)
  _invCache[key] = shape or false
  return shape
end

----------------------------------------------------------------------
-- event building: identical spreads / velocities / gates to the MIDI pack
----------------------------------------------------------------------
local SPREAD = {D=14/480, U=9/480, P=4/480, x=10/480}

local function strokeEvents(frets, kind, atQN, stepQN, barQN, nextQN, evs)
  local notes = pitchesOf(frets)
  local order, byString, posVels, gate = notes, nil, nil, nil
  local cutoff = (nextQN or barQN)
  if kind=='D' then
    byString = {96,92,88,85,82,88}          -- indexed by string: bass louder
    gate = stepQN*4; cutoff = cutoff - 0.0125
  elseif kind=='U' then
    order = {}
    for i=#notes, math.max(1,#notes-3), -1 do order[#order+1]=notes[i] end
    posVels = {78,74,72,70}                 -- by stroke order: the sweep fades
    gate = stepQN*3; cutoff = cutoff - 0.0125
  elseif kind=='x' then
    byString = {46,44,42,40,38,40}
    gate = 0.125
  else -- palm mute
    byString = {104,100,96,92,88,88}
    gate = stepQN * 0.42
  end
  local sp = SPREAD[kind] or SPREAD.D
  local accent = (math.abs(atQN % 1) < 0.001) and 1.05 or 1.0
  for i,n in ipairs(order) do
    local base = byString and byString[n.str] or posVels[i] or 70
    local st = atQN + (i-1)*sp
    local ln = math.min(gate, cutoff - st)   -- clamp per note, from its own start
    if ln < 0.03 then ln = 0.03 end
    evs[#evs+1] = {qn = st, len = ln, pitch = n.pitch,
                   vel = math.floor(math.min(127, base*accent)), str = n.str}
  end
end

-- returns a list of {qn,len,pitch,vel,str} covering one bar
local function buildEvents(frets, art, barQN)
  local evs = {}
  if art.single then
    if art.single=='A' then                      -- arpeggio, one note per eighth
      local i = 0
      for _,n in ipairs(pitchesOf(frets)) do
        evs[#evs+1] = {qn=i*0.5, len=barQN-i*0.5, pitch=n.pitch, vel=86, str=n.str}
        i = i + 1
      end
    else
      strokeEvents(frets, art.single, 0, barQN, barQN, barQN, evs)
    end
    return evs
  end
  local slots = #art.p
  local stepQN = barQN / slots
  for i=1,slots do
    if art.p[i] ~= 0 then
      local nextQN
      for j=i+1,slots do if art.p[j] ~= 0 then nextQN = (j-1)*stepQN break end end
      strokeEvents(frets, art.p[i], (i-1)*stepQN, stepQN, barQN, nextQN, evs)
    end
  end
  return evs
end

----------------------------------------------------------------------
-- riff engine: procedural single-note lines over a scale (metal chug MVP)
-- A riff reuses the whole articulation engine: each rhythm slot is one tiny
-- fret shape (a single low note) strummed with P/D/x, so the palm-mute gating,
-- velocity-by-string and no-same-string-overlap logic all carry over unchanged.
----------------------------------------------------------------------
-- scales as interval sets above the pedal root, low to high within one octave.
-- Metal chugs live in these: the ♭2 is the Phrygian bite, the natural 3 turns it
-- Phrygian-dominant (the "Spanish"/neoclassical colour), Aeolian is plain minor.
local SCALES = {
  {key='phrygian', name='Phrygian',     iv={0,1,3,5,7,8,10}},
  {key='phrygdom', name='Phrygian dom', iv={0,1,4,5,7,8,10}},
  {key='aeolian',  name='Aeolian',      iv={0,2,3,5,7,8,10}},
}

-- deterministic PRNG (Park-Miller). Seeded so audition, insert, export and the
-- tests all reproduce the same line for a given (root, scale, rhythm, seed);
-- the Re-roll button just advances the seed.
local function lcg(seed)
  local s = seed % 2147483647
  if s <= 0 then s = s + 2147483646 end
  return function()
    s = (s * 16807) % 2147483647
    return s / 2147483647
  end
end

-- interval for the idx-th scale step, wrapping cleanly into higher octaves
local function scaleStep(iv, idx)
  return iv[idx % #iv + 1] + 12 * (idx // #iv)
end

-- one bar of steps: steps[i] is false (rest) or {iv=semitones-above-root, art}.
-- The line pedals the root and wanders the scale in small steps, capped at the
-- octave so it stays a low riff, not a lead. Beat 1 always lands on the root,
-- and downbeats fall home half the time, which is what makes it read as a groove.
local function generateRiff(iv, rhythm, rng)
  local steps, cur = {}, 0
  local moves = {-2,-1,1,1,2}
  for i=1,#rhythm.p do
    local k = rhythm.p[i]
    if k == 0 then
      steps[i] = false
    else
      local onBeat = (i-1) % rhythm.div == 0
      if i == 1 or (onBeat and rng() < 0.5) then
        cur = 0                                    -- anchor the pulse on the root
      else
        cur = cur + moves[math.floor(rng() * #moves) + 1]
        if cur < 0 then cur = 0 end
        if cur > #iv then cur = #iv end            -- cap at the octave
      end
      steps[i] = {iv = scaleStep(iv, cur), art = k}
    end
  end
  return steps
end

-- lowest string that can fret this pitch within a hand span; favours low strings
-- so the line sits in the chunky register a riff wants
local function fretFor(pitch)
  for s=1,6 do
    local f = pitch - OPEN[s]
    if f >= 0 and f <= 15 then
      local fr = {false,false,false,false,false,false}
      fr[s] = f
      return fr
    end
  end
  local fr = {false,false,false,false,false,false}
  fr[6] = pitch - OPEN[6]
  return fr
end

-- the pedal-root pitch on the low string for a root name (low-E-string region)
local function rootBaseOf(root)
  return 40 + ((pcOf(root) - 4) % 12)
end

-- render a bar of riff steps to events, reusing strokeEvents once per step
local function buildRiffEvents(riff, rootBase, barQN)
  local slots = #riff.rhythm.p
  local stepQN = barQN / slots
  local evs = {}
  for i=1,slots do
    local st = riff.steps[i]
    if st then
      local frets = fretFor(rootBase + st.iv)
      local nextQN
      for j=i+1,slots do if riff.steps[j] then nextQN = (j-1)*stepQN break end end
      strokeEvents(frets, st.art, (i-1)*stepQN, stepQN, barQN, nextQN, evs)
    end
  end
  return evs
end

-- assemble a riff from selections; also the tests' entry point. Folds the whole
-- selection into the seed so different picks differ even at seed 1.
local function makeRiff(root, scaleKey, rhythmIdx, seed)
  local scale = SCALES[1]
  for _,s in ipairs(SCALES) do if s.key==scaleKey then scale=s end end
  local mixed = seed*1009 + rhythmIdx*31
  for i,s in ipairs(SCALES) do if s==scale then mixed = mixed + i*7 end end
  local rhythm = POWER[rhythmIdx]
  return {rhythm=rhythm, scale=scale, steps=generateRiff(scale.iv, rhythm, lcg(mixed))}
end

----------------------------------------------------------------------
-- state
----------------------------------------------------------------------
local S = {
  tab      = 1,            -- 1 chords, 2 power, 3 progressions, 4 riffs
  root     = 'A',
  qual     = 'm7',
  inv      = 0,            -- chord inversion: 0 root position, 1/2/3 = 3rd/5th/7th in bass
  proot    = 'E',
  three    = false,
  strumIdx = 1,
  powerIdx = 4,
  rroot    = 'E',          -- riff pedal root
  scale    = 'phrygian',   -- riff scale
  rhythmIdx = 4,           -- riff rhythm (index into POWER); 4 = gallop
  riffSeed = 1,            -- procedural seed; Re-roll advances it
  loop     = true,
  keyPC    = 0,            -- C
  keyMode  = 'maj',
  sevenths = false,
  mood     = PROGS.moods[1],   -- selected progression category
  progSel  = 1,                -- index into the filtered progression list
  progScroll = 0,              -- first visible row in that list
  song     = {},               -- the arrangement: an ordered list of blocks
  songSel  = nil,              -- index of the selected block
  songScroll = 0,              -- first visible bar in the timeline lane
  status   = 'Select your guitar track, press Tab to set it up, then Audition (space) — or play a s d f g h j to sing along.',
}

-- the Song/arranger feature is parked: its engine, tests and UI all stay in place,
-- but the tab and its "Add to Song" button are hidden until this is flipped back on.
local SONG_ENABLED = false

-- progressions filtered to the chosen mood, in library order
local function progList()
  local out = {}
  for _,p in ipairs(PROGS.progressions) do
    if p.mood == S.mood then out[#out+1] = p end
  end
  return out
end
local function currentProg()
  local list = progList()
  return list[math.min(S.progSel, #list)] or list[1]
end
-- a progression rendered in a given key: list of {root,qual,label,frets,deg}
local function progChordsIn(p, keyPC)
  local out = {}
  for _,c in ipairs(p.chords) do
    local root = NAMES[(keyPC + c[1]) % 12 + 1]
    local v = CHORDS[root][c[2]]
    out[#out+1] = {root=root, qual=c[2], label=v.label, frets=v.frets, deg=c[1]}
  end
  return out
end
local function progChords(p) return progChordsIn(p, S.keyPC) end

local function barQN()
  local pos = reaper.GetCursorPosition()
  local num, den = reaper.TimeMap_GetTimeSigAtTime(0, pos)
  if not num or num == 0 then num, den = 4, 4 end
  return num * (4/den)
end
local function tempo() return reaper.Master_GetTempo() end

-- the chord voicing for the Chords tab, with the selected inversion applied
-- (falls back to root position if that inversion has no playable shape)
local function chordFrets()
  return invertShape(S.root, S.qual, S.inv) or CHORDS[S.root][S.qual].frets
end
-- the sequence of frets audition/insert will lay out, one chord per bar
local function sequenceFrets()
  if S.tab==3 then
    local seq = {}
    for _,c in ipairs(progChords(currentProg())) do seq[#seq+1] = c.frets end
    return seq
  elseif S.tab==1 then return { chordFrets() }
  else return { powerChord(S.proot, S.three) } end
end
local function currentFrets()
  if S.tab==1 then return chordFrets()
  elseif S.tab==2 then return powerChord(S.proot, S.three)
  elseif S.tab==4 then return fretFor(rootBaseOf(S.rroot))   -- board shows the pedal root
  elseif S.tab==5 then return fretFor(40)                    -- unused: no board on Song
  else return sequenceFrets()[1] end          -- board shows the first chord
end
local function currentArt()
  if S.tab==2 then return POWER[S.powerIdx]
  elseif S.tab==4 then return POWER[S.rhythmIdx]
  elseif S.tab==5 then return {name='song'}                  -- no pattern; song loops by tab
  else return STRUM[S.strumIdx] end
end
local function currentRiff() return makeRiff(S.rroot, S.scale, S.rhythmIdx, S.riffSeed) end

-- ---- song / arrangement -------------------------------------------------
-- a block's *natural* bars, as bar-local event lists, using the same generators
-- the individual tabs use. A block just snapshots one tab's selections.
local function blockNatural(b, bqn)
  if b.kind=='chord' then
    return { buildEvents(CHORDS[b.g.root][b.g.qual].frets, STRUM[b.g.strumIdx], bqn) }
  elseif b.kind=='power' then
    return { buildEvents(powerChord(b.g.proot, b.g.three), POWER[b.g.powerIdx], bqn) }
  elseif b.kind=='riff' then
    return { buildRiffEvents(makeRiff(b.g.rroot, b.g.scale, b.g.rhythmIdx, b.g.riffSeed),
                             rootBaseOf(b.g.rroot), bqn) }
  else -- prog
    local out = {}
    for _,c in ipairs(progChordsIn(b.g.prog, b.g.keyPC)) do
      out[#out+1] = buildEvents(c.frets, STRUM[b.g.strumIdx], bqn)
    end
    return out
  end
end
local function songLen()
  local n = 0
  for _,b in ipairs(S.song) do n = math.max(n, b.startBar + b.bars) end
  return n
end
-- the whole arrangement as one bar-local event list per absolute bar (empty = rest).
-- Each block tiles its natural bars across its stretched length; overlapping blocks
-- simply stack. This slots straight into the existing per-bar audition/insert paths.
local function renderSongBars(bqn)
  local bars = {}
  for i=1,songLen() do bars[i] = {} end
  for _,b in ipairs(S.song) do
    local nat = blockNatural(b, bqn)
    for k=0,b.bars-1 do
      local dst = bars[b.startBar + k + 1]
      for _,e in ipairs(nat[k % #nat + 1]) do dst[#dst+1] = e end
    end
  end
  return bars
end

-- one event-list per bar for whatever the active tab plays
local function eventBars(bqn)
  if S.tab==5 then return renderSongBars(bqn) end
  if S.tab==4 then return { buildRiffEvents(currentRiff(), rootBaseOf(S.rroot), bqn) } end
  local art, out = currentArt(), {}
  for _,frets in ipairs(sequenceFrets()) do out[#out+1] = buildEvents(frets, art, bqn) end
  return out
end
local function scaleName(key)
  for _,s in ipairs(SCALES) do if s.key==key then return s.name end end
  return key
end
local function currentLabel()
  if S.tab==1 then return CHORDS[S.root][S.qual].label
  elseif S.tab==2 then return S.proot..'5'
  elseif S.tab==4 then return S.rroot..' '..scaleName(S.scale)
  elseif S.tab==5 then return 'Song'
  else
    local p = currentProg()
    local names = {}
    for _,c in ipairs(progChords(p)) do names[#names+1] = c.label end
    return table.concat(names, ' - ')
  end
end

-- ---- block builders (snapshot the active tab's selections into a song block) ----
local KIND_COL = {   -- lane colour per block kind
  chord = {0.910,0.639,0.239}, power = {0.42,0.62,0.86},
  prog  = {0.46,0.78,0.52},    riff  = {0.72,0.55,0.86},
}
local function tabKind() return ({'chord','power','prog','riff'})[S.tab] end
local function makeBlock(kind)
  local b = {kind=kind, startBar=songLen(), g={}}
  if kind=='chord' then
    b.g = {root=S.root, qual=S.qual, strumIdx=S.strumIdx}
    b.bars, b.label = 1, CHORDS[S.root][S.qual].label
  elseif kind=='power' then
    b.g = {proot=S.proot, three=S.three, powerIdx=S.powerIdx}
    b.bars, b.label = 1, S.proot..'5'
  elseif kind=='riff' then
    b.g = {rroot=S.rroot, scale=S.scale, rhythmIdx=S.rhythmIdx, riffSeed=S.riffSeed}
    b.bars, b.label = 1, S.rroot..' '..scaleName(S.scale)..' riff'
  else
    local p = currentProg()
    b.g = {prog=p, keyPC=S.keyPC, keyMode=S.keyMode, strumIdx=S.strumIdx}
    b.bars, b.label = #p.chords, (p.name~='' and p.name or 'progression')
  end
  return b
end
local function addToSong(kind)
  local b = makeBlock(kind)
  S.song[#S.song+1] = b
  S.songSel = #S.song
  S.status = 'Added "'..b.label..'" to the song  ·  '..#S.song..' block'
             ..(#S.song==1 and '' or 's')..', '..songLen()..' bars.'
end
local function deleteSel()
  if S.songSel then
    local b = S.song[S.songSel]
    table.remove(S.song, S.songSel); S.songSel = nil
    if b then S.status = 'Removed "'..b.label..'".' end
  end
end
local function currentDia()
  local f = currentFrets()
  local s = ''
  for i=1,6 do
    local v = f[i]
    s = s .. (v==false and 'x' or (v<10 and tostring(v) or string.char(87+v)))
  end
  return s
end

----------------------------------------------------------------------
-- audition through the selected track (virtual MIDI keyboard)
----------------------------------------------------------------------
local sched, playing, nextStart, lit = {}, false, 0, {}
local playBarStarts = {}          -- audio-clock start time of each bar in the queued sequence

local function panic()
  for ch=0,0 do reaper.StuffMIDIMessage(0, 0xB0+ch, 123, 0) end
  for _,e in ipairs(sched) do
    if not e.on then reaper.StuffMIDIMessage(0, 0x80, e.pitch, 0) end
  end
  sched = {}
end

-- lay the whole sequence out from t0, one chord per bar (one bar for a single chord)
local function queueBar(t0)
  local spqn = 60 / tempo()
  local bqn  = barQN()
  local t = t0
  playBarStarts = {}
  for _,evlist in ipairs(eventBars(bqn)) do
    playBarStarts[#playBarStarts+1] = t
    for _,e in ipairs(evlist) do
      sched[#sched+1] = {t=t + e.qn*spqn, on=true,  pitch=e.pitch, vel=e.vel, str=e.str}
      sched[#sched+1] = {t=t + (e.qn+e.len)*spqn, on=false, pitch=e.pitch}
    end
    t = t + bqn * spqn
  end
  table.sort(sched, function(a,b) return a.t < b.t end)
  nextStart = t
end

-- which bar of the queued sequence is sounding now (1-based); 1 when idle
local function playingBar()
  if not playing or #playBarStarts == 0 then return 1 end
  local now, idx = reaper.time_precise(), 1
  for k,ts in ipairs(playBarStarts) do if now >= ts then idx = k end end
  return idx
end

-- MIDI input, all channels, all inputs (the virtual keyboard is one of them)
local MIDI_ALL_IN = 4096 | (63 << 5)

local function trackName(tr)
  local _, nm = reaper.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', false)
  if nm == '' then nm = 'Track ' .. math.floor(reaper.GetMediaTrackInfo_Value(tr,'IP_TRACKNUMBER')) end
  return nm
end

-- wires the selected track so the audition can reach its instrument
local function setupTrack()
  local tr = reaper.GetSelectedTrack(0, 0)
  if not tr then S.status = 'Select a track first, then click Set up track.' return end
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECINPUT', MIDI_ALL_IN)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECARM', 1)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECMON', 1)
  reaper.SetMediaTrackInfo_Value(tr, 'I_FXEN', 1)
  reaper.TrackList_AdjustWindows(false)
  reaper.UpdateArrange()
  if reaper.TrackFX_GetCount(tr) == 0 then
    S.status = trackName(tr) .. ' is armed, but has no instrument. Add your guitar VSTi.'
  else
    S.status = trackName(tr) .. ' is ready. Press Audition.'
  end
end

-- says why it is silent instead of just being silent
local function checkAudible()
  local tr = reaper.GetSelectedTrack(0, 0)
  if not tr then return 'No track selected - click a track, then Set up track.' end
  if reaper.TrackFX_GetCount(tr) == 0 then
    return trackName(tr) .. ' has no instrument on it.' end
  local armed = reaper.GetMediaTrackInfo_Value(tr, 'I_RECARM') == 1
  local mon   = reaper.GetMediaTrackInfo_Value(tr, 'I_RECMON') > 0
  local isMidi = (math.floor(reaper.GetMediaTrackInfo_Value(tr, 'I_RECINPUT')) & 4096) ~= 0
  if not (armed and mon and isMidi) then
    return trackName(tr) .. ' is not armed for MIDI input - press Tab or click Set up track.' end
  return nil
end

local function audition()
  if S.tab==5 and #S.song==0 then
    S.status = 'The song is empty — add blocks from the other tabs first.' return
  end
  local why = checkAudible()
  if why then S.status = why
  elseif S.tab==5 then S.status = 'Playing song · '..#S.song..' blocks, '..songLen()..' bars'
  else S.status = 'Playing ' .. currentLabel() .. ' - ' .. currentArt().name end
  panic()
  playing = true
  queueBar(reaper.time_precise() + 0.05)
end

local function stopAudition()
  playing = false
  panic()
end

-- the home-row keys, left to right, standing in for scale degrees I..vii°. A physical
-- run under the resting hand is easy to find by touch, which is the point when you are
-- singing over it. DEGREE_KEY maps each key's char code (both cases) to its degree.
local DEG_KEYS = {'a','s','d','f','g','h','j'}
local DEGREE_KEY = {}
for i,k in ipairs(DEG_KEYS) do
  DEGREE_KEY[string.byte(k)] = i
  DEGREE_KEY[string.byte(k:upper())] = i
end

-- play the i-th diatonic chord of the current key by keyboard, so you can accompany
-- yourself by ear — press a key, sing over it, press the next. It selects the same
-- chord the "IN KEY" numeral row shows and auditions it with the current strum,
-- switching to the Chords tab so the board confirms what's sounding.
local function playDegree(i)
  local dia = diatonicChords(S.keyPC, S.keyMode, S.sevenths)
  local dc = dia[i]
  if not dc then return end
  S.tab, S.root, S.qual, S.inv = 1, NAMES[dc.pc+1], dc.quality, 0
  audition()
end

local function serviceAudio()
  local now = reaper.time_precise()
  while sched[1] and sched[1].t <= now do
    local e = table.remove(sched, 1)
    if e.on then
      reaper.StuffMIDIMessage(0, 0x90, e.pitch, e.vel)
      if e.str then lit[e.str] = now + 0.22 end
    else
      reaper.StuffMIDIMessage(0, 0x80, e.pitch, 0)
    end
  end
  if playing then
    local isPattern = currentArt().p ~= nil or S.tab==5
    if isPattern and S.loop and now > nextStart - 0.12 then
      queueBar(nextStart)
    elseif #sched == 0 and (not isPattern or not S.loop) then
      playing = false
    end
  end
end

----------------------------------------------------------------------
-- insert into the project
----------------------------------------------------------------------
local function insertAtCursor()
  local tr = reaper.GetSelectedTrack(0, 0)
  if not tr then S.status = 'No track selected. Click a track first.' return end
  if S.tab==5 and #S.song==0 then S.status = 'The song is empty — nothing to send.' return end
  local pos  = reaper.GetCursorPosition()
  local bqn  = barQN()
  local bars = eventBars(bqn)
  local qn0  = reaper.TimeMap2_timeToQN(0, pos)
  local endT = reaper.TimeMap2_QNToTime(0, qn0 + bqn * #bars)

  reaper.Undo_BeginBlock()
  local item = reaper.CreateNewMIDIItemInProj(tr, pos, endT, false)
  local take = reaper.GetActiveTake(item)
  for bar,evlist in ipairs(bars) do
    local off = (bar-1) * bqn
    for _,e in ipairs(evlist) do
      local sp = reaper.MIDI_GetPPQPosFromProjQN(take, qn0 + off + e.qn)
      local ep = reaper.MIDI_GetPPQPosFromProjQN(take, qn0 + off + e.qn + e.len)
      reaper.MIDI_InsertNote(take, false, false, sp, ep, 0, e.pitch, e.vel, true)
    end
  end
  reaper.MIDI_Sort(take)
  local nm
  if S.tab==5 then
    nm = 'Song · ' .. #S.song .. ' blocks, ' .. songLen() .. ' bars'
  elseif S.tab==3 then
    local p = currentProg()
    nm = (p.name ~= '' and p.name or currentLabel())
  elseif S.tab==4 then
    nm = currentLabel() .. ' riff · ' .. currentArt().name .. ' #' .. S.riffSeed
  else
    local a = analyze(S.keyPC, S.keyMode, pcOf(S.tab==1 and S.root or S.proot),
                      S.tab==1 and S.qual or '5')
    nm = currentLabel() .. ' (' .. a.numeral .. ') ' .. currentArt().name
  end
  reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', nm, true)
  -- advance the edit cursor to the end of what we just inserted, so back-to-back inserts
  -- lay chords end to end: audition, insert, pick the next, insert again. moveview keeps
  -- the new cursor on screen; seekplay stays false so playback isn't disturbed.
  reaper.SetEditCurPos(endT, true, false)
  reaper.UpdateArrange()
  reaper.Undo_EndBlock('Insert ' .. nm, -1)
  S.status = 'Inserted ' .. nm .. ' · cursor advanced to the end, ready for the next.'
end

----------------------------------------------------------------------
-- write a .mid file (drag it in from the Media Explorer)
----------------------------------------------------------------------
local function vlq(n)
  local b, out = n & 0x7F, ''
  n = n >> 7
  out = string.char(b)
  while n > 0 do
    out = string.char((n & 0x7F) | 0x80) .. out
    n = n >> 7
  end
  return out
end
local function be(n, bytes)
  local s = ''
  for i = bytes-1, 0, -1 do s = s .. string.char((n >> (8*i)) & 0xFF) end
  return s
end

local function exportMidi()
  local PPQ, bpm = 480, tempo()
  local evs = (S.tab==4)
    and buildRiffEvents(currentRiff(), rootBaseOf(S.rroot), barQN())
    or  buildEvents(currentFrets(), currentArt(), barQN())
  local list = {}
  for _,e in ipairs(evs) do
    list[#list+1] = {t=math.floor(e.qn*PPQ+0.5), on=1, p=e.pitch, v=e.vel}
    list[#list+1] = {t=math.floor((e.qn+e.len)*PPQ+0.5), on=0, p=e.pitch, v=0}
  end
  table.sort(list, function(a,b) if a.t==b.t then return a.on < b.on end return a.t < b.t end)

  local mpqn = math.floor(60000000 / bpm)
  local data = '\0\255\81\3' .. be(mpqn,3)                    -- tempo
  data = '\0' .. string.char(0xC0, 29) .. data                 -- program change
  local prev = 0
  for _,e in ipairs(list) do
    data = data .. vlq(e.t - prev) .. string.char(e.on==1 and 0x90 or 0x80, e.p, e.v)
    prev = e.t
  end
  data = data .. '\0\255\47\0'
  local mid = 'MThd' .. be(6,4) .. be(0,2) .. be(1,2) .. be(PPQ,2)
            .. 'MTrk' .. be(#data,4) .. data

  local dir = reaper.GetProjectPath('') .. '/GuitarChords'
  reaper.RecursiveCreateDirectory(dir, 0)
  local name = (currentLabel() .. '_' .. currentArt().name):gsub('[^%w%+%-]', '_')
  local path = dir .. '/' .. name .. '.mid'
  local f = io.open(path, 'wb')
  if not f then S.status = 'Could not write to ' .. dir return end
  f:write(mid) f:close()
  S.status = 'Saved ' .. name .. '.mid  ->  ' .. dir
end

----------------------------------------------------------------------
-- ui
----------------------------------------------------------------------
-- Logic/GarageBand palette: cool graphite chrome, macOS system-blue accent
local C = {
  bg={0.129,0.133,0.145}, panel={0.169,0.176,0.196}, line={0.267,0.278,0.302},
  ink={0.902,0.914,0.933}, mute={0.545,0.561,0.600}, accent={0.157,0.518,0.984},
  accentDim={0.157,0.278,0.451}, wood={0.216,0.176,0.145}, nickel={0.612,0.639,0.671},
  string={0.776,0.796,0.824}, chip={0.204,0.216,0.239}, selink={0.98,0.99,1.0},
}
local function col(c, a) gfx.set(c[1], c[2], c[3], a or 1) end
local function box(x,y,w,h,c,fill) col(c); gfx.rect(x,y,w,h,fill and 1 or 0) end
local function txt(s,x,y,c,font)
  gfx.setfont(font or 1); col(c); gfx.x=x; gfx.y=y; gfx.drawstr(s)
end
local function txtc(s,x,y,w,c,font)
  gfx.setfont(font or 1); col(c)
  local tw = gfx.measurestr(s); gfx.x = x + (w-tw)/2; gfx.y = y; gfx.drawstr(s)
end

local mousePrev, clicked, mx, my = 0, false, 0, 0
local pressed, released, held = false, false, false   -- mouse edges/state for dragging
local songDragMode, songDragOff = nil, 0              -- timeline drag: 'move' | 'stretch'
local progListRect = nil     -- {x,y,w,h} of the progression list, for wheel scrolling
local function hit(x,y,w,h) return mx>=x and mx<x+w and my>=y and my<y+h end
local function chip(x,y,w,h,label,on,font)
  local hov = hit(x,y,w,h)
  box(x,y,w,h, on and C.accentDim or C.chip, true)
  box(x,y,w,h, on and C.accent or (hov and C.mute or C.line), false)
  txtc(label, x, y + (h-11)/2 - 2, w, on and C.selink or C.ink, font or 2)
  return clicked and hov
end
local function button(x,y,w,h,label,primary)
  local hov = hit(x,y,w,h)
  box(x,y,w,h, primary and C.accent or C.chip, true)
  box(x,y,w,h, primary and C.accent or (hov and C.mute or C.line), false)
  txtc(label, x, y + (h-12)/2 - 2, w, primary and C.selink or C.ink, 2)
  return clicked and hov
end

----------------------------------------------------------------------
-- hand-drawn glyphs (gfx has no SVG; these are vector primitives). A stroke is a
-- triangle pointing the way the hand moves; a pattern is a row of them / of cells.
----------------------------------------------------------------------
local function strokeGlyph(cx, cy, r, kind, on)
  if kind=='D' or kind=='d' then                       -- downstroke: triangle down
    col(on and C.accent or {0.60,0.64,0.70}); gfx.triangle(cx-r,cy-r, cx+r,cy-r, cx,cy+r)
  elseif kind=='U' or kind=='u' then                   -- upstroke: triangle up
    col(C.nickel); gfx.triangle(cx-r,cy+r, cx+r,cy+r, cx,cy-r)
  elseif kind=='P' then                                -- palm mute: down, muted colour
    col(C.mute); gfx.triangle(cx-r,cy-r, cx+r,cy-r, cx,cy+r)
  elseif kind=='x' then                                -- dead: small x
    col(C.mute); gfx.line(cx-r,cy-r,cx+r,cy+r); gfx.line(cx-r,cy+r,cx+r,cy-r)
  else col(C.line); gfx.circle(cx, cy, 1, 1, 1) end    -- rest: dot
end
-- strum icon: one big stroke for the single kinds, else the 8-slot down/up motif
local function drawStrumIcon(x, y, w, h, art, on)
  local cy = y + h/2
  if art.single then
    if art.single=='A' then                            -- arpeggio: rising steps
      col(on and C.accent or {0.60,0.64,0.70})
      for i=0,3 do gfx.circle(x+3+i*5, cy+5-i*3, 1.5, 1, 1) end
    else strokeGlyph(x+w/2, cy, 5, art.single, on) end
  else
    local n = #art.p
    for i=1,n do
      local cx = x + (i-0.5)*(w/n)
      strokeGlyph(cx, cy, math.min(4, w/n/2 - 1), art.p[i], on)
    end
  end
end
-- mini pattern strip, the footer grid shrunk onto a button
local function drawPatternMini(x, y, w, h, art, on)
  local n = #art.p
  local cw = w/n
  for i=1,n do
    local k = art.p[i]
    local c = (k==0) and C.chip or (k=='P' and (on and C.accent or C.accentDim)
              or (k=='x' and C.line or C.nickel))
    box(x+(i-1)*cw, y, math.max(1, cw-1), h, c, true)
  end
end
-- a chip with a glyph strip on the left and a label on the right
local function iconChip(x,y,w,h,on,label,drawIcon)
  local hov = hit(x,y,w,h)
  box(x,y,w,h, on and C.accentDim or C.chip, true)
  box(x,y,w,h, on and C.accent or (hov and C.mute or C.line), false)
  drawIcon(x+4, y+3, 42, h-6, on)
  col(C.line); gfx.line(x+50, y+4, x+50, y+h-4)
  txt(label, x+56, y+(h-11)/2-1, on and C.selink or C.ink, 2)
  return clicked and hov
end
-- a chip with the label on top and its rhythm strip along the bottom
local function patternChip(x,y,w,h,on,label,art)
  local hov = hit(x,y,w,h)
  box(x,y,w,h, on and C.accentDim or C.chip, true)
  box(x,y,w,h, on and C.accent or (hov and C.mute or C.line), false)
  txt(label, x+6, y+2, on and C.selink or C.ink, 2)
  drawPatternMini(x+6, y+h-9, w-12, 6, art, on)
  return clicked and hov
end

-- a die face: light body, dark pips laid out on the 3x3 grid for `face` (1..6)
local PIPS = {
  [1]={{0.5,0.5}},
  [2]={{0.3,0.3},{0.7,0.7}},
  [3]={{0.3,0.3},{0.5,0.5},{0.7,0.7}},
  [4]={{0.3,0.3},{0.7,0.3},{0.3,0.7},{0.7,0.7}},
  [5]={{0.3,0.3},{0.7,0.3},{0.5,0.5},{0.3,0.7},{0.7,0.7}},
  [6]={{0.3,0.3},{0.7,0.3},{0.3,0.5},{0.7,0.5},{0.3,0.7},{0.7,0.7}},
}
local function drawDice(dx, dy, ds, face)
  box(dx, dy, ds, ds, C.string, true)
  box(dx, dy, ds, ds, C.mute, false)
  col(C.bg)
  local r = math.max(1, ds*0.1)
  for _,p in ipairs(PIPS[face] or PIPS[5]) do
    gfx.circle(dx + p[1]*ds, dy + p[2]*ds, r, 1, 1)
  end
end

-- per-mood accent colours, so the Progressions tab reads by colour, not just text
local MOOD_COL = {
  Rock={0.85,0.55,0.30},  Metal={0.70,0.72,0.76},   Phrygian={0.82,0.44,0.40},
  Blues={0.38,0.55,0.82}, Emotional={0.80,0.50,0.72},Beautiful={0.52,0.76,0.80},
  Sad={0.44,0.54,0.74},   Jazz={0.82,0.64,0.34},     Pop={0.54,0.80,0.54},
  Dark={0.52,0.46,0.62},  Sexy={0.84,0.42,0.52},     Inspiring={0.82,0.74,0.38},
  Unique={0.60,0.74,0.62},Other={0.56,0.52,0.48},
}
local function moodCol(m) return MOOD_COL[m] or C.mute end

local function drawBoard(frets, x0, y0, w, h)
  local minf, maxf, any = 99, 0, false
  for i=1,6 do local f=frets[i]
    if f and f>0 then any=true; minf=math.min(minf,f); maxf=math.max(maxf,f) end end
  local start = (not any or maxf<=5) and 1 or minf
  local nx, fw, sg = x0+52, (w-52)/5, h/5
  box(nx, y0-12, fw*5, h+24, C.wood, true)
  box(nx-7, y0-12, 7, h+24, start==1 and {0.906,0.878,0.824} or {0.353,0.290,0.243}, true)
  for f=1,5 do
    col(C.nickel)
    gfx.line(nx+fw*f, y0-12, nx+fw*f, y0+h+12)
    gfx.line(nx+fw*f+1, y0-12, nx+fw*f+1, y0+h+12)
  end
  local now = reaper.time_precise()
  for i=6,1,-1 do
    local y = y0 + (6-i)*sg
    local isLit = (lit[i] or 0) > now
    col(isLit and C.accent or C.string)
    gfx.line(nx-7, y, nx+fw*5, y)
    if i <= 3 then gfx.line(nx-7, y+1, nx+fw*5, y+1) end   -- wound strings read thicker
    local f = frets[i]
    if f == false then
      txtc('x', nx-38, y-8, 16, C.mute, 2)
    elseif f == 0 then
      col(C.string); gfx.circle(nx-30, y, 5, 0, 1)
    else
      col(isLit and C.accent or {0.949,0.929,0.894})
      gfx.circle(nx + fw*(f-start+0.5), y, 9, 1, 1)
    end
  end
  if start > 1 then txtc(start..'fr', nx, y0+h+14, fw, C.mute, 2) end
end

-- the arrangement lane: blocks on a bar grid, drag to move, drag the right edge to
-- stretch, click to select. Bar/pixel maths all live off LANE so the drag and the
-- draw agree.
local LANE = {x=20, y=150, w=680, h=84, view=16}
local function laneBarW() return LANE.w / LANE.view end
local function drawTimeline()
  local L, barW = LANE, laneBarW()
  box(L.x, L.y, L.w, L.h, C.panel, true)

  -- grab / drag input, resolved before drawing so the visuals reflect this frame
  if pressed and hit(L.x, L.y, L.w, L.h) then
    S.songSel, songDragMode = nil, nil
    for idx=#S.song,1,-1 do                      -- topmost block under the cursor wins
      local b  = S.song[idx]
      local bx = L.x + (b.startBar - S.songScroll) * barW
      local bw = b.bars * barW
      if mx>=bx and mx<bx+bw and my>=L.y+6 and my<L.y+L.h-18 then
        S.songSel = idx
        if mx >= bx+bw-8 then songDragMode = 'stretch'
        else songDragMode, songDragOff = 'move', (S.songScroll + (mx-L.x)/barW) - b.startBar end
        break
      end
    end
  end
  if held and S.songSel and songDragMode then
    local b, mbar = S.song[S.songSel], S.songScroll + (mx - L.x)/barW
    if songDragMode=='move' then
      b.startBar = math.max(0, math.floor(mbar - songDragOff + 0.5))
    else
      b.bars = math.max(1, math.floor(mbar + 0.5) - b.startBar)
    end
  end
  if released then songDragMode = nil end

  -- bar grid + numbers every 4 bars
  for i=0,L.view do
    local gx, bar = L.x + i*barW, S.songScroll + i
    col(bar % 4 == 0 and C.line or C.chip)
    gfx.line(gx, L.y, gx, L.y+L.h)
    if bar % 4 == 0 then txt(tostring(bar+1), gx+3, L.y+L.h-14, C.mute, 2) end
  end

  -- blocks
  for idx,b in ipairs(S.song) do
    local bx = L.x + (b.startBar - S.songScroll) * barW
    local bw = b.bars * barW
    local vx0, vx1 = math.max(bx, L.x), math.min(bx+bw, L.x+L.w)
    if vx1 > vx0 then
      local sel = idx == S.songSel
      box(vx0, L.y+6, vx1-vx0, L.h-26, KIND_COL[b.kind] or C.accent, true)
      box(vx0, L.y+6, vx1-vx0, L.h-26, sel and C.ink or C.bg, false)
      txt(b.label, vx0+6, L.y+12, C.bg, 2)
      if sel then box(vx1-6, L.y+6, 6, L.h-26, C.ink, true) end   -- stretch handle
    end
  end

  -- playhead
  if playing then
    local phx = L.x + (playingBar()-1 - S.songScroll) * barW
    if phx >= L.x and phx <= L.x+L.w then
      col(C.accent); gfx.line(phx, L.y, phx, L.y+L.h); gfx.line(phx+1, L.y, phx+1, L.y+L.h)
    end
  end
end

local W, H = 720, 812             -- fixed design canvas; the UI never reflows off it
-- STABLE title (no version): REAPER remembers a gfx window's position by its title, so
-- the version lives in the status bar instead — otherwise every build looks like a new
-- window and its remembered position is lost. We set the size (for zoom); REAPER the spot.
local TITLE  = 'Guitar Chord Pack'
local CANVAS = 0                  -- offscreen image the UI is drawn into, then blitted

-- EZdrummer-style zoom: the UI is drawn at the 720x812 canvas and blitted to fill the
-- window, so it scales without reflowing. "100%" is the largest window that fits this
-- monitor's work area (capped for readability); the stepper only scales *down* from
-- there, so no level is ever bigger than the screen can show.
local function maxFitScale()
  if not reaper.my_getViewport then return 1.0 end
  local l, t, r, b = reaper.my_getViewport(0, 0, 0, 0, 0, 0, W, H, true)
  local fit = math.min((r - l) * 0.96 / W, (b - t) * 0.92 / H)
  return math.max(0.6, math.min(fit, 1.5))
end
local BASE = maxFitScale()        -- the biggest that fits = the user's 100%
local PCTS = {100, 90, 80, 70, 60}
local uiIdx = 1                   -- default: 100% of BASE
local pendingSize = nil           -- {w,h} to re-open the window at, applied after the frame
local winX, winY = nil, nil        -- last window position (screen coords), nil = unknown
local function levelSize(idx)
  local m = BASE * PCTS[idx] / 100
  return math.floor(W * m + 0.5), math.floor(H * m + 0.5)
end

local function setFonts()
  gfx.setfont(1, 'Helvetica Neue', 15)
  gfx.setfont(2, 'Helvetica Neue', 12)
  gfx.setfont(3, 'Menlo', 29, string.byte('b'))
  gfx.setfont(4, 'Menlo', 15)
end
-- fonts and the offscreen buffer are per-window; re-establish them after every init
local function afterInit()
  setFonts()
  gfx.setimgdim(CANVAS, W, H)
end

----------------------------------------------------------------------
-- persistence: remember the picks across sessions via REAPER's ExtState
-- (persist=true writes to reaper-extstate.ini, so it survives restarts). Enumerated
-- fields are validated on load, so a stale value from an older build can't crash us.
----------------------------------------------------------------------
local EXT = 'GuitarChordPack'
local function inList(v, t) for _,x in ipairs(t) do if x==v then return true end end return false end
local function saveState()
  local set = function(k,v) reaper.SetExtState(EXT, k, tostring(v), true) end
  set('tab', S.tab)         set('root', S.root)       set('qual', S.qual)  set('inv', S.inv)
  set('strumIdx', S.strumIdx) set('proot', S.proot)   set('three', S.three and 1 or 0)
  set('powerIdx', S.powerIdx) set('rroot', S.rroot)   set('scale', S.scale)
  set('rhythmIdx', S.rhythmIdx) set('riffSeed', S.riffSeed) set('loop', S.loop and 1 or 0)
  set('keyPC', S.keyPC)     set('keyMode', S.keyMode) set('sevenths', S.sevenths and 1 or 0)
  set('mood', S.mood)       set('progSel', S.progSel) set('uiIdx', uiIdx)
  if winX and winY then set('winX', math.floor(winX)); set('winY', math.floor(winY)) end
end
local function loadState()
  local g = function(k) local v = reaper.GetExtState(EXT, k); return v ~= '' and v or nil end
  local n = function(k) local v = g(k); return v and tonumber(v) or nil end
  local maxTab = SONG_ENABLED and 5 or 4
  if n('tab') then S.tab = math.max(1, math.min(maxTab, math.floor(n('tab')))) end
  if g('root')  and CHORDS[g('root')] then S.root = g('root') end
  if g('qual')  and CHORDS[S.root][g('qual')] then S.qual = g('qual') end
  if n('inv') then local iv=math.floor(n('inv'))
    S.inv = (iv>=1 and iv<=3 and invertShape(S.root, S.qual, iv)) and iv or 0 end
  if g('proot') and CHORDS[g('proot')] then S.proot = g('proot') end
  if g('rroot') and CHORDS[g('rroot')] then S.rroot = g('rroot') end
  if g('scale') then for _,s in ipairs(SCALES) do if s.key==g('scale') then S.scale=g('scale') end end end
  if g('keyMode')=='maj' or g('keyMode')=='min' then S.keyMode = g('keyMode') end
  if g('mood') and inList(g('mood'), PROGS.moods) then S.mood = g('mood') end
  if n('strumIdx')  then S.strumIdx  = math.max(1, math.min(#STRUM, math.floor(n('strumIdx')))) end
  if n('powerIdx')  then S.powerIdx  = math.max(1, math.min(#POWER, math.floor(n('powerIdx')))) end
  if n('rhythmIdx') then S.rhythmIdx = math.max(1, math.min(#POWER, math.floor(n('rhythmIdx')))) end
  if n('keyPC')     then S.keyPC     = math.max(0, math.min(11, math.floor(n('keyPC')))) end
  if n('riffSeed')  then S.riffSeed  = math.max(1, math.floor(n('riffSeed'))) end
  if n('progSel')   then S.progSel   = math.max(1, math.floor(n('progSel'))) end
  if g('three')    then S.three    = g('three') == '1' end
  if g('loop')     then S.loop     = g('loop') == '1' end
  if g('sevenths') then S.sevenths = g('sevenths') == '1' end
  local ui = n('uiIdx'); if ui and ui>=1 and ui<=#PCTS then uiIdx = math.floor(ui) end
  winX, winY = n('winX'), n('winY')
end
loadState()

-- open at the remembered zoom size, and the remembered position if we have one
do
  local w0, h0 = levelSize(uiIdx)
  if winX and winY then gfx.init(TITLE, w0, h0, 0, winX, winY)
  else gfx.init(TITLE, w0, h0, 0) end
end
afterInit()

local function draw()
  gfx.setfont(1)
  col(C.bg); gfx.rect(0,0,W,H,1)

  -- tabs
  local tabs = {'Chords','Power','Progressions','Riffs'}
  if SONG_ENABLED then tabs[#tabs+1] = 'Song' end
  for i,t in ipairs(tabs) do
    local x = 20 + (i-1)*112
    if chip(x, 16, 104, 28, t, S.tab==i, 2) then S.tab=i; stopAudition() end
  end
  -- UI zoom stepper (EZdrummer-style size levels). Clicking re-opens the window at
  -- the new size after the frame; the UI is always drawn on the 720x812 canvas and
  -- blitted to fill, so nothing reflows or clips.
  do
    local px  = W - 20 - 26            -- '+' button, right edge (bigger)
    local lx  = px - 48                -- percent label
    local mnx = lx - 26                -- '-' button (smaller)
    if button(mnx, 16, 26, 24, '-') and uiIdx < #PCTS then
      uiIdx = uiIdx + 1
      local w0, h0 = levelSize(uiIdx); pendingSize = {w=w0, h=h0}
    end
    txtc(PCTS[uiIdx]..'%', lx, 22, 48, C.mute, 2)
    if button(px, 16, 26, 24, '+') and uiIdx > 1 then
      uiIdx = uiIdx - 1
      local w0, h0 = levelSize(uiIdx); pendingSize = {w=w0, h=h0}
    end
  end

  local f = currentFrets()
  if S.tab==3 then
    -- header: progression name, its chords in the chosen key, roman numerals.
    -- the board and the lit chord follow whichever bar is currently sounding.
    local p = currentProg()
    local cs = progChords(p)
    local bar = math.min(playingBar(), #cs)
    f = cs[bar].frets
    txt(p.name ~= '' and p.name or (p.mood .. ' progression'), 20, 58, C.ink, 1)
    gfx.setfont(4)
    local lx = 20
    for j,c in ipairs(cs) do
      col(j==bar and C.accent or C.mute)
      gfx.x = lx; gfx.y = 84; gfx.drawstr(c.label)
      lx = lx + gfx.measurestr(c.label) + gfx.measurestr('  ')
    end
    local romans = {}
    for _,c in ipairs(cs) do
      romans[#romans+1] = analyze(S.keyPC, S.keyMode, pcOf(c.root), c.qual).numeral
    end
    txt(table.concat(romans, '   '), 20, 108, C.mute, 2)
    txt('in ' .. NAMES[S.keyPC+1] .. ' ' .. (S.keyMode=='maj' and 'major' or 'minor')
        .. '   ·   ' .. #cs .. ' bars', 470, 58, C.mute, 2)
  elseif S.tab==4 then
    -- riff header: procedural line, pedal root shown on the board
    txt(currentLabel() .. ' riff', 20, 60, C.ink, 3)
    txt(currentDia(), 250, 72, C.accent, 4)
    txt('procedural line · pedal root + scale', 20, 100, C.mute, 2)
    txt('seed ' .. S.riffSeed .. '   ·   ' .. currentArt().name, 470, 60, C.mute, 2)
    txt('Re-roll for a new line; the same seed replays identically', 470, 78, C.mute, 2)
  elseif S.tab==5 then
    -- song header: arrangement summary
    txt('Song', 20, 60, C.ink, 3)
    if #S.song==0 then
      txt('empty — add blocks from the other tabs, then drag to arrange', 20, 100, C.mute, 2)
    else
      txt(#S.song..' block'..(#S.song==1 and '' or 's')..'   ·   '..songLen()..' bars',
          20, 100, C.mute, 2)
    end
    txt('drag to reposition · drag right edge to stretch', 470, 60, C.mute, 2)
    txt('Send to REAPER lays the whole arrangement at the cursor', 470, 78, C.mute, 2)
  else
    -- header
    local label = currentLabel()
    if S.tab==1 and S.inv>0 then                    -- show the slash chord for inversions
      local lo=999 for _,nt in ipairs(pitchesOf(f)) do if nt.pitch<lo then lo=nt.pitch end end
      label = label .. '/' .. NAMES[lo%12+1]
    end
    txt(label, 20, 60, C.ink, 3)
    txt(currentDia(), 250, 72, C.accent, 4)
    local INVN = {'1st inversion', '2nd inversion', '3rd inversion'}
    local meta = noteNames(f)
    if S.tab==1 then meta = meta .. '   ' .. (S.inv>0 and INVN[S.inv] or CHORDS[S.root][S.qual].shape)
    else meta = meta .. '   ' .. (S.three and 'root + 5th + octave' or 'root + 5th') end
    txt(meta, 20, 100, C.mute, 2)

    -- roman numeral and function, relative to the chosen key
    local chordPC = pcOf(S.tab==1 and S.root or S.proot)
    local a = analyze(S.keyPC, S.keyMode, chordPC, S.tab==1 and S.qual or '5')
    local kx = 470
    txt('in ' .. NAMES[S.keyPC+1] .. ' ' .. (S.keyMode=='maj' and 'major' or 'minor'),
        kx, 60, C.mute, 2)
    txt(a.numeral, kx, 74, C.accent, 3)
    txt(a.func, kx, 100, C.ink, 2)
    txt(a.note, kx, 116, C.mute, 2)
  end

  if S.tab==5 then drawTimeline() else drawBoard(f, 20, 138, 680, 100) end

  -- transport (tab-aware: the Song tab commits the whole arrangement)
  local y = 268
  if button(20, y, 96, 30, playing and 'Stop' or 'Audition', not playing) then
    if playing then stopAudition() else audition() end
  end
  if S.tab==5 then
    if button(122, y, 140, 30, 'Send to REAPER', true) then insertAtCursor() end
    if button(268, y, 104, 30, 'Set up track') then setupTrack() end
    if button(378, y, 96, 30, 'Clear song') then
      S.song, S.songSel = {}, nil; stopAudition(); S.status = 'Song cleared.'
    end
    if chip(480, y, 54, 30, 'loop', S.loop, 2) then S.loop = not S.loop end
    txt(string.format('%.0f BPM', tempo()), 544, y+9, C.mute, 2)
  else
    if button(122, y, 116, 30, 'Insert at cursor') then insertAtCursor() end
    if button(244, y, 84, 30, 'Save .mid') then exportMidi() end
    if button(334, y, 104, 30, 'Set up track') then setupTrack() end
    if SONG_ENABLED and button(444, y, 124, 30, '+ Add to Song', true) then addToSong(tabKind()) end
    if chip(574, y, 54, 30, 'loop', S.loop, 2) then S.loop = not S.loop end
    txt(string.format('%.0f BPM', tempo()), 634, y+9, C.mute, 2)
  end

  -- selectors
  y = 316
  if S.tab == 1 then
    -- key-first: pick the key, then quality, and the diatonic chords fall out of it
    txt('KEY', 20, y, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = 20 + (i-1)*46
      if chip(x, y+18, 42, 26, r, pcOf(r)==S.keyPC, 2) then S.keyPC = pcOf(r) end
    end
    if chip(578, y+18, 60, 26, 'major', S.keyMode=='maj', 2) then S.keyMode='maj' end
    if chip(640, y+18, 60, 26, 'minor', S.keyMode=='min', 2) then S.keyMode='min' end

    txt('QUALITY', 20, y+56, C.mute, 2)
    for i,q in ipairs(QUALS) do
      local x = 20 + ((i-1)%8)*84
      local yy = y + 74 + math.floor((i-1)/8)*30
      if chip(x, yy, 80, 26, q, q==S.qual, 2) then S.qual=q; S.inv=0; audition() end
    end

    -- the seven chords of the chosen key, one click each — or play them from the home
    -- row (a s d f g h j = I..vii°) and sing along; each chip shows its key in the corner.
    txt('IN KEY', 20, y+136, C.mute, 2)
    txt('press the home row  a s d f g h j  to play and sing along', 78, y+136, {0.36,0.37,0.40}, 2)
    if chip(640, y+154, 60, 26, S.sevenths and '7ths' or 'triads', S.sevenths, 2) then
      S.sevenths = not S.sevenths
    end
    for i,dc in ipairs(diatonicChords(S.keyPC, S.keyMode, S.sevenths)) do
      local x = 20 + (i-1)*88
      local sel = (pcOf(S.root)==dc.pc and S.qual==dc.quality)
      if chip(x, y+154, 84, 26, dc.numeral, sel, 2) then
        S.root = NAMES[dc.pc+1]; S.qual = dc.quality; S.inv=0; audition()
      end
      txt(DEG_KEYS[i], x+5, y+157, sel and C.selink or C.mute, 2)  -- keyboard hint
      txtc(dc.root .. (dc.quality=='maj' and '' or dc.quality), x, y+182, 84, C.mute, 2)
    end

    txt('CHORD ROOT', 20, y+210, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = 20 + ((i-1)%12)*56
      if chip(x, y+228, 52, 26, r, r==S.root, 2) then S.root=r; S.inv=0; audition() end
    end

    -- inversions: real hand-playable shapes; the ones with no shape are dimmed out
    txt('INVERSION', 20, y+256, C.mute, 2)
    local invNames = {'root', '1st', '2nd', '3rd'}
    for iv=0,3 do
      local x = 20 + iv*88
      local avail = (iv==0) or (invertShape(S.root, S.qual, iv) ~= nil)
      if avail then
        if chip(x, y+274, 84, 26, invNames[iv+1], S.inv==iv, 2) then S.inv=iv; audition() end
      else
        box(x, y+274, 84, 26, C.chip, true)
        box(x, y+274, 84, 26, C.line, false)
        txtc(invNames[iv+1], x, y+281, 84, {0.36,0.37,0.40}, 2)
      end
    end

    txt('STRUM', 20, y+306, C.mute, 2)
    for i,s in ipairs(STRUM) do
      local x = 20 + ((i-1)%5)*136
      local yy = y + 324 + math.floor((i-1)/5)*30
      if iconChip(x, yy, 132, 26, i==S.strumIdx, s.name,
                  function(ix,iy,iw,ih,on) drawStrumIcon(ix,iy,iw,ih,s,on) end) then
        S.strumIdx=i; audition()
      end
    end
  elseif S.tab == 2 then
    txt('ROOT', 20, y, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = 20 + ((i-1)%12)*56
      if chip(x, y+18, 52, 26, r..'5', r==S.proot, 2) then S.proot=r; audition() end
    end
    if chip(20, y+54, 100, 26, S.three and '3-note' or '2-note', S.three, 2) then
      S.three = not S.three; audition()
    end
    txt('KEY', 20, y+94, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = 20 + (i-1)*46
      if chip(x, y+112, 42, 26, r, pcOf(r)==S.keyPC, 2) then S.keyPC = pcOf(r) end
    end
    if chip(578, y+112, 60, 26, 'major', S.keyMode=='maj', 2) then S.keyMode='maj' end
    if chip(640, y+112, 60, 26, 'minor', S.keyMode=='min', 2) then S.keyMode='min' end

    txt('PATTERN', 20, y+148, C.mute, 2)
    for i,p in ipairs(POWER) do
      local x = 20 + ((i-1)%5)*136
      local yy = y + 166 + math.floor((i-1)/5)*32
      if patternChip(x, yy, 132, 30, i==S.powerIdx, p.name, p) then S.powerIdx=i; audition() end
    end
  elseif S.tab==4 then
    txt('ROOT', 20, y, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = 20 + ((i-1)%12)*56
      if chip(x, y+18, 52, 26, r, r==S.rroot, 2) then S.rroot=r; audition() end
    end
    txt('SCALE', 20, y+58, C.mute, 2)
    for i,s in ipairs(SCALES) do
      local x = 20 + (i-1)*136
      if chip(x, y+76, 132, 26, s.name, s.key==S.scale, 2) then S.scale=s.key; audition() end
    end
    txt('RHYTHM', 20, y+116, C.mute, 2)
    for i,p in ipairs(POWER) do
      local x = 20 + ((i-1)%5)*136
      local yy = y + 134 + math.floor((i-1)/5)*32
      if patternChip(x, yy, 132, 30, i==S.rhythmIdx, p.name, p) then S.rhythmIdx=i; audition() end
    end
    do
      local bx, by, bw, bh = 20, y+244, 150, 30
      local hov = hit(bx, by, bw, bh)
      box(bx, by, bw, bh, C.chip, true)
      box(bx, by, bw, bh, hov and C.mute or C.line, false)
      drawDice(bx+9, by+7, 16, (S.riffSeed - 1) % 6 + 1)   -- die shows the current roll
      txt('Re-roll', bx+36, by+(bh-12)/2-1, C.ink, 2)
      if clicked and hov then S.riffSeed = S.riffSeed + 1; audition() end
    end
    txt('a new procedural line in the same scale + rhythm', 176, y+253, C.mute, 2)
  elseif S.tab==5 then
    -- song inspector: the selected block's controls, plus arranging help
    txt('SONG', 20, y, C.mute, 2)
    if #S.song==0 then
      txt('Add blocks from the Chords, Power, Progressions and Riffs tabs', 20, y+22, C.ink, 1)
      txt('with "+ Add to Song", then drag them here to arrange.', 20, y+46, C.mute, 2)
    else
      local b = S.songSel and S.song[S.songSel]
      if b then
        txt('Selected: ' .. b.label .. '   (' .. b.kind .. ')', 20, y+22, C.ink, 1)
        txt('bar ' .. (b.startBar+1) .. '   ·   length', 20, y+54, C.mute, 2)
        if button(200, y+48, 30, 26, '-') and b.bars > 1 then b.bars = b.bars - 1 end
        txtc(b.bars .. (b.bars==1 and ' bar' or ' bars'), 234, y+54, 76, C.ink, 2)
        if button(314, y+48, 30, 26, '+') then b.bars = b.bars + 1 end
        if button(372, y+48, 96, 26, 'Delete') then deleteSel() end
      else
        txt('Click a block to select it.', 20, y+22, C.mute, 2)
      end
      txt('Drag a block to move it · drag its right edge to stretch · scroll to pan',
          20, y+92, C.mute, 2)
    end
  else
    -- progressions tab — leads with STYLE and colour-codes by mood, so it reads by
    -- colour rather than as another chord grid; the library list is the hero.
    txt('STYLE', 20, y, C.mute, 2)
    for i,m in ipairs(PROGS.moods) do
      local x = 20 + ((i-1)%7)*98
      local yy = y + 18 + math.floor((i-1)/7)*30
      local on, hov = m==S.mood, hit(x, yy, 94, 26)
      box(x, yy, 94, 26, on and C.accentDim or C.chip, true)
      box(x, yy, 94, 26, on and C.accent or (hov and C.mute or C.line), false)
      box(x+7, yy+9, 8, 8, moodCol(m), true)                  -- mood swatch
      txt(m, x+22, yy+7, on and C.selink or C.ink, 2)
      if clicked and hov then S.mood=m; S.progSel=1; S.progScroll=0; stopAudition() end
    end

    txt('START ON', 20, y+80, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = 20 + (i-1)*46
      if chip(x, y+98, 42, 26, r, pcOf(r)==S.keyPC, 2) then S.keyPC = pcOf(r); audition() end
    end
    if chip(578, y+98, 60, 26, 'major', S.keyMode=='maj', 2) then S.keyMode='maj' end
    if chip(640, y+98, 60, 26, 'minor', S.keyMode=='min', 2) then S.keyMode='min' end

    -- the scrolling progression list (hero), each row colour-barred by its mood
    local list = progList()
    local lx, ly, lw = 20, y+138, 680
    local rowH, rows = 24, 8
    progListRect = {lx, ly, lw, rowH*rows}    -- captured for wheel scrolling
    local maxScroll = math.max(0, #list - rows)
    if S.progScroll > maxScroll then S.progScroll = maxScroll end
    box(lx, ly, lw, rowH*rows, C.panel, true)
    for vi=1,rows do
      local idx = S.progScroll + vi
      local p = list[idx]
      if p then
        local ry = ly + (vi-1)*rowH
        local sel = (idx == S.progSel)
        local hov = hit(lx, ry, lw, rowH)
        if sel then box(lx, ry, lw, rowH, C.accentDim, true) end
        if hov and not sel then box(lx, ry, lw, rowH, C.chip, true) end
        box(lx, ry, 4, rowH, moodCol(p.mood), true)           -- mood colour bar
        local names = {}
        for _,c in ipairs(progChords(p)) do names[#names+1] = c.label end
        local text = table.concat(names, ' - ')
        if p.name ~= '' then text = p.name .. '    ' .. text end
        txt(text, lx+12, ry+5, sel and C.selink or C.ink, 2)
        if clicked and hov then S.progSel=idx; audition() end
      end
    end
    -- scrollbar
    if #list > rows then
      local bh = rowH*rows * rows/#list
      local by = ly + (rowH*rows-bh) * (S.progScroll/maxScroll)
      box(lx+lw-5, ly, 5, rowH*rows, C.chip, true)
      box(lx+lw-5, by, 5, bh, C.mute, true)
    end
    txt((#list) .. ' progressions · scroll to browse · click to audition', 20, ly+rowH*rows+8, C.mute, 2)

    txt('STRUM', 20, ly+rowH*rows+34, C.mute, 2)
    for i,s in ipairs(STRUM) do
      local x = 20 + ((i-1)%5)*136
      local yy = ly+rowH*rows+52 + math.floor((i-1)/5)*30
      if iconChip(x, yy, 132, 26, i==S.strumIdx, s.name,
                  function(ix,iy,iw,ih,on) drawStrumIcon(ix,iy,iw,ih,s,on) end) then
        S.strumIdx=i; audition()
      end
    end
  end

  -- pattern grid (hidden where another row occupies its space: progressions and song)
  local art = currentArt()
  if art.p and S.tab ~= 3 and S.tab ~= 5 then
    local gy = H - 96
    local n = #art.p
    local cw = (680 - (n-1)*3) / n
    for i=1,n do
      local x = 20 + (i-1)*(cw+3)
      local k = art.p[i]
      local c = (k==0) and C.chip or (k=='P' and C.accentDim or (k=='x' and {0.18,0.19,0.21} or C.accent))
      box(x, gy, cw, 20, c, true)
      box(x, gy, cw, 20, (i-1) % art.div == 0 and C.line or C.chip, false)
      if k ~= 0 and k ~= 'P' then
        txtc(k=='x' and 'x' or k, x, gy+3, cw, k=='D' and C.selink or C.mute, 2)
      end
    end
  end

  box(0, H-52, W, 52, C.panel, true)
  txt(S.status, 20, H-36, C.mute, 2)
  -- version tag, so this window is identifiable at a glance against the browser build
  do
    gfx.setfont(2); col(C.mute)
    local vs = 'v'..VERSION
    local vw = gfx.measurestr(vs)
    gfx.x = W - vw - 20; gfx.y = H-36; gfx.drawstr(vs)
  end
end

local function loop()
  -- the UI is drawn on the fixed 720x812 canvas; fit it into the actual window
  -- (aspect preserved, letterboxed) and map the mouse back into canvas space
  local ww, wh = gfx.w, gfx.h
  do
    local _, wx, wy = gfx.dock(-1, 0, 0, 0, 0)    -- reliable window position on macOS
    if wx then winX, winY = wx, wy end
  end
  local s  = math.min(ww / W, wh / H)
  local dw, dh = W * s, H * s
  local ox, oy = (ww - dw) / 2, (wh - dh) / 2
  mx = (gfx.mouse_x - ox) / s
  my = (gfx.mouse_y - oy) / s
  local down = (gfx.mouse_cap & 1) == 1
  pressed  = down and (mousePrev & 1) == 0
  released = (not down) and (mousePrev & 1) == 1
  held, clicked = down, pressed
  -- wheel scrolls the progression list or pans the song timeline under the pointer
  if gfx.mouse_wheel ~= 0 then
    local dir = gfx.mouse_wheel > 0 and 1 or -1
    if S.tab==3 and progListRect
       and hit(progListRect[1], progListRect[2], progListRect[3], progListRect[4]) then
      S.progScroll = math.max(0, S.progScroll - dir)
    elseif S.tab==5 and hit(LANE.x, LANE.y, LANE.w, LANE.h) then
      local maxScroll = math.max(0, songLen() - 1)
      S.songScroll = math.max(0, math.min(maxScroll, S.songScroll - dir))
    end
    gfx.mouse_wheel = 0
  end

  gfx.dest = CANVAS                            -- render the UI to the offscreen canvas
  draw()
  gfx.dest = -1                                -- then blit it, scaled, into the window
  col(C.bg); gfx.rect(0, 0, ww, wh, 1)         -- letterbox fill around the canvas
  gfx.blit(CANVAS, 1, 0, 0, 0, W, H, ox, oy, dw, dh)

  mousePrev = gfx.mouse_cap
  serviceAudio()

  local ch = gfx.getchar()
  if ch == 32 then if playing then stopAudition() else audition() end end
  if ch == 9 then setupTrack() end   -- Tab = set up the selected track
  -- the home row a s d f g h j (any case) plays the seven diatonic chords of the key,
  -- left to right = I..vii°, so you can sing and comp yourself with fingers at rest
  if DEGREE_KEY[ch] then playDegree(DEGREE_KEY[ch]) end
  if ch == 27 or ch == -1 then stopAudition(); saveState(); gfx.quit() return end
  gfx.update()

  -- apply a zoom change by re-opening the window at the new size (gfx ignores a
  -- resize on an already-open window, so quit + init is the only way)
  if pendingSize then
    gfx.quit()
    if winX and winY then gfx.init(TITLE, pendingSize.w, pendingSize.h, 0, winX, winY)
    else gfx.init(TITLE, pendingSize.w, pendingSize.h, 0) end
    afterInit()
    pendingSize, mousePrev = nil, 1               -- swallow the click that resized
  end
  reaper.defer(loop)
end

reaper.atexit(function() panic(); saveState() end)
loop()
