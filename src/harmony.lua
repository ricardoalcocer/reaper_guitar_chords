-- functional harmony analysis: chord + key -> roman numeral, function, tendency
local H = {}

local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}

-- triad type and printed suffix for each quality in the pack
local Q = {
  maj   ={t='maj', s=''},      m    ={t='min', s=''},     ['7'] ={t='maj', s='7'},
  m7    ={t='min', s='7'},     maj7 ={t='maj', s='maj7'}, m7b5  ={t='dim', s='ø7'},
  dim7  ={t='dim', s='°7'},    dim  ={t='dim', s='°'},    aug   ={t='aug', s='+'},
  sus2  ={t='sus', s='sus2'},  sus4 ={t='sus', s='sus4'}, ['7sus4']={t='sus', s='7sus4'},
  ['6'] ={t='maj', s='6'},     m6   ={t='min', s='6'},    ['9'] ={t='maj', s='9'},
  add9  ={t='maj', s='add9'},  ['5']={t='pow', s='5'},
  -- extended qualities (progression library)
  maj9  ={t='maj', s='maj9'},  m9   ={t='min', s='9'},    m11   ={t='min', s='11'},
  ['13']={t='maj', s='13'},    ['13sus4']={t='sus', s='13sus4'}, ['9sus4']={t='sus', s='9sus4'},
  ['6/9']={t='maj', s='6/9'},  ['m6/9']={t='min', s='6/9'}, add11 ={t='maj', s='add11'},
  mMaj7 ={t='min', s='(maj7)'},['7alt']={t='maj', s='7alt'},
}

-- degree -> numeral spelling
local DEG_MAJ = {[0]='I',[1]='♭II',[2]='II',[3]='♭III',[4]='III',[5]='IV',
                 [6]='♯IV',[7]='V',[8]='♭VI',[9]='VI',[10]='♭VII',[11]='VII'}
local DEG_MIN = {[0]='I',[1]='♭II',[2]='II',[3]='III',[4]='♯III',[5]='IV',
                 [6]='♯IV',[7]='V',[8]='VI',[9]='♯VI',[10]='VII',[11]='VII'}

-- every degree gets a function; non-scale degrees are flagged as borrowed
local FUNC_MAJ = {[0]='Tonic',[1]='Predominant',[2]='Predominant',[3]='Tonic',
                  [4]='Tonic',[5]='Predominant',[6]='Predominant',[7]='Dominant',
                  [8]='Predominant',[9]='Tonic',[10]='Predominant',[11]='Dominant'}
local FUNC_MIN = {[0]='Tonic',[1]='Predominant',[2]='Predominant',[3]='Tonic',
                  [4]='Chromatic',[5]='Predominant',[6]='Predominant',[7]='Dominant',
                  [8]='Predominant',[9]='Predominant',[10]='Subtonic',[11]='Dominant'}

-- the triad quality the key itself puts on each scale degree
local TRIAD_MAJ = {[0]='maj',[2]='min',[4]='min',[5]='maj',[7]='maj',[9]='min',[11]='dim'}
local TRIAD_MIN = {[0]='min',[2]='dim',[3]='maj',[5]='min',[7]='maj',[8]='maj',[10]='maj'}

local NOTE_MAJ = {
  [0]='home', [2]='sets up the V', [4]='mediant, a gentle tonic',
  [5]='steps away from home', [7]='pulls back to I', [9]='relative minor, stands in for I',
  [11]='leading tone, pulls to I', [1]='Neapolitan, chromatic predominant',
  [3]='borrowed from the parallel minor', [6]='raised 4th, usually heading to V',
  [8]='borrowed from the parallel minor', [10]='backdoor, leans toward I',
}
local NOTE_MIN = {
  [0]='home', [2]='half-diminished ii, sets up V', [3]='relative major',
  [5]='steps away from home', [7]='pulls back to i', [8]='borrowed brightness above the tonic',
  [10]='subtonic, often works as the V of III', [11]='leading tone, pulls to i',
  [1]='Neapolitan, chromatic predominant', [4]='chromatic', [6]='raised 4th, heading to V',
  [9]='raised 6th, the Dorian colour',
}

local DIA_MAJ = {0,2,4,5,7,9,11}
local DIA_MIN = {0,2,3,5,7,8,10}

local function lower(n) return (n:gsub('[IV]+', function(r) return r:lower() end)) end
local function isDiatonic(set, d)
  for _,x in ipairs(set) do if x==d then return true end end
  return false
end

