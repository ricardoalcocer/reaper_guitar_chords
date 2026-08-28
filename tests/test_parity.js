// The JS harmony in web_template.html must agree with src/harmony.lua exactly.
// Two implementations of the same theory drift silently; this catches it.
const fs = require('fs');
const NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];
const QUALS = ['maj','m','7','m7','maj7','m7b5','dim7','dim','aug','sus2','sus4',
               '7sus4','6','m6','9','add9','5',
               'maj9','m9','m11','13','13sus4','9sus4','6/9','m6/9','add11','mMaj7','7alt'];

const html = fs.readFileSync('src/web_template.html', 'utf8');
const start = html.indexOf('const QINFO');
const end = html.indexOf('/* ---------- audio');
if (start < 0 || end < 0) { console.error('could not locate harmony block'); process.exit(1); }
eval(html.slice(start, end));

const lines = fs.readFileSync('build/lua_analysis.txt', 'utf8').trim().split('\n');
let bad = 0;
for (const line of lines) {
  const [key, mode, chord, q, numeral, func] = line.split('|');
  const r = analyze(+key, mode, +chord, q);
  if (r.numeral !== numeral || r.func !== func) {
    if (bad < 10) {
      console.log(`MISMATCH key=${NAMES[+key]} ${mode} chord=${NAMES[+chord]}${q}` +
                  `  lua=${numeral}/${func}  js=${r.numeral}/${r.func}`);
    }
    bad++;
  }
}
console.log(`${lines.length} results compared, ${bad} mismatches`);
process.exit(bad === 0 ? 0 : 1);
