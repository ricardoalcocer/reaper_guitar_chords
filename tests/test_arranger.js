// The arranger's note-generation and MIDI export are pure functions living in the
// ARRANGER CORE block of web_template.html. This slices that block (the same technique as
// test_parity.js) and asserts the musical invariants headlessly: pitches are OPEN[i]+fret,
// strum stagger equals the SPREAD constants, every Note-On has a matching Note-Off, no two
// notes overlap on the same string, and an empty strip produces no file.
const fs = require('fs');
const html = fs.readFileSync('src/web_template.html', 'utf8');

// --- real constants, pulled from the template so the test uses the shipped values ---
var OPEN, SPREAD;
eval('OPEN = '   + html.match(/const OPEN = (\[[^\]]*\]);/)[1]);
eval('SPREAD = ' + html.match(/const SPREAD = (\{[^}]*\});/)[1]);

// --- fixtures the core closes over (test inputs, not logic under test) ---
var NAMES = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];
var CHORDS = { C:{ maj:{ frets:[null,3,2,0,1,0], label:'C', dia:'x32010', notes:'', shape:'' } } };
var STRUM_PATS = { downs:['D',null,'D',null,'D',null,'D',null] };
var POWER_PATS = {};
function powerChord(){ return [null,null,null,null,null,null]; }

// --- the logic under test, sliced verbatim from the template ---
const coreStart = html.indexOf('function strokeEvents');
const coreEnd   = html.indexOf('/* ==================== END ARRANGER CORE');
if (coreStart < 0 || coreEnd < 0) { console.error('could not locate ARRANGER CORE block'); process.exit(1); }
eval(html.slice(coreStart, coreEnd));

let bad = 0;
function ok(cond, msg){ if(!cond){ console.log('FAIL: ' + msg); bad++; } }

// --- a minimal SMF parser (running-status aware) for the assertions ---
function parseSMF(bytes){
  const b = Array.from(bytes);
  const ascii = (o,n)=>b.slice(o,o+n).map(c=>String.fromCharCode(c)).join('');
  ok(ascii(0,4)==='MThd', 'header is MThd');
  const division = (b[12]<<8)|b[13];
  ok(ascii(14,4)==='MTrk', 'one MTrk chunk at offset 14');
  const trkLen = (b[18]<<24)|(b[19]<<16)|(b[20]<<8)|b[21];
  let i = 22, running = 0;
  const end = 22 + trkLen;
  const ons=[], offs=[];
  function vlqRead(){ let v=0,c; do{ c=b[i++]; v=(v<<7)|(c&0x7f); }while(c&0x80); return v; }
  let tick=0;
  while(i < end){
    tick += vlqRead();
    let status = b[i];
    if(status & 0x80){ i++; running = status; } else { status = running; }
    const hi = status & 0xf0;
    if(status === 0xFF){ const type=b[i++]; const len=vlqRead(); i+=len; }      // meta
    else if(hi === 0x90){ const n=b[i++], v=b[i++]; (v>0?ons:offs).push({tick,midi:n,vel:v}); }
    else if(hi === 0x80){ const n=b[i++]; i++; offs.push({tick,midi:n}); }
    else if(hi === 0xC0 || hi === 0xD0){ i++; }                                 // 1 data byte
    else { i+=2; }                                                              // other 2-byte
  }
  return {division, ons, offs, trkLen, trkEnd:end, total:b.length};
}

// ---------- Test 1: strokeEvents — pitches and SPREAD stagger (US1) ----------
{
  const frets = CHORDS.C.maj.frets;
  const evs = strokeEvents(frets, 'D');
  ok(evs.length === 5, 'C maj downstroke sounds 5 strings');
  evs.forEach((e,idx)=>{
    ok(e.midi === OPEN[e.si] + frets[e.si], `event ${idx}: midi == OPEN[i]+fret`);
    ok(Math.round(e.offBeat*480) === idx*14, `event ${idx}: stagger == ${idx*14} ticks (SPREAD.D)`);
    ok(e.art === 'open', `event ${idx}: downstroke is 'open'`);
  });
  const pitches = evs.map(e=>e.midi);
  ok(JSON.stringify(pitches) === JSON.stringify([48,52,55,60,64]), 'C maj pitches ascending 48,52,55,60,64');
}

// ---------- Test 2: arrangeToMidi — a one-chord strip (US3 contract) ----------
{
  const strip = { bpm:120, program:25, blocks:[
    { kind:'chord', source:'chords', root:'C', quality:'maj', palmMute:false, startBeat:0, lengthBeats:1 } ] };
  const bytes = arrangeToMidi(strip);
  ok(bytes instanceof Uint8Array, 'arrangeToMidi returns bytes');
  const m = parseSMF(bytes);
  ok(m.division === 480, `division == 480 (got ${m.division})`);
  ok(m.trkEnd === m.total, 'MTrk length prefix matches its content');
  ok(m.ons.length === 5 && m.offs.length === 5, `5 note-ons and 5 note-offs (got ${m.ons.length}/${m.offs.length})`);
  const onTicks = m.ons.map(o=>o.tick).sort((a,b)=>a-b);
  ok(JSON.stringify(onTicks) === JSON.stringify([0,14,28,42,56]), `note-on ticks staggered 0,14,28,42,56 (got ${onTicks})`);
  const onMidis = m.ons.map(o=>o.midi).sort((a,b)=>a-b);
  ok(JSON.stringify(onMidis) === JSON.stringify([48,52,55,60,64]), 'exported pitches match the voicing');
  // every note-on has a matching note-off on the same pitch
  const offMidis = m.offs.map(o=>o.midi).sort((a,b)=>a-b);
  ok(JSON.stringify(onMidis) === JSON.stringify(offMidis), 'every note-on has a matching note-off');
}

// ---------- Test 3: strum pattern block — no same-string overlap (US1/US2) ----------
{
  const strip = { bpm:120, program:25, blocks:[
    { kind:'pattern', source:'strum', root:'C', quality:'maj', patternId:'downs', startBeat:0, lengthBeats:4 } ] };
  const bytes = arrangeToMidi(strip);
  const m = parseSMF(bytes);
  // 'downs' fires 4 downstrokes of 5 notes each = 20 notes
  ok(m.ons.length === 20 && m.offs.length === 20, `20 note-ons/offs from a 4-hit pattern (got ${m.ons.length}/${m.offs.length})`);
  // reconstruct per-pitch intervals and assert none overlap on the same pitch/string
  const byMidi = {};
  m.ons.forEach(o=>{ (byMidi[o.midi]=byMidi[o.midi]||[]).push({on:o.tick}); });
  // pair each on with the nearest following off of the same midi
  m.offs.forEach(f=>{ const list=byMidi[f.midi]; if(!list) return;
    const open=list.filter(x=>x.off===undefined && x.on<=f.tick).sort((a,b)=>b.on-a.on)[0];
    if(open) open.off=f.tick; });
  let overlaps=0;
  Object.values(byMidi).forEach(list=>{ list.sort((a,b)=>a.on-b.on);
    for(let i=0;i<list.length-1;i++){ if(list[i].off===undefined || list[i].off > list[i+1].on) overlaps++; } });
  ok(overlaps === 0, `no two notes overlap on the same string (found ${overlaps})`);
}

// ---------- Test 4: empty strip exports nothing (FR-015) ----------
{
  ok(arrangeToMidi({ bpm:120, blocks:[] }) === null, 'empty strip -> arrangeToMidi returns null');
}

console.log(`arranger: ${bad === 0 ? 'all checks passed' : bad + ' FAILURES'}`);
process.exit(bad === 0 ? 0 : 1);
