#!/usr/bin/env python3
"""Builds both deliverables from the shared sources in src/.

  src/harmony.lua        + src/reaper_template.lua + src/chorddata.json -> reaper/GuitarChordPack.lua
  src/web_template.html  + src/chorddata.json                           -> web/guitar-audition.html

Chord data is the single source of truth for voicings and is produced by
src/gen_chords.py, which validates every voicing against chord theory before
emitting it. Run `make data` after changing any shape.
"""
import hashlib, json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'src')
ORDER = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']

# Semver, bumped by hand for *meaning*: patch = fix, minor = feature,
# major = breaking change or a musical-constant change. build.py appends a short
# hash of the shared sources (below), so two builds can never look identical even
# if you forget to bump. The full string is stamped into BOTH deliverables, so
# matching stamps confirm the REAPER script and the browser tool are the same build.
VERSION_BASE = '2.11.0'

# every source that feeds either deliverable; the hash changes iff one of these does
_HASH_INPUTS = ['reaper_template.lua', 'web_template.html', 'harmony.lua',
                'chorddata.json', 'progressions.json']


def build_hash():
    h = hashlib.sha1()
    for name in _HASH_INPUTS:
        h.update(open(os.path.join(SRC, name), 'rb').read())
    return h.hexdigest()[:7]


VERSION = VERSION_BASE + '+' + build_hash()


def chord_data():
    return json.load(open(os.path.join(SRC, 'chorddata.json')))


def prog_data():
    return json.load(open(os.path.join(SRC, 'progressions.json')))


def lua_table(data):
    def frets(fr):
        return '{' + ','.join('false' if f is None else str(f) for f in fr) + '}'
    roots = []
    for root in ORDER:
        entries = [
            '["%s"]={label="%s",frets=%s,dia="%s",shape="%s",notes="%s"}'
            % (q, v['label'], frets(v['frets']), v['dia'], v['shape'], v['notes'])
            for q, v in data[root].items()
        ]
        roots.append('["%s"]={%s}' % (root, ','.join(entries)))
    return '{\n' + ',\n'.join(roots) + '\n}'


def prog_lua(data):
    """Serialise progressions.json to a Lua table literal."""
    moods = '{' + ','.join('"%s"' % m for m in data['moods']) + '}'
    items = []
    for p in data['progressions']:
        chords = ','.join('{%d,"%s"}' % (d, q) for d, q in p['chords'])
        name = p['name'].replace('\\', '\\\\').replace('"', '\\"')
        items.append('{mood="%s",name="%s",chords={%s}}' % (p['mood'], name, chords))
    return '{moods=%s,progressions={%s}}' % (moods, ','.join(items))


def strip_module(lua):
    """Turn harmony.lua from a module into an inlinable block of locals."""
    lua = lua.replace('local H = {}\n', '')
    lua = lua.replace("local NAMES = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}\n", '')
    lua = lua.replace('function H.analyze', 'local function analyze')
    lua = lua.replace('function H.diatonic', 'local function diatonicChords')
    lua = lua.replace('  local a = H.analyze(', '  local a = analyze(')
    lua = lua.replace('local Q = {', 'local QINFO = {')
    lua = lua.replace('local q = Q[quality] or Q.maj', 'local q = QINFO[quality] or QINFO.maj')
    return lua.replace('\nreturn H\n', '')


TEST_HOOK = """if _G.GCP_TEST then
  _G.GCP = {buildEvents=buildEvents, powerChord=powerChord, exportMidi=exportMidi,
            pitchesOf=pitchesOf, CHORDS=CHORDS, STRUM=STRUM, POWER=POWER, S=S,
            analyze=analyze, diatonicChords=diatonicChords, PROGS=PROGS,
            makeRiff=makeRiff, buildRiffEvents=buildRiffEvents, generateRiff=generateRiff,
            SCALES=SCALES, rootBaseOf=rootBaseOf,
            renderSongBars=renderSongBars, blockNatural=blockNatural, songLen=songLen,
            songSerialize=songSerialize, songDeserialize=songDeserialize,
            invertShape=invertShape, INV_QUALS=INV_QUALS}
  return
end

----------------------------------------------------------------------
-- ui"""


def build_reaper(data, progs):
    lua = open(os.path.join(SRC, 'reaper_template.lua')).read()
    harmony = strip_module(open(os.path.join(SRC, 'harmony.lua')).read())
    assert '--[[HARMONY]]' in lua, 'harmony placeholder missing'
    assert '--[[CHORD_DATA]]' in lua, 'chord data placeholder missing'
    assert '--[[PROG_DATA]]' in lua, 'progression data placeholder missing'
    lua = lua.replace('--[[HARMONY]]', harmony)
    lua = lua.replace('local CHORDS = --[[CHORD_DATA]]', 'local CHORDS = ' + lua_table(data))
    lua = lua.replace('local PROGS = --[[PROG_DATA]]', 'local PROGS = ' + prog_lua(progs))
    lua = lua.replace('__VERSION__', VERSION)
    lua = lua.replace(
        '----------------------------------------------------------------------\n-- ui',
        TEST_HOOK, 1)
    out = os.path.join(ROOT, 'reaper', 'GuitarChordPack.lua')
    open(out, 'w').write(lua)
    return out, len(lua)


def build_web(data, progs):
    html = open(os.path.join(SRC, 'web_template.html')).read()
    assert '/*CHORD_DATA*/' in html, 'chord data placeholder missing'
    assert '/*PROG_DATA*/' in html, 'progression data placeholder missing'
    html = html.replace('/*CHORD_DATA*/', json.dumps(data, separators=(',', ':')))
    html = html.replace('/*PROG_DATA*/', json.dumps(progs, separators=(',', ':')))
    html = html.replace('__VERSION__', VERSION)
    out = os.path.join(ROOT, 'web', 'guitar-audition.html')
    open(out, 'w').write(html)
    return out, len(html)


if __name__ == '__main__':
    data = chord_data()
    progs = prog_data()
    n = sum(len(v) for v in data.values())
    for path, size in (build_reaper(data, progs), build_web(data, progs)):
        print(f'{os.path.relpath(path, ROOT):34} {size/1024:6.1f} KB')
    print(f'{n} chord voicings embedded, {len(progs["progressions"])} progressions')
