// Chord inversions live in BOTH Lua (src/reaper_template.lua) and JS (src/web_template.html).
// This is the two-implementations-of-one-theory guard from CLAUDE.md: the JS invertShape must
// return the SAME hand-playable shape (or the same "no shape") as the Lua one for every
// root x quality x inversion. The search is deterministic, so parity is exact, not approximate.
const fs = require('fs');

// Read the BUILT web file so CHORDS is real data, not the /*CHORD_DATA*/ placeholder.
const html = fs.readFileSync('web/guitar-audition.html', 'utf8');

// Splice CHORDS, the constants, and the inversion engine into one scope and hand back the API.
const chordsSrc = html.slice(html.indexOf('const CHORDS ='), html.indexOf('const PROGS ='));
const engineSrc = html.slice(html.indexOf('const INV_QUALS'),
                             html.indexOf('/* ---------- functional harmony'));
if (!chordsSrc || !engineSrc.includes('function invertShape')) {
  console.error('could not locate CHORDS or the inversion engine in the built web file');
  process.exit(1);
}
const OPENsrc  = 'const OPEN=[40,45,50,55,59,64];';
const NAMESsrc = "const NAMES=['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];";
const { invertShape } = (0, eval)(                         // indirect eval: global scope, no name clash
  chordsSrc + '\n' + OPENsrc + '\n' + NAMESsrc + '\n' + engineSrc +
  '\n; ({ invertShape });');

const shapeStr = s => s ? s.map(f => f == null ? 'x' : String(f)).join(',') : 'nil';

let bad = 0;
const fail = (...a) => { bad++; console.log('FAIL', ...a); };

const dump = fs.readFileSync('build/lua_inversions.txt', 'utf8').trim().split('\n');
let checked = 0;
for (const line of dump) {
  const [root, qual, invStr, luaShape] = line.split('|');
  const js = shapeStr(invertShape(root, qual, +invStr));
  if (js !== luaShape) {
    fail(`${root} ${qual} inv ${invStr}\n  lua: ${luaShape}\n  js : ${js}`);
    if (bad > 8) break;
  }
  checked++;
}

console.log(`inversions(web): ${checked} shapes checked` + (bad ? ` — ${bad} FAILURES` : ' — all match Lua'));
process.exit(bad === 0 ? 0 : 1);
