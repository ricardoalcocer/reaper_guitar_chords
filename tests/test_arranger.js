// The song model + MIDI export are pure functions in the ARRANGER CORE block of
// web_template.html. This slices that block (like test_parity.js) and asserts the model
// the user specified: blocks are loops measured in quarter-note BEATS; a single chord is ONE
// strum (not a fabricated pattern); stretching REPEATS the loop's notes (partial loops allowed);
// pitches are OPEN[i]+fret; every Note-On has a matching Note-Off; empty song exports nothing.
const fs = require('fs');
const html = fs.readFileSync('src/web_template.html', 'utf8');

var OPEN, SPREAD;
eval('OPEN = '   + html.match(/const OPEN = (\[[^\]]*\]);/)[1]);
eval('SPREAD = ' + html.match(/const SPREAD = (\{[^}]*\});/)[1]);

var NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];
var CHORDS = { C:{ maj:{ frets:[null,3,2,0,1,0], label:'C' } }, G:{ maj:{ frets:[3,2,0,0,0,3], label:'G' } } };
var STRUM_PATS = { downs:['D',null,'D',null,'D',null,'D',null] };   // 4 downstrokes over 1 bar
var POWER_PATS = {};
function powerChord(root){ return [ (NAMES.indexOf(root)+12-4)%12, 0,0,0,0,0 ]; }

const coreStart = html.indexOf('function strokeEvents');
const coreEnd   = html.indexOf('/* ==================== END ARRANGER CORE');
if (coreStart < 0 || coreEnd < 0) { console.error('could not locate ARRANGER CORE block'); process.exit(1); }
eval(html.slice(coreStart, coreEnd));

let bad = 0;
function ok(cond, msg){ if(!cond){ console.log('FAIL: ' + msg); bad++; } }

function parseSMF(bytes){
  const b = Array.from(bytes);
  const ascii = (o,n)=>b.slice(o,o+n).map(c=>String.fromCharCode(c)).join('');
  ok(ascii(0,4)==='MThd', 'header is MThd');
  const division = (b[12]<<8)|b[13];
  ok(ascii(14,4)==='MTrk', 'one MTrk chunk');
  const trkLen = (b[18]<<24)|(b[19]<<16)|(b[20]<<8)|b[21];
  let i=22, running=0, tick=0, end=22+trkLen; const ons=[], offs=[];
  const vlq=()=>{ let v=0,c; do{ c=b[i++]; v=(v<<7)|(c&0x7f); }while(c&0x80); return v; };
  while(i<end){
    tick+=vlq(); let s=b[i]; if(s&0x80){i++;running=s;}else s=running; const hi=s&0xf0;
    if(s===0xFF){ i++; const l=vlq(); i+=l; }
    else if(hi===0x90){ const n=b[i++],v=b[i++]; (v>0?ons:offs).push({tick,midi:n,vel:v}); }
    else if(hi===0x80){ const n=b[i++]; i++; offs.push({tick,midi:n}); }
    else if(hi===0xC0||hi===0xD0){ i++; } else { i+=2; }
  }
  return {division, ons, offs, trkEnd:end, total:b.length};
}
const noteOns = (strip)=> parseSMF(arrangeToMidi(strip)).ons.length;

// ---------- 1: strokeEvents pitches + SPREAD stagger ----------
{
  const evs = strokeEvents(CHORDS.C.maj.frets,'D');
  ok(evs.length===5, 'C maj downstroke = 5 strings');
  evs.forEach((e,idx)=>{
    ok(e.midi===OPEN[e.si]+CHORDS.C.maj.frets[e.si], `event ${idx}: midi == OPEN[i]+fret`);
    ok(Math.round(e.offBeat*480)===idx*14, `event ${idx}: stagger == ${idx*14} ticks`);
  });
}

