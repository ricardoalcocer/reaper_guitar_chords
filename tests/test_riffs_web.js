// The riff generator is implemented in BOTH Lua (src/reaper_template.lua) and JS
// (src/web_template.html). This is the two-implementations-of-one-theory guard from CLAUDE.md:
//   1) PARITY  — the JS makeRiff line must match the Lua one for every scale x rhythm x seed.
//   2) INVARIANTS — the web riff block's note events must be sane (in scale, in range, no
//      same-string restrike before a note ends), the web analogue of tests/test_riffs.lua.
const fs = require('fs');
const html = fs.readFileSync('src/web_template.html', 'utf8');

// --- pull the literal constants the engine needs, then eval the ARRANGER CORE (like test_arranger) ---
const NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];
var OPEN, SPREAD, POWER_PATS, b4;
eval('OPEN = '   + html.match(/const OPEN = (\[[^\]]*\]);/)[1]);
eval('SPREAD = ' + html.match(/const SPREAD = (\{[^}]*\});/)[1]);
{ const s = html.indexOf('const b4 =');
  const e = html.indexOf('};', html.indexOf('const POWER_PATS')) + 2;
  eval(html.slice(s, e).replace(/\bconst /g, '')); }         // assign b4 + POWER_PATS to the outer vars (const won't leak out of eval)
// stubs only referenced by non-riff block code paths (never called here), so eval succeeds:
var CHORDS = {}, STRUM_PATS = {}; function powerChord(){ return [null,null,null,null,null,null]; }

const coreStart = html.indexOf('function strokeEvents');
const coreEnd   = html.indexOf('/* ==================== END ARRANGER CORE');
if (coreStart < 0 || coreEnd < 0) { console.error('could not locate ARRANGER CORE block'); process.exit(1); }
eval(html.slice(coreStart, coreEnd));                        // defines makeRiff, fretFor, rootBaseOf, block*, RIFF_*

let bad = 0;
const fail = (...a) => { bad++; console.log('FAIL', ...a); };

// ---------- 1) PARITY against the Lua dump ----------
const dump = fs.readFileSync('build/lua_riffs.txt', 'utf8').trim().split('\n');
let checked = 0;
for (const line of dump) {
  const [scaleKey, riStr, seedStr, stepsStr] = line.split('|');
  const ri = +riStr, seed = +seedStr;
  const r = makeRiff('E', scaleKey, ri, seed);
  const js = r.steps.map(st => st ? (st.iv + ':' + st.art) : '.').join(',');
  if (js !== stepsStr) { fail(`parity ${scaleKey} rhythm ${ri} seed ${seed}\n  lua: ${stepsStr}\n  js : ${js}`); if (bad > 8) break; }
  checked++;
}

// ---------- 2) web riff-block INVARIANTS — every combo from the dump, across a few roots ----------
const inScale = (iv, semis) => iv.includes(((semis % 12) + 12) % 12);
let combos = 0, events = 0;
for (const line of dump) {
  const [scaleKey, riStr, seedStr] = line.split('|');
  const ri = +riStr, seed = +seedStr;
  const iv = makeRiff('E', scaleKey, ri, seed).scale.iv;     // scale intervals (root-independent)
  for (const root of ['C','E','F','A','B']) {
    const b = { source:'riff', root, scale:scaleKey, rhythmIdx:ri, seed };
    b.lenBeats = blockLoopBeats(b);
    if (!(b.lenBeats >= 1)) { fail('riff lenBeats < 1', root, scaleKey, ri, seed); continue; }
    const ev = blockNoteEvents(b, 120);
    if (ev.length === 0) { fail('no events', root, scaleKey, ri, seed); continue; }
    const rb = rootBaseOf(root), bySi = {};
    for (const e of ev) {
      if (e.vel < 1 || e.vel > 127)    fail('vel out of range', e.vel, root, scaleKey, ri, seed);
      if (e.endBeat <= e.startBeat)     fail('non-positive length', root, scaleKey, ri, seed);
      if (e.midi < 40 || e.midi > 90)   fail('pitch out of range', e.midi, root, scaleKey, ri, seed);
      if (!inScale(iv, e.midi - rb))    fail('note out of scale', e.midi - rb, scaleKey, ri, seed);
      (bySi[e.si] = bySi[e.si] || []).push(e);
    }
    for (const k of Object.keys(bySi)) {                      // no string restruck before its note ends
      const l = bySi[k].sort((a, b2) => a.startBeat - b2.startBeat);
      for (let i = 0; i < l.length - 1; i++)
        if (l[i + 1].startBeat < l[i].endBeat - 1e-6) fail('same-string overlap', root, scaleKey, ri, seed);
    }
    combos++; events += ev.length;
  }
}

console.log(`riffs(web): ${checked} parity lines ok, ${combos} blocks / ${events} events checked` + (bad ? ` — ${bad} FAILURES` : ' — all passed'));
process.exit(bad === 0 ? 0 : 1);
