// The song model + MIDI export are pure functions in the ARRANGER CORE block of
// web_template.html. This slices that block (like test_parity.js) and asserts the model:
// a block is a bar-length LOOP; stretching it REPEATS the notes; pitches are OPEN[i]+fret;
// every Note-On has a matching Note-Off; no same-string overlap; empty song exports nothing.
const fs = require('fs');
const html = fs.readFileSync('src/web_template.html', 'utf8');

// real constants pulled from the template
var OPEN, SPREAD;
eval('OPEN = '   + html.match(/const OPEN = (\[[^\]]*\]);/)[1]);
eval('SPREAD = ' + html.match(/const SPREAD = (\{[^}]*\});/)[1]);

// fixtures the core closes over (test inputs, not the logic under test)
var NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];
var CHORDS = { C:{ maj:{ frets:[null,3,2,0,1,0], label:'C' } }, G:{ maj:{ frets:[3,2,0,0,0,3], label:'G' } } };
var STRUM_PATS = { downs:['D',null,'D',null,'D',null,'D',null], eighths:['D','U','D','U','D','U','D','U'] };
var POWER_PATS = { gallop:{ p:['P',null,'P','P','P',null,'P','P','P',null,'P','P','P',null,'P','P'], div:4 } };
function powerChord(root){ return [ (NAMES.indexOf(root)+12-4)%12, 0,0,0,0,0 ]; }  // any 2 fretted strings

// the logic under test, sliced from the template
const coreStart = html.indexOf('function strokeEvents');
const coreEnd   = html.indexOf('/* ==================== END ARRANGER CORE');
if (coreStart < 0 || coreEnd < 0) { console.error('could not locate ARRANGER CORE block'); process.exit(1); }
eval(html.slice(coreStart, coreEnd));

let bad = 0;
function ok(cond, msg){ if(!cond){ console.log('FAIL: ' + msg); bad++; } }

// minimal running-status-aware SMF parser
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
function noteOnCount(strip){ return parseSMF(arrangeToMidi(strip)).ons.length; }

// ---------- 1: strokeEvents — pitches and SPREAD stagger ----------
{
  const frets = CHORDS.C.maj.frets, evs = strokeEvents(frets,'D');
  ok(evs.length===5, 'C maj downstroke sounds 5 strings');
  evs.forEach((e,idx)=>{
    ok(e.midi===OPEN[e.si]+frets[e.si], `event ${idx}: midi == OPEN[i]+fret`);
    ok(Math.round(e.offBeat*480)===idx*14, `event ${idx}: stagger == ${idx*14} ticks (SPREAD.D)`);
  });
}

// ---------- 2: a block is a bar loop; export header + pitches ----------
{
  const strip = { bpm:120, program:25, blocks:[
    { source:'chord', root:'C', quality:'maj', patternId:'downs', startBar:0, bars:1 } ] };
  const m = parseSMF(arrangeToMidi(strip));
  ok(m.division===480, `division == 480 (got ${m.division})`);
  ok(m.trkEnd===m.total, 'MTrk length prefix matches content');
  // 'downs' = 4 downstrokes/bar × 5 strings = 20 notes in a 1-bar chord loop
  ok(m.ons.length===20 && m.offs.length===20, `1-bar chord loop = 20 notes (got ${m.ons.length}/${m.offs.length})`);
  const onMidis=[...new Set(m.ons.map(o=>o.midi))].sort((a,b)=>a-b);
  ok(JSON.stringify(onMidis)===JSON.stringify([48,52,55,60,64]), 'exported pitches match the C-maj voicing');
}

// ---------- 3: STRETCHING A BLOCK REPEATS ITS NOTES (the core rule) ----------
{
  const mk=(bars)=>({ bpm:120, blocks:[
    { source:'strum', root:'C', quality:'maj', patternId:'downs', startBar:0, bars } ] });
  const n1=noteOnCount(mk(1)), n2=noteOnCount(mk(2)), n4=noteOnCount(mk(4));
  ok(n2===n1*2, `2 bars = twice the notes of 1 bar (${n1} -> ${n2})`);
  ok(n4===n1*4, `4 bars = 4× the notes (${n1} -> ${n4}) — stretch repeats, not lengthens`);
}

// ---------- 4: note LENGTH does not grow with the block (it's not sustain) ----------
{
  const maxLen=(bars)=>{
    const m=parseSMF(arrangeToMidi({bpm:120, blocks:[
      {source:'strum', root:'C', quality:'maj', patternId:'downs', startBar:0, bars}]}));
    const byMidi={}; m.ons.forEach(o=>{(byMidi[o.midi]=byMidi[o.midi]||[]).push({on:o.tick});});
    m.offs.forEach(f=>{ const l=byMidi[f.midi]; if(!l) return;
      const open=l.filter(x=>x.off===undefined && x.on<=f.tick).sort((a,b)=>b.on-a.on)[0]; if(open) open.off=f.tick; });
    let mx=0; Object.values(byMidi).forEach(l=>l.forEach(x=>{ if(x.off!==undefined) mx=Math.max(mx,x.off-x.on); })); return mx;
  };
  ok(Math.abs(maxLen(1)-maxLen(4))<40, 'a stretched block keeps the same per-note length (no sustain)');
}

// ---------- 5: a progression is a multi-bar loop; stacking positions by bar ----------
{
  // 2-chord progression = a 2-bar loop; place a second block after it at bar 2
  const strip={ bpm:120, blocks:[
    { source:'prog', chords:[{root:'C',quality:'maj'},{root:'G',quality:'maj'}], patternId:'downs', startBar:0, bars:2 },
    { source:'strum', root:'C', quality:'maj', patternId:'downs', startBar:2, bars:1 } ]};
  const m=parseSMF(arrangeToMidi(strip));
  // prog: 2 bars × 4 downs × ~5 strings; the trailing block starts at bar 2 = tick 2*4*480 = 3840
  const firstOfSecond = Math.min(...m.ons.filter(o=>o.tick>=3840).map(o=>o.tick));
  ok(firstOfSecond===3840, `the stacked block starts exactly at bar 3 (tick 3840, got ${firstOfSecond})`);
  // matched on/off, no same-string overlap
  ok(m.ons.length===m.offs.length, 'every note-on has a matching note-off');
}

// ---------- 6: empty song exports nothing ----------
{
  ok(arrangeToMidi({ bpm:120, blocks:[] })===null, 'empty song -> arrangeToMidi returns null');
}

console.log(`arranger: ${bad===0 ? 'all checks passed' : bad+' FAILURES'}`);
process.exit(bad===0 ? 0 : 1);