// ---------- 2: a single CHORD block is ONE strum (the bug the user hit) ----------
{
  const m = parseSMF(arrangeToMidi({ bpm:120, blocks:[
    { source:'chord', root:'C', quality:'maj', startBeat:0, lenBeats:4 } ] }));
  ok(m.division===480, `division == 480 (got ${m.division})`);
  ok(m.trkEnd===m.total, 'MTrk length prefix matches content');
  ok(m.ons.length===5 && m.offs.length===5, `one chord = ONE strum = 5 notes, NOT a pattern (got ${m.ons.length})`);
  const onTicks=m.ons.map(o=>o.tick).sort((a,b)=>a-b);
  ok(JSON.stringify(onTicks)===JSON.stringify([0,14,28,42,56]), `single strum, staggered 0,14,28,42,56 (got ${onTicks})`);
  const onMidis=m.ons.map(o=>o.midi).sort((a,b)=>a-b);
  ok(JSON.stringify(onMidis)===JSON.stringify([48,52,55,60,64]), 'pitches match the C-maj voicing');
}

// ---------- 3: stretching a groove REPEATS its notes ----------
{
  const mk=(len)=>({ bpm:120, blocks:[ { source:'strum', root:'C', quality:'maj', patternId:'downs', startBeat:0, lenBeats:len } ] });
  const n4=noteOns(mk(4)), n8=noteOns(mk(8)), n12=noteOns(mk(12));
  ok(n4===20, `1-bar 'downs' groove = 4 downstrokes × 5 = 20 notes (got ${n4})`);
  ok(n8===40, `2 bars = 2× the notes (${n4} -> ${n8})`);
  ok(n12===60, `3 bars = 3× the notes (${n4} -> ${n12})`);
}

// ---------- 4: stretch snaps to the BEAT — a partial stretch plays a partial loop ----------
{
  const mk=(len)=>({ bpm:120, blocks:[ { source:'strum', root:'C', quality:'maj', patternId:'downs', startBeat:0, lenBeats:len } ] });
  // 'downs' hits on beats 0,1,2,3. Stretch 4 -> 5 beats: adds beat-4 (= loop's beat 0) hit only.
  ok(noteOns(mk(5))===25, `+1 beat adds one more downstroke = 25 notes (got ${noteOns(mk(5))})`);
  ok(noteOns(mk(6))===30, `+2 beats adds two downstrokes = 30 notes (got ${noteOns(mk(6))})`);
}

// ---------- 5: a single chord stretched repeats per bar (still not 4 strums) ----------
{
  const mk=(len)=>({ bpm:120, blocks:[ { source:'chord', root:'C', quality:'maj', startBeat:0, lenBeats:len } ] });
  ok(noteOns(mk(4))===5,  `1 bar = 1 strum = 5 notes (got ${noteOns(mk(4))})`);
  ok(noteOns(mk(8))===10, `2 bars = 2 strums = 10 notes, i.e. one strum per bar (got ${noteOns(mk(8))})`);
}

// ---------- 6: a progression is a multi-bar loop; stacking positions by beat ----------
{
  const strip={ bpm:120, blocks:[
    { source:'prog', chords:[{root:'C',quality:'maj'},{root:'G',quality:'maj'}], patternId:'downs', startBeat:0, lenBeats:8 },
    { source:'strum', root:'C', quality:'maj', patternId:'downs', startBeat:8, lenBeats:4 } ]};
  const m=parseSMF(arrangeToMidi(strip));
  const firstOfSecond = Math.min(...m.ons.filter(o=>o.tick>=8*480).map(o=>o.tick));
  ok(firstOfSecond===8*480, `stacked block starts exactly at beat 8 (tick ${8*480}, got ${firstOfSecond})`);
  ok(m.ons.length===m.offs.length, 'every note-on has a matching note-off');
}

// ---------- 7: empty song exports nothing ----------
{
  ok(arrangeToMidi({ bpm:120, blocks:[] })===null, 'empty song -> arrangeToMidi returns null');
}

console.log(`arranger: ${bad===0 ? 'all checks passed' : bad+' FAILURES'}`);
process.exit(bad===0 ? 0 : 1);
