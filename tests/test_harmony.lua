local H = dofile('src/harmony.lua')
local N = {C=0,Db=1,D=2,Eb=3,E=4,F=5,Gb=6,G=7,Ab=8,A=9,Bb=10,B=11}
local cases = {
  -- key, mode, chord root, quality, expected numeral, expected function keyword
  {'C','maj','G','7',    'V7',      'Dominant'},
  {'C','maj','C','maj',  'I',       'Tonic'},
  {'C','maj','D','m7',   'ii7',     'Predominant'},
  {'C','maj','F','maj',  'IV',      'Predominant'},
  {'C','maj','A','m',    'vi',      'Tonic'},
  {'C','maj','B','m7b5', 'viiø7',   'Dominant'},
  {'C','maj','E','m',    'iii',     'Tonic'},
  {'C','maj','A','7',    'V7/ii',   'Secondary dominant'},
  {'C','maj','E','7',    'V7/vi',   'Secondary dominant'},
  {'C','maj','D','maj',  'V/V',     'Secondary dominant'},
  {'C','maj','C','7',    'V7/IV',   'Secondary dominant'},
  {'C','maj','Ab','maj', '♭VI',     'borrowed'},
  {'C','maj','Bb','maj', '♭VII',    'borrowed'},
  {'C','maj','Db','maj', '♭II',     'Predominant'},
  {'A','min','E','7',    'V7',      'Dominant'},
  {'A','min','A','m',    'i',       'Tonic'},
  {'A','min','D','m',    'iv',      'Predominant'},
  {'A','min','C','maj',  'III',     'Tonic'},
  {'A','min','F','maj',  'VI',      'Predominant'},
  {'A','min','G','maj',  'VII',     'Subtonic'},
  {'A','min','B','m7b5', 'iiø7',    'Predominant'},
  {'C','maj','G','5',    'V5',      'Dominant'},
}
local fail=0
for _,c in ipairs(cases) do
  local r = H.analyze(N[c[1]], c[2], N[c[3]], c[4])
  local okN = r.numeral == c[5]
  local okF = r.func:lower():find(c[6]:lower(), 1, true) ~= nil
  if not (okN and okF) then
    fail=fail+1
    print(string.format('FAIL %s %s: %s%s -> got %s / %s, want %s / %s',
      c[1], c[2], c[3], c[4], r.numeral, r.func, c[5], c[6]))
  end
end
print(fail==0 and 'all '..#cases..' analysis cases pass' or (fail..' failures'))
print()
for _,mode in ipairs({'maj','min'}) do
  for _,sev in ipairs({false,true}) do
    local t = {}
    for _,d in ipairs(H.diatonic(0, mode, sev)) do t[#t+1] = d.numeral..' '..d.root..(d.quality=='maj' and '' or d.quality) end
    print(string.format('C %s %s: %s', mode, sev and '7ths' or 'triads', table.concat(t,'  ')))
  end
end