-- keyPC 0..11, mode 'maj'|'min', chordPC 0..11, quality string
function H.analyze(keyPC, mode, chordPC, quality)
  local q = Q[quality] or Q.maj
  local d = (chordPC - keyPC) % 12
  local degMap  = (mode=='maj') and DEG_MAJ  or DEG_MIN
  local funcMap = (mode=='maj') and FUNC_MAJ or FUNC_MIN
  local noteMap = (mode=='maj') and NOTE_MAJ or NOTE_MIN
  local dia     = (mode=='maj') and DIA_MAJ  or DIA_MIN

  -- leading-tone spelling in minor: VII is the subtonic, vii° the leading tone
  local base = degMap[d]
  if mode=='min' and d==11 and q.t~='dim' then base = '♯VII' end

  local num = base
  if q.t=='min' or q.t=='dim' then num = lower(num) end
  num = num .. q.s

  -- secondary dominants
  local triadMap = (mode=='maj') and TRIAD_MAJ or TRIAD_MIN
  local homeTriad = triadMap[d]
  -- dominant-seventh family: a major triad with a ♭7, so it can act as an applied V
  local seventh = (quality=='7' or quality=='9' or quality=='7sus4'
                   or quality=='13' or quality=='9sus4' or quality=='13sus4' or quality=='7alt')
  local plainMaj = (quality=='maj')
  -- a dom7 is diatonic only on V (and on the subtonic of a minor key)
  local seventhIsNative = (mode=='maj') and (d==7) or (d==7 or d==10)
  -- a major triad only reads as an applied V where the key wants a minor or dim chord
  local majContradicts = homeTriad and (homeTriad=='min' or homeTriad=='dim')
  local isDomShape = (seventh and not seventhIsNative) or (plainMaj and majContradicts)
  if isDomShape and d ~= 7 then
    local target = (chordPC + 5) % 12
    local td = (target - keyPC) % 12
    if isDiatonic(dia, td) and td ~= d then
      local tnum = degMap[td]
      local tri = 'maj'
      if mode=='maj' then
        if td==2 or td==4 or td==9 then tri='min' elseif td==11 then tri='dim' end
      else
        if td==0 or td==5 then tri='min' elseif td==2 then tri='dim' end
      end
      if tri~='maj' then tnum = lower(tnum) end
      local pre = (quality=='maj') and 'V' or (quality=='7sus4' and 'V7sus4' or 'V7')
      return {numeral = pre..'/'..tnum, func = 'Secondary dominant',
              note = 'a borrowed V that pulls to '..tnum..' ('..NAMES[target+1]..')',
              target = tnum}
    end
  end
  -- applied diminished sevenths resolve up a semitone
  if quality=='dim7' or quality=='m7b5' then
    local target = (chordPC + 1) % 12
    local td = (target - keyPC) % 12
    if isDiatonic(dia, td) and td ~= 0 and quality=='dim7' then
      local tnum = degMap[td]
      if (mode=='maj' and (td==2 or td==4 or td==9)) or (mode=='min' and (td==0 or td==5)) then
        tnum = lower(tnum)
      end
      return {numeral = num, func = 'Applied leading tone',
              note = 'pulls up a semitone to '..tnum..' ('..NAMES[target+1]..')', target = tnum}
    end
  end

  local func = funcMap[d] or 'Chromatic'
  if not isDiatonic(dia, d) and func ~= 'Chromatic' then
    func = func .. ' (borrowed)'
  end
  -- a chord whose quality contradicts the key still keeps its degree function
  return {numeral = num, func = func, note = noteMap[d] or 'chromatic colour'}
end

-- the seven diatonic chords of a key, as {degree, quality, numeral}
function H.diatonic(keyPC, mode, sevenths)
  local out = {}
  local degs = (mode=='maj') and DIA_MAJ or DIA_MIN
  local quals
  if mode=='maj' then
    quals = sevenths and {'maj7','m7','m7','maj7','7','m7','m7b5'}
                     or  {'maj','m','m','maj','maj','m','dim'}
  else
    -- harmonic-minor V: the dominant people actually play in a minor key
    quals = sevenths and {'m7','m7b5','maj7','m7','7','maj7','7'}
                     or  {'m','dim','maj','m','maj','maj','maj'}
  end
  for i,d in ipairs(degs) do
    local pc = (keyPC + d) % 12
    local a = H.analyze(keyPC, mode, pc, quals[i])
    out[#out+1] = {pc=pc, quality=quals[i], numeral=a.numeral, root=NAMES[pc+1], func=a.func}
  end
  return out
end

return H
