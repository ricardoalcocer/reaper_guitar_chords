--[[
  Guitar Songwriter - audition, arrange and insert
  @description Guitar Songwriter: audition chords, power chords, progressions and
               procedural riffs through the selected track's instrument, arrange
               them on the song lane, and insert the result as MIDI at the cursor.
  @author generated for REAPER, no extensions required
  @version 2.14.1+ef73f0d
--]]

local VERSION = "2.14.1+ef73f0d"

----------------------------------------------------------------------
-- data
----------------------------------------------------------------------
local CHORDS = {
["C"]={["maj"]={label="C",frets={false,3,2,0,1,0},dia="x32010",shape="open",notes="C3 E3 G3 C4 E4"},["m"]={label="Cm",frets={false,3,5,5,4,3},dia="x35543",shape="A-shape @3",notes="C3 G3 C4 Eb4 G4"},["7"]={label="C7",frets={false,3,2,3,1,0},dia="x32310",shape="open",notes="C3 E3 Bb3 C4 E4"},["m7"]={label="Cm7",frets={false,3,5,3,4,3},dia="x35343",shape="A-shape @3",notes="C3 G3 Bb3 Eb4 G4"},["maj7"]={label="Cmaj7",frets={false,3,2,0,0,0},dia="x32000",shape="open",notes="C3 E3 G3 B3 E4"},["m7b5"]={label="Cm7b5",frets={false,3,4,3,4,false},dia="x3434x",shape="A-shape @3",notes="C3 Gb3 Bb3 Eb4"},["dim7"]={label="Cdim7",frets={false,3,4,2,4,false},dia="x3424x",shape="A-shape @3",notes="C3 Gb3 A3 Eb4"},["dim"]={label="Cdim",frets={false,3,4,5,4,false},dia="x3454x",shape="A-shape @3",notes="C3 Gb3 C4 Eb4"},["aug"]={label="Caug",frets={false,3,6,5,5,4},dia="x36554",shape="A-shape @3",notes="C3 Ab3 C4 E4 Ab4"},["sus2"]={label="Csus2",frets={false,3,5,5,3,3},dia="x35533",shape="A-shape @3",notes="C3 G3 C4 D4 G4"},["sus4"]={label="Csus4",frets={false,3,5,5,6,3},dia="x35563",shape="A-shape @3",notes="C3 G3 C4 F4 G4"},["7sus4"]={label="C7sus4",frets={false,3,5,3,6,3},dia="x35363",shape="A-shape @3",notes="C3 G3 Bb3 F4 G4"},["6"]={label="C6",frets={false,3,5,5,5,5},dia="x35555",shape="A-shape @3",notes="C3 G3 C4 E4 A4"},["m6"]={label="Cm6",frets={false,3,5,5,4,5},dia="x35545",shape="A-shape @3",notes="C3 G3 C4 Eb4 A4"},["9"]={label="C9",frets={false,3,2,3,3,3},dia="x32333",shape="A-shape @3",notes="C3 E3 Bb3 D4 G4"},["add9"]={label="Cadd9",frets={false,3,2,0,3,0},dia="x32030",shape="open",notes="C3 E3 G3 D4 E4"},["maj9"]={label="Cmaj9",frets={false,3,2,4,3,3},dia="x32433",shape="A-shape @3",notes="C3 E3 B3 D4 G4"},["m9"]={label="Cm9",frets={false,3,1,3,3,3},dia="x31333",shape="A-shape @3",notes="C3 Eb3 Bb3 D4 G4"},["m11"]={label="Cm11",frets={false,3,1,3,1,1},dia="x31311",shape="A-shape @3",notes="C3 Eb3 Bb3 C4 F4"},["13"]={label="C13",frets={false,3,2,3,1,5},dia="x32315",shape="A-shape @3",notes="C3 E3 Bb3 C4 A4"},["13sus4"]={label="C13sus4",frets={false,3,3,3,1,5},dia="x33315",shape="A-shape @3",notes="C3 F3 Bb3 C4 A4"},["9sus4"]={label="C9sus4",frets={false,3,3,3,3,3},dia="x33333",shape="A-shape @3",notes="C3 F3 Bb3 D4 G4"},["6/9"]={label="C6/9",frets={false,3,2,2,3,3},dia="x32233",shape="A-shape @3",notes="C3 E3 A3 D4 G4"},["m6/9"]={label="Cm6/9",frets={false,3,1,2,3,3},dia="x31233",shape="A-shape @3",notes="C3 Eb3 A3 D4 G4"},["add11"]={label="Cadd11",frets={false,3,3,5,5,3},dia="x33553",shape="A-shape @3",notes="C3 F3 C4 E4 G4"},["mMaj7"]={label="CmMaj7",frets={false,3,1,4,1,3},dia="x31413",shape="A-shape @3",notes="C3 Eb3 B3 C4 G4"},["7alt"]={label="C7alt",frets={false,3,2,3,4,3},dia="x32343",shape="A-shape @3",notes="C3 E3 Bb3 Eb4 G4"},["5"]={label="C5",frets={false,3,5,5,false,false},dia="x355xx",shape="A-shape @3",notes="C3 G3 C4"}},
["Db"]={["maj"]={label="Db",frets={false,4,6,6,6,4},dia="x46664",shape="A-shape @4",notes="Db3 Ab3 Db4 F4 Ab4"},["m"]={label="Dbm",frets={false,4,6,6,5,4},dia="x46654",shape="A-shape @4",notes="Db3 Ab3 Db4 E4 Ab4"},["7"]={label="Db7",frets={false,4,6,4,6,4},dia="x46464",shape="A-shape @4",notes="Db3 Ab3 B3 F4 Ab4"},["m7"]={label="Dbm7",frets={false,4,6,4,5,4},dia="x46454",shape="A-shape @4",notes="Db3 Ab3 B3 E4 Ab4"},["maj7"]={label="Dbmaj7",frets={false,4,6,5,6,4},dia="x46564",shape="A-shape @4",notes="Db3 Ab3 C4 F4 Ab4"},["m7b5"]={label="Dbm7b5",frets={false,4,5,4,5,false},dia="x4545x",shape="A-shape @4",notes="Db3 G3 B3 E4"},["dim7"]={label="Dbdim7",frets={false,4,5,3,5,false},dia="x4535x",shape="A-shape @4",notes="Db3 G3 Bb3 E4"},["dim"]={label="Dbdim",frets={false,4,5,6,5,false},dia="x4565x",shape="A-shape @4",notes="Db3 G3 Db4 E4"},["aug"]={label="Dbaug",frets={false,4,7,6,6,5},dia="x47665",shape="A-shape @4",notes="Db3 A3 Db4 F4 A4"},["sus2"]={label="Dbsus2",frets={false,4,6,6,4,4},dia="x46644",shape="A-shape @4",notes="Db3 Ab3 Db4 Eb4 Ab4"},["sus4"]={label="Dbsus4",frets={false,4,6,6,7,4},dia="x46674",shape="A-shape @4",notes="Db3 Ab3 Db4 Gb4 Ab4"},["7sus4"]={label="Db7sus4",frets={false,4,6,4,7,4},dia="x46474",shape="A-shape @4",notes="Db3 Ab3 B3 Gb4 Ab4"},["6"]={label="Db6",frets={false,4,6,6,6,6},dia="x46666",shape="A-shape @4",notes="Db3 Ab3 Db4 F4 Bb4"},["m6"]={label="Dbm6",frets={false,4,6,6,5,6},dia="x46656",shape="A-shape @4",notes="Db3 Ab3 Db4 E4 Bb4"},["9"]={label="Db9",frets={false,4,3,4,4,4},dia="x43444",shape="A-shape @4",notes="Db3 F3 B3 Eb4 Ab4"},["add9"]={label="Dbadd9",frets={false,4,6,8,6,4},dia="x46864",shape="A-shape @4",notes="Db3 Ab3 Eb4 F4 Ab4"},["maj9"]={label="Dbmaj9",frets={false,4,3,5,4,4},dia="x43544",shape="A-shape @4",notes="Db3 F3 C4 Eb4 Ab4"},["m9"]={label="Dbm9",frets={false,4,2,4,4,4},dia="x42444",shape="A-shape @4",notes="Db3 E3 B3 Eb4 Ab4"},["m11"]={label="Dbm11",frets={false,4,2,4,2,2},dia="x42422",shape="A-shape @4",notes="Db3 E3 B3 Db4 Gb4"},["13"]={label="Db13",frets={false,4,3,4,2,6},dia="x43426",shape="A-shape @4",notes="Db3 F3 B3 Db4 Bb4"},["13sus4"]={label="Db13sus4",frets={false,4,4,4,2,6},dia="x44426",shape="A-shape @4",notes="Db3 Gb3 B3 Db4 Bb4"},["9sus4"]={label="Db9sus4",frets={false,4,4,4,4,4},dia="x44444",shape="A-shape @4",notes="Db3 Gb3 B3 Eb4 Ab4"},["6/9"]={label="Db6/9",frets={false,4,3,3,4,4},dia="x43344",shape="A-shape @4",notes="Db3 F3 Bb3 Eb4 Ab4"},["m6/9"]={label="Dbm6/9",frets={false,4,2,3,4,4},dia="x42344",shape="A-shape @4",notes="Db3 E3 Bb3 Eb4 Ab4"},["add11"]={label="Dbadd11",frets={false,4,4,6,6,4},dia="x44664",shape="A-shape @4",notes="Db3 Gb3 Db4 F4 Ab4"},["mMaj7"]={label="DbmMaj7",frets={false,4,2,5,2,4},dia="x42524",shape="A-shape @4",notes="Db3 E3 C4 Db4 Ab4"},["7alt"]={label="Db7alt",frets={false,4,3,4,5,4},dia="x43454",shape="A-shape @4",notes="Db3 F3 B3 E4 Ab4"},["5"]={label="Db5",frets={false,4,6,6,false,false},dia="x466xx",shape="A-shape @4",notes="Db3 Ab3 Db4"}},
["D"]={["maj"]={label="D",frets={false,false,0,2,3,2},dia="xx0232",shape="open",notes="D3 A3 D4 Gb4"},["m"]={label="Dm",frets={false,false,0,2,3,1},dia="xx0231",shape="open",notes="D3 A3 D4 F4"},["7"]={label="D7",frets={false,false,0,2,1,2},dia="xx0212",shape="open",notes="D3 A3 C4 Gb4"},["m7"]={label="Dm7",frets={false,false,0,2,1,1},dia="xx0211",shape="open",notes="D3 A3 C4 F4"},["maj7"]={label="Dmaj7",frets={false,false,0,2,2,2},dia="xx0222",shape="open",notes="D3 A3 Db4 Gb4"},["m7b5"]={label="Dm7b5",frets={false,5,6,5,6,false},dia="x5656x",shape="A-shape @5",notes="D3 Ab3 C4 F4"},["dim7"]={label="Ddim7",frets={false,5,6,4,6,false},dia="x5646x",shape="A-shape @5",notes="D3 Ab3 B3 F4"},["dim"]={label="Ddim",frets={false,5,6,7,6,false},dia="x5676x",shape="A-shape @5",notes="D3 Ab3 D4 F4"},["aug"]={label="Daug",frets={false,5,8,7,7,6},dia="x58776",shape="A-shape @5",notes="D3 Bb3 D4 Gb4 Bb4"},["sus2"]={label="Dsus2",frets={false,false,0,2,3,0},dia="xx0230",shape="open",notes="D3 A3 D4 E4"},["sus4"]={label="Dsus4",frets={false,false,0,2,3,3},dia="xx0233",shape="open",notes="D3 A3 D4 G4"},["7sus4"]={label="D7sus4",frets={false,5,7,5,8,5},dia="x57585",shape="A-shape @5",notes="D3 A3 C4 G4 A4"},["6"]={label="D6",frets={false,false,0,2,0,2},dia="xx0202",shape="open",notes="D3 A3 B3 Gb4"},["m6"]={label="Dm6",frets={false,5,7,7,6,7},dia="x57767",shape="A-shape @5",notes="D3 A3 D4 F4 B4"},["9"]={label="D9",frets={false,5,4,5,5,5},dia="x54555",shape="A-shape @5",notes="D3 Gb3 C4 E4 A4"},["add9"]={label="Dadd9",frets={false,5,7,9,7,5},dia="x57975",shape="A-shape @5",notes="D3 A3 E4 Gb4 A4"},["maj9"]={label="Dmaj9",frets={false,5,4,6,5,5},dia="x54655",shape="A-shape @5",notes="D3 Gb3 Db4 E4 A4"},["m9"]={label="Dm9",frets={false,5,3,5,5,5},dia="x53555",shape="A-shape @5",notes="D3 F3 C4 E4 A4"},["m11"]={label="Dm11",frets={false,5,3,5,3,3},dia="x53533",shape="A-shape @5",notes="D3 F3 C4 D4 G4"},["13"]={label="D13",frets={false,5,4,5,3,7},dia="x54537",shape="A-shape @5",notes="D3 Gb3 C4 D4 B4"},["13sus4"]={label="D13sus4",frets={false,5,5,5,3,7},dia="x55537",shape="A-shape @5",notes="D3 G3 C4 D4 B4"},["9sus4"]={label="D9sus4",frets={false,5,5,5,5,5},dia="x55555",shape="A-shape @5",notes="D3 G3 C4 E4 A4"},["6/9"]={label="D6/9",frets={false,5,4,4,5,5},dia="x54455",shape="A-shape @5",notes="D3 Gb3 B3 E4 A4"},["m6/9"]={label="Dm6/9",frets={false,5,3,4,5,5},dia="x53455",shape="A-shape @5",notes="D3 F3 B3 E4 A4"},["add11"]={label="Dadd11",frets={false,5,5,7,7,5},dia="x55775",shape="A-shape @5",notes="D3 G3 D4 Gb4 A4"},["mMaj7"]={label="DmMaj7",frets={false,5,3,6,3,5},dia="x53635",shape="A-shape @5",notes="D3 F3 Db4 D4 A4"},["7alt"]={label="D7alt",frets={false,5,4,5,6,5},dia="x54565",shape="A-shape @5",notes="D3 Gb3 C4 F4 A4"},["5"]={label="D5",frets={false,5,7,7,false,false},dia="x577xx",shape="A-shape @5",notes="D3 A3 D4"}},
["Eb"]={["maj"]={label="Eb",frets={false,6,8,8,8,6},dia="x68886",shape="A-shape @6",notes="Eb3 Bb3 Eb4 G4 Bb4"},["m"]={label="Ebm",frets={false,6,8,8,7,6},dia="x68876",shape="A-shape @6",notes="Eb3 Bb3 Eb4 Gb4 Bb4"},["7"]={label="Eb7",frets={false,6,8,6,8,6},dia="x68686",shape="A-shape @6",notes="Eb3 Bb3 Db4 G4 Bb4"},["m7"]={label="Ebm7",frets={false,6,8,6,7,6},dia="x68676",shape="A-shape @6",notes="Eb3 Bb3 Db4 Gb4 Bb4"},["maj7"]={label="Ebmaj7",frets={false,6,8,7,8,6},dia="x68786",shape="A-shape @6",notes="Eb3 Bb3 D4 G4 Bb4"},["m7b5"]={label="Ebm7b5",frets={false,6,7,6,7,false},dia="x6767x",shape="A-shape @6",notes="Eb3 A3 Db4 Gb4"},["dim7"]={label="Ebdim7",frets={false,6,7,5,7,false},dia="x6757x",shape="A-shape @6",notes="Eb3 A3 C4 Gb4"},["dim"]={label="Ebdim",frets={false,6,7,8,7,false},dia="x6787x",shape="A-shape @6",notes="Eb3 A3 Eb4 Gb4"},["aug"]={label="Ebaug",frets={false,6,9,8,8,7},dia="x69887",shape="A-shape @6",notes="Eb3 B3 Eb4 G4 B4"},["sus2"]={label="Ebsus2",frets={false,6,8,8,6,6},dia="x68866",shape="A-shape @6",notes="Eb3 Bb3 Eb4 F4 Bb4"},["sus4"]={label="Ebsus4",frets={false,6,8,8,9,6},dia="x68896",shape="A-shape @6",notes="Eb3 Bb3 Eb4 Ab4 Bb4"},["7sus4"]={label="Eb7sus4",frets={false,6,8,6,9,6},dia="x68696",shape="A-shape @6",notes="Eb3 Bb3 Db4 Ab4 Bb4"},["6"]={label="Eb6",frets={false,6,8,8,8,8},dia="x68888",shape="A-shape @6",notes="Eb3 Bb3 Eb4 G4 C5"},["m6"]={label="Ebm6",frets={false,6,8,8,7,8},dia="x68878",shape="A-shape @6",notes="Eb3 Bb3 Eb4 Gb4 C5"},["9"]={label="Eb9",frets={false,6,5,6,6,6},dia="x65666",shape="A-shape @6",notes="Eb3 G3 Db4 F4 Bb4"},["add9"]={label="Ebadd9",frets={false,6,8,10,8,6},dia="x68a86",shape="A-shape @6",notes="Eb3 Bb3 F4 G4 Bb4"},["maj9"]={label="Ebmaj9",frets={false,6,5,7,6,6},dia="x65766",shape="A-shape @6",notes="Eb3 G3 D4 F4 Bb4"},["m9"]={label="Ebm9",frets={false,6,4,6,6,6},dia="x64666",shape="A-shape @6",notes="Eb3 Gb3 Db4 F4 Bb4"},["m11"]={label="Ebm11",frets={false,6,4,6,4,4},dia="x64644",shape="A-shape @6",notes="Eb3 Gb3 Db4 Eb4 Ab4"},["13"]={label="Eb13",frets={false,6,5,6,4,8},dia="x65648",shape="A-shape @6",notes="Eb3 G3 Db4 Eb4 C5"},["13sus4"]={label="Eb13sus4",frets={false,6,6,6,4,8},dia="x66648",shape="A-shape @6",notes="Eb3 Ab3 Db4 Eb4 C5"},["9sus4"]={label="Eb9sus4",frets={false,6,6,6,6,6},dia="x66666",shape="A-shape @6",notes="Eb3 Ab3 Db4 F4 Bb4"},["6/9"]={label="Eb6/9",frets={false,6,5,5,6,6},dia="x65566",shape="A-shape @6",notes="Eb3 G3 C4 F4 Bb4"},["m6/9"]={label="Ebm6/9",frets={false,6,4,5,6,6},dia="x64566",shape="A-shape @6",notes="Eb3 Gb3 C4 F4 Bb4"},["add11"]={label="Ebadd11",frets={false,6,6,8,8,6},dia="x66886",shape="A-shape @6",notes="Eb3 Ab3 Eb4 G4 Bb4"},["mMaj7"]={label="EbmMaj7",frets={false,6,4,7,4,6},dia="x64746",shape="A-shape @6",notes="Eb3 Gb3 D4 Eb4 Bb4"},["7alt"]={label="Eb7alt",frets={false,6,5,6,7,6},dia="x65676",shape="A-shape @6",notes="Eb3 G3 Db4 Gb4 Bb4"},["5"]={label="Eb5",frets={false,6,8,8,false,false},dia="x688xx",shape="A-shape @6",notes="Eb3 Bb3 Eb4"}},
["E"]={["maj"]={label="E",frets={0,2,2,1,0,0},dia="022100",shape="E-shape @0",notes="E2 B2 E3 Ab3 B3 E4"},["m"]={label="Em",frets={0,2,2,0,0,0},dia="022000",shape="E-shape @0",notes="E2 B2 E3 G3 B3 E4"},["7"]={label="E7",frets={0,2,0,1,0,0},dia="020100",shape="E-shape @0",notes="E2 B2 D3 Ab3 B3 E4"},["m7"]={label="Em7",frets={0,2,0,0,0,0},dia="020000",shape="E-shape @0",notes="E2 B2 D3 G3 B3 E4"},["maj7"]={label="Emaj7",frets={0,2,1,1,0,0},dia="021100",shape="open",notes="E2 B2 Eb3 Ab3 B3 E4"},["m7b5"]={label="Em7b5",frets={0,1,0,0,false,false},dia="0100xx",shape="E-shape @0",notes="E2 Bb2 D3 G3"},["dim7"]={label="Edim7",frets={false,7,8,6,8,false},dia="x7868x",shape="A-shape @7",notes="E3 Bb3 Db4 G4"},["dim"]={label="Edim",frets={0,1,false,0,false,false},dia="01x0xx",shape="E-shape @0",notes="E2 Bb2 G3"},["aug"]={label="Eaug",frets={0,3,2,1,false,false},dia="0321xx",shape="E-shape @0",notes="E2 C3 E3 Ab3"},["sus2"]={label="Esus2",frets={0,2,2,false,0,2},dia="022x02",shape="E-shape @0",notes="E2 B2 E3 B3 Gb4"},["sus4"]={label="Esus4",frets={0,2,2,2,0,0},dia="022200",shape="E-shape @0",notes="E2 B2 E3 A3 B3 E4"},["7sus4"]={label="E7sus4",frets={0,2,0,2,0,0},dia="020200",shape="E-shape @0",notes="E2 B2 D3 A3 B3 E4"},["6"]={label="E6",frets={0,2,2,1,2,0},dia="022120",shape="open",notes="E2 B2 E3 Ab3 Db4 E4"},["m6"]={label="Em6",frets={0,2,2,0,2,0},dia="022020",shape="open",notes="E2 B2 E3 G3 Db4 E4"},["9"]={label="E9",frets={false,7,6,7,7,7},dia="x76777",shape="A-shape @7",notes="E3 Ab3 D4 Gb4 B4"},["add9"]={label="Eadd9",frets={0,2,2,1,false,2},dia="0221x2",shape="E-shape @0",notes="E2 B2 E3 Ab3 Gb4"},["maj9"]={label="Emaj9",frets={false,7,6,8,7,7},dia="x76877",shape="A-shape @7",notes="E3 Ab3 Eb4 Gb4 B4"},["m9"]={label="Em9",frets={false,7,5,7,7,7},dia="x75777",shape="A-shape @7",notes="E3 G3 D4 Gb4 B4"},["m11"]={label="Em11",frets={false,7,5,7,5,5},dia="x75755",shape="A-shape @7",notes="E3 G3 D4 E4 A4"},["13"]={label="E13",frets={false,7,6,7,5,9},dia="x76759",shape="A-shape @7",notes="E3 Ab3 D4 E4 Db5"},["13sus4"]={label="E13sus4",frets={false,7,7,7,5,9},dia="x77759",shape="A-shape @7",notes="E3 A3 D4 E4 Db5"},["9sus4"]={label="E9sus4",frets={false,7,7,7,7,7},dia="x77777",shape="A-shape @7",notes="E3 A3 D4 Gb4 B4"},["6/9"]={label="E6/9",frets={false,7,6,6,7,7},dia="x76677",shape="A-shape @7",notes="E3 Ab3 Db4 Gb4 B4"},["m6/9"]={label="Em6/9",frets={false,7,5,6,7,7},dia="x75677",shape="A-shape @7",notes="E3 G3 Db4 Gb4 B4"},["add11"]={label="Eadd11",frets={0,0,false,1,0,0},dia="00x100",shape="E-shape @0",notes="E2 A2 Ab3 B3 E4"},["mMaj7"]={label="EmMaj7",frets={0,false,1,0,0,0},dia="0x1000",shape="E-shape @0",notes="E2 Eb3 G3 B3 E4"},["7alt"]={label="E7alt",frets={false,7,6,7,8,7},dia="x76787",shape="A-shape @7",notes="E3 Ab3 D4 G4 B4"},["5"]={label="E5",frets={0,2,2,false,false,false},dia="022xxx",shape="E-shape @0",notes="E2 B2 E3"}},
["F"]={["maj"]={label="F",frets={1,3,3,2,1,1},dia="133211",shape="E-shape @1",notes="F2 C3 F3 A3 C4 F4"},["m"]={label="Fm",frets={1,3,3,1,1,1},dia="133111",shape="E-shape @1",notes="F2 C3 F3 Ab3 C4 F4"},["7"]={label="F7",frets={1,3,1,2,1,1},dia="131211",shape="E-shape @1",notes="F2 C3 Eb3 A3 C4 F4"},["m7"]={label="Fm7",frets={1,3,1,1,1,1},dia="131111",shape="E-shape @1",notes="F2 C3 Eb3 Ab3 C4 F4"},["maj7"]={label="Fmaj7",frets={1,false,2,2,1,false},dia="1x221x",shape="E-shape @1",notes="F2 E3 A3 C4"},["m7b5"]={label="Fm7b5",frets={1,2,1,1,false,false},dia="1211xx",shape="E-shape @1",notes="F2 B2 Eb3 Ab3"},["dim7"]={label="Fdim7",frets={1,2,0,1,false,false},dia="1201xx",shape="E-shape @1",notes="F2 B2 D3 Ab3"},["dim"]={label="Fdim",frets={1,2,false,1,false,false},dia="12x1xx",shape="E-shape @1",notes="F2 B2 Ab3"},["aug"]={label="Faug",frets={1,4,3,2,false,false},dia="1432xx",shape="E-shape @1",notes="F2 Db3 F3 A3"},["sus2"]={label="Fsus2",frets={1,3,3,false,1,3},dia="133x13",shape="E-shape @1",notes="F2 C3 F3 C4 G4"},["sus4"]={label="Fsus4",frets={1,3,3,3,1,1},dia="133311",shape="E-shape @1",notes="F2 C3 F3 Bb3 C4 F4"},["7sus4"]={label="F7sus4",frets={1,3,1,3,1,1},dia="131311",shape="E-shape @1",notes="F2 C3 Eb3 Bb3 C4 F4"},["6"]={label="F6",frets={1,3,3,2,3,false},dia="13323x",shape="E-shape @1",notes="F2 C3 F3 A3 D4"},["m6"]={label="Fm6",frets={1,3,3,1,3,false},dia="13313x",shape="E-shape @1",notes="F2 C3 F3 Ab3 D4"},["9"]={label="F9",frets={false,8,7,8,8,8},dia="x87888",shape="A-shape @8",notes="F3 A3 Eb4 G4 C5"},["add9"]={label="Fadd9",frets={1,3,3,2,false,3},dia="1332x3",shape="E-shape @1",notes="F2 C3 F3 A3 G4"},["maj9"]={label="Fmaj9",frets={1,0,false,0,1,0},dia="10x010",shape="E-shape @1",notes="F2 A2 G3 C4 E4"},["m9"]={label="Fm9",frets={false,8,6,8,8,8},dia="x86888",shape="A-shape @8",notes="F3 Ab3 Eb4 G4 C5"},["m11"]={label="Fm11",frets={false,8,6,8,6,6},dia="x86866",shape="A-shape @8",notes="F3 Ab3 Eb4 F4 Bb4"},["13"]={label="F13",frets={false,8,7,8,6,10},dia="x8786a",shape="A-shape @8",notes="F3 A3 Eb4 F4 D5"},["13sus4"]={label="F13sus4",frets={false,8,8,8,6,10},dia="x8886a",shape="A-shape @8",notes="F3 Bb3 Eb4 F4 D5"},["9sus4"]={label="F9sus4",frets={false,8,8,8,8,8},dia="x88888",shape="A-shape @8",notes="F3 Bb3 Eb4 G4 C5"},["6/9"]={label="F6/9",frets={1,0,0,0,false,1},dia="1000x1",shape="E-shape @1",notes="F2 A2 D3 G3 F4"},["m6/9"]={label="Fm6/9",frets={false,8,6,7,8,8},dia="x86788",shape="A-shape @8",notes="F3 Ab3 D4 G4 C5"},["add11"]={label="Fadd11",frets={1,1,false,2,1,1},dia="11x211",shape="E-shape @1",notes="F2 Bb2 A3 C4 F4"},["mMaj7"]={label="FmMaj7",frets={1,false,2,1,1,1},dia="1x2111",shape="E-shape @1",notes="F2 E3 Ab3 C4 F4"},["7alt"]={label="F7alt",frets={false,8,7,8,9,8},dia="x87898",shape="A-shape @8",notes="F3 A3 Eb4 Ab4 C5"},["5"]={label="F5",frets={1,3,3,false,false,false},dia="133xxx",shape="E-shape @1",notes="F2 C3 F3"}},
["Gb"]={["maj"]={label="Gb",frets={2,4,4,3,2,2},dia="244322",shape="E-shape @2",notes="Gb2 Db3 Gb3 Bb3 Db4 Gb4"},["m"]={label="Gbm",frets={2,4,4,2,2,2},dia="244222",shape="E-shape @2",notes="Gb2 Db3 Gb3 A3 Db4 Gb4"},["7"]={label="Gb7",frets={2,4,2,3,2,2},dia="242322",shape="E-shape @2",notes="Gb2 Db3 E3 Bb3 Db4 Gb4"},["m7"]={label="Gbm7",frets={2,4,2,2,2,2},dia="242222",shape="E-shape @2",notes="Gb2 Db3 E3 A3 Db4 Gb4"},["maj7"]={label="Gbmaj7",frets={2,false,3,3,2,false},dia="2x332x",shape="E-shape @2",notes="Gb2 F3 Bb3 Db4"},["m7b5"]={label="Gbm7b5",frets={2,3,2,2,false,false},dia="2322xx",shape="E-shape @2",notes="Gb2 C3 E3 A3"},["dim7"]={label="Gbdim7",frets={2,3,1,2,false,false},dia="2312xx",shape="E-shape @2",notes="Gb2 C3 Eb3 A3"},["dim"]={label="Gbdim",frets={2,3,false,2,false,false},dia="23x2xx",shape="E-shape @2",notes="Gb2 C3 A3"},["aug"]={label="Gbaug",frets={2,5,4,3,false,false},dia="2543xx",shape="E-shape @2",notes="Gb2 D3 Gb3 Bb3"},["sus2"]={label="Gbsus2",frets={2,4,4,false,2,4},dia="244x24",shape="E-shape @2",notes="Gb2 Db3 Gb3 Db4 Ab4"},["sus4"]={label="Gbsus4",frets={2,4,4,4,2,2},dia="244422",shape="E-shape @2",notes="Gb2 Db3 Gb3 B3 Db4 Gb4"},["7sus4"]={label="Gb7sus4",frets={2,4,2,4,2,2},dia="242422",shape="E-shape @2",notes="Gb2 Db3 E3 B3 Db4 Gb4"},["6"]={label="Gb6",frets={2,4,4,3,4,false},dia="24434x",shape="E-shape @2",notes="Gb2 Db3 Gb3 Bb3 Eb4"},["m6"]={label="Gbm6",frets={2,4,4,2,4,false},dia="24424x",shape="E-shape @2",notes="Gb2 Db3 Gb3 A3 Eb4"},["9"]={label="Gb9",frets={false,9,8,9,9,9},dia="x98999",shape="A-shape @9",notes="Gb3 Bb3 E4 Ab4 Db5"},["add9"]={label="Gbadd9",frets={2,4,4,3,false,4},dia="2443x4",shape="E-shape @2",notes="Gb2 Db3 Gb3 Bb3 Ab4"},["maj9"]={label="Gbmaj9",frets={2,1,false,1,2,1},dia="21x121",shape="E-shape @2",notes="Gb2 Bb2 Ab3 Db4 F4"},["m9"]={label="Gbm9",frets={2,0,false,1,2,0},dia="20x120",shape="E-shape @2",notes="Gb2 A2 Ab3 Db4 E4"},["m11"]={label="Gbm11",frets={2,false,2,2,0,2},dia="2x2202",shape="E-shape @2",notes="Gb2 E3 A3 B3 Gb4"},["13"]={label="Gb13",frets={2,1,1,false,2,0},dia="211x20",shape="E-shape @2",notes="Gb2 Bb2 Eb3 Db4 E4"},["13sus4"]={label="Gb13sus4",frets={2,false,1,1,0,0},dia="2x1100",shape="E-shape @2",notes="Gb2 Eb3 Ab3 B3 E4"},["9sus4"]={label="Gb9sus4",frets={2,false,2,1,0,2},dia="2x2102",shape="E-shape @2",notes="Gb2 E3 Ab3 B3 Gb4"},["6/9"]={label="Gb6/9",frets={2,1,1,1,false,2},dia="2111x2",shape="E-shape @2",notes="Gb2 Bb2 Eb3 Ab3 Gb4"},["m6/9"]={label="Gbm6/9",frets={2,0,1,1,false,2},dia="2011x2",shape="E-shape @2",notes="Gb2 A2 Eb3 Ab3 Gb4"},["add11"]={label="Gbadd11",frets={2,2,false,3,2,2},dia="22x322",shape="E-shape @2",notes="Gb2 B2 Bb3 Db4 Gb4"},["mMaj7"]={label="GbmMaj7",frets={2,false,3,2,2,2},dia="2x3222",shape="E-shape @2",notes="Gb2 F3 A3 Db4 Gb4"},["7alt"]={label="Gb7alt",frets={2,1,false,2,2,0},dia="21x220",shape="E-shape @2",notes="Gb2 Bb2 A3 Db4 E4"},["5"]={label="Gb5",frets={2,4,4,false,false,false},dia="244xxx",shape="E-shape @2",notes="Gb2 Db3 Gb3"}},
["G"]={["maj"]={label="G",frets={3,2,0,0,0,3},dia="320003",shape="open",notes="G2 B2 D3 G3 B3 G4"},["m"]={label="Gm",frets={3,5,5,3,3,3},dia="355333",shape="E-shape @3",notes="G2 D3 G3 Bb3 D4 G4"},["7"]={label="G7",frets={3,2,0,0,0,1},dia="320001",shape="open",notes="G2 B2 D3 G3 B3 F4"},["m7"]={label="Gm7",frets={3,5,3,3,3,3},dia="353333",shape="E-shape @3",notes="G2 D3 F3 Bb3 D4 G4"},["maj7"]={label="Gmaj7",frets={3,2,0,0,0,2},dia="320002",shape="open",notes="G2 B2 D3 G3 B3 Gb4"},["m7b5"]={label="Gm7b5",frets={3,4,3,3,false,false},dia="3433xx",shape="E-shape @3",notes="G2 Db3 F3 Bb3"},["dim7"]={label="Gdim7",frets={3,4,2,3,false,false},dia="3423xx",shape="E-shape @3",notes="G2 Db3 E3 Bb3"},["dim"]={label="Gdim",frets={3,4,false,3,false,false},dia="34x3xx",shape="E-shape @3",notes="G2 Db3 Bb3"},["aug"]={label="Gaug",frets={3,6,5,4,false,false},dia="3654xx",shape="E-shape @3",notes="G2 Eb3 G3 B3"},["sus2"]={label="Gsus2",frets={3,5,5,false,3,5},dia="355x35",shape="E-shape @3",notes="G2 D3 G3 D4 A4"},["sus4"]={label="Gsus4",frets={3,5,5,5,3,3},dia="355533",shape="E-shape @3",notes="G2 D3 G3 C4 D4 G4"},["7sus4"]={label="G7sus4",frets={3,5,3,5,3,3},dia="353533",shape="E-shape @3",notes="G2 D3 F3 C4 D4 G4"},["6"]={label="G6",frets={3,2,0,0,0,0},dia="320000",shape="open",notes="G2 B2 D3 G3 B3 E4"},["m6"]={label="Gm6",frets={3,5,5,3,5,false},dia="35535x",shape="E-shape @3",notes="G2 D3 G3 Bb3 E4"},["9"]={label="G9",frets={false,10,9,10,10,10},dia="xa9aaa",shape="A-shape @10",notes="G3 B3 F4 A4 D5"},["add9"]={label="Gadd9",frets={3,5,5,4,false,5},dia="3554x5",shape="E-shape @3",notes="G2 D3 G3 B3 A4"},["maj9"]={label="Gmaj9",frets={3,2,false,2,3,2},dia="32x232",shape="E-shape @3",notes="G2 B2 A3 D4 Gb4"},["m9"]={label="Gm9",frets={3,1,false,2,3,1},dia="31x231",shape="E-shape @3",notes="G2 Bb2 A3 D4 F4"},["m11"]={label="Gm11",frets={3,false,3,3,1,3},dia="3x3313",shape="E-shape @3",notes="G2 F3 Bb3 C4 G4"},["13"]={label="G13",frets={3,2,2,false,3,1},dia="322x31",shape="E-shape @3",notes="G2 B2 E3 D4 F4"},["13sus4"]={label="G13sus4",frets={3,false,2,2,1,1},dia="3x2211",shape="E-shape @3",notes="G2 E3 A3 C4 F4"},["9sus4"]={label="G9sus4",frets={3,false,3,2,1,3},dia="3x3213",shape="E-shape @3",notes="G2 F3 A3 C4 G4"},["6/9"]={label="G6/9",frets={3,2,2,2,false,3},dia="3222x3",shape="E-shape @3",notes="G2 B2 E3 A3 G4"},["m6/9"]={label="Gm6/9",frets={3,1,2,2,false,3},dia="3122x3",shape="E-shape @3",notes="G2 Bb2 E3 A3 G4"},["add11"]={label="Gadd11",frets={3,3,false,4,3,3},dia="33x433",shape="E-shape @3",notes="G2 C3 B3 D4 G4"},["mMaj7"]={label="GmMaj7",frets={3,false,4,3,3,3},dia="3x4333",shape="E-shape @3",notes="G2 Gb3 Bb3 D4 G4"},["7alt"]={label="G7alt",frets={3,2,false,3,3,1},dia="32x331",shape="E-shape @3",notes="G2 B2 Bb3 D4 F4"},["5"]={label="G5",frets={3,5,5,false,false,false},dia="355xxx",shape="E-shape @3",notes="G2 D3 G3"}},
["Ab"]={["maj"]={label="Ab",frets={4,6,6,5,4,4},dia="466544",shape="E-shape @4",notes="Ab2 Eb3 Ab3 C4 Eb4 Ab4"},["m"]={label="Abm",frets={4,6,6,4,4,4},dia="466444",shape="E-shape @4",notes="Ab2 Eb3 Ab3 B3 Eb4 Ab4"},["7"]={label="Ab7",frets={4,6,4,5,4,4},dia="464544",shape="E-shape @4",notes="Ab2 Eb3 Gb3 C4 Eb4 Ab4"},["m7"]={label="Abm7",frets={4,6,4,4,4,4},dia="464444",shape="E-shape @4",notes="Ab2 Eb3 Gb3 B3 Eb4 Ab4"},["maj7"]={label="Abmaj7",frets={4,false,5,5,4,false},dia="4x554x",shape="E-shape @4",notes="Ab2 G3 C4 Eb4"},["m7b5"]={label="Abm7b5",frets={4,5,4,4,false,false},dia="4544xx",shape="E-shape @4",notes="Ab2 D3 Gb3 B3"},["dim7"]={label="Abdim7",frets={4,5,3,4,false,false},dia="4534xx",shape="E-shape @4",notes="Ab2 D3 F3 B3"},["dim"]={label="Abdim",frets={4,5,false,4,false,false},dia="45x4xx",shape="E-shape @4",notes="Ab2 D3 B3"},["aug"]={label="Abaug",frets={4,7,6,5,false,false},dia="4765xx",shape="E-shape @4",notes="Ab2 E3 Ab3 C4"},["sus2"]={label="Absus2",frets={4,6,6,false,4,6},dia="466x46",shape="E-shape @4",notes="Ab2 Eb3 Ab3 Eb4 Bb4"},["sus4"]={label="Absus4",frets={4,6,6,6,4,4},dia="466644",shape="E-shape @4",notes="Ab2 Eb3 Ab3 Db4 Eb4 Ab4"},["7sus4"]={label="Ab7sus4",frets={4,6,4,6,4,4},dia="464644",shape="E-shape @4",notes="Ab2 Eb3 Gb3 Db4 Eb4 Ab4"},["6"]={label="Ab6",frets={4,6,6,5,6,false},dia="46656x",shape="E-shape @4",notes="Ab2 Eb3 Ab3 C4 F4"},["m6"]={label="Abm6",frets={4,6,6,4,6,false},dia="46646x",shape="E-shape @4",notes="Ab2 Eb3 Ab3 B3 F4"},["9"]={label="Ab9",frets={false,11,10,11,11,11},dia="xbabbb",shape="A-shape @11",notes="Ab3 C4 Gb4 Bb4 Eb5"},["add9"]={label="Abadd9",frets={4,6,6,5,false,6},dia="4665x6",shape="E-shape @4",notes="Ab2 Eb3 Ab3 C4 Bb4"},["maj9"]={label="Abmaj9",frets={4,3,false,3,4,3},dia="43x343",shape="E-shape @4",notes="Ab2 C3 Bb3 Eb4 G4"},["m9"]={label="Abm9",frets={4,2,false,3,4,2},dia="42x342",shape="E-shape @4",notes="Ab2 B2 Bb3 Eb4 Gb4"},["m11"]={label="Abm11",frets={4,false,4,4,2,4},dia="4x4424",shape="E-shape @4",notes="Ab2 Gb3 B3 Db4 Ab4"},["13"]={label="Ab13",frets={4,3,3,false,4,2},dia="433x42",shape="E-shape @4",notes="Ab2 C3 F3 Eb4 Gb4"},["13sus4"]={label="Ab13sus4",frets={4,false,3,3,2,2},dia="4x3322",shape="E-shape @4",notes="Ab2 F3 Bb3 Db4 Gb4"},["9sus4"]={label="Ab9sus4",frets={4,false,4,3,2,4},dia="4x4324",shape="E-shape @4",notes="Ab2 Gb3 Bb3 Db4 Ab4"},["6/9"]={label="Ab6/9",frets={4,3,3,3,false,4},dia="4333x4",shape="E-shape @4",notes="Ab2 C3 F3 Bb3 Ab4"},["m6/9"]={label="Abm6/9",frets={4,2,3,3,false,4},dia="4233x4",shape="E-shape @4",notes="Ab2 B2 F3 Bb3 Ab4"},["add11"]={label="Abadd11",frets={4,4,false,5,4,4},dia="44x544",shape="E-shape @4",notes="Ab2 Db3 C4 Eb4 Ab4"},["mMaj7"]={label="AbmMaj7",frets={4,false,5,4,4,4},dia="4x5444",shape="E-shape @4",notes="Ab2 G3 B3 Eb4 Ab4"},["7alt"]={label="Ab7alt",frets={4,3,false,4,4,2},dia="43x442",shape="E-shape @4",notes="Ab2 C3 B3 Eb4 Gb4"},["5"]={label="Ab5",frets={4,6,6,false,false,false},dia="466xxx",shape="E-shape @4",notes="Ab2 Eb3 Ab3"}},
["A"]={["maj"]={label="A",frets={false,0,2,2,2,0},dia="x02220",shape="A-shape @0",notes="A2 E3 A3 Db4 E4"},["m"]={label="Am",frets={false,0,2,2,1,0},dia="x02210",shape="A-shape @0",notes="A2 E3 A3 C4 E4"},["7"]={label="A7",frets={false,0,2,0,2,0},dia="x02020",shape="A-shape @0",notes="A2 E3 G3 Db4 E4"},["m7"]={label="Am7",frets={false,0,2,0,1,0},dia="x02010",shape="A-shape @0",notes="A2 E3 G3 C4 E4"},["maj7"]={label="Amaj7",frets={false,0,2,1,2,0},dia="x02120",shape="A-shape @0",notes="A2 E3 Ab3 Db4 E4"},["m7b5"]={label="Am7b5",frets={false,0,1,0,1,false},dia="x0101x",shape="A-shape @0",notes="A2 Eb3 G3 C4"},["dim7"]={label="Adim7",frets={5,6,4,5,false,false},dia="5645xx",shape="E-shape @5",notes="A2 Eb3 Gb3 C4"},["dim"]={label="Adim",frets={false,0,1,2,1,false},dia="x0121x",shape="A-shape @0",notes="A2 Eb3 A3 C4"},["aug"]={label="Aaug",frets={false,0,3,2,2,1},dia="x03221",shape="A-shape @0",notes="A2 F3 A3 Db4 F4"},["sus2"]={label="Asus2",frets={false,0,2,2,0,0},dia="x02200",shape="A-shape @0",notes="A2 E3 A3 B3 E4"},["sus4"]={label="Asus4",frets={false,0,2,2,3,0},dia="x02230",shape="A-shape @0",notes="A2 E3 A3 D4 E4"},["7sus4"]={label="A7sus4",frets={false,0,2,0,3,0},dia="x02030",shape="A-shape @0",notes="A2 E3 G3 D4 E4"},["6"]={label="A6",frets={false,0,2,2,2,2},dia="x02222",shape="A-shape @0",notes="A2 E3 A3 Db4 Gb4"},["m6"]={label="Am6",frets={false,0,2,2,1,2},dia="x02212",shape="A-shape @0",notes="A2 E3 A3 C4 Gb4"},["9"]={label="A9",frets={false,0,2,4,2,3},dia="x02423",shape="open",notes="A2 E3 B3 Db4 G4"},["add9"]={label="Aadd9",frets={false,0,2,4,2,0},dia="x02420",shape="A-shape @0",notes="A2 E3 B3 Db4 E4"},["maj9"]={label="Amaj9",frets={5,4,false,4,5,4},dia="54x454",shape="E-shape @5",notes="A2 Db3 B3 E4 Ab4"},["m9"]={label="Am9",frets={5,3,false,4,5,3},dia="53x453",shape="E-shape @5",notes="A2 C3 B3 E4 G4"},["m11"]={label="Am11",frets={5,false,5,5,3,5},dia="5x5535",shape="E-shape @5",notes="A2 G3 C4 D4 A4"},["13"]={label="A13",frets={5,4,4,false,5,3},dia="544x53",shape="E-shape @5",notes="A2 Db3 Gb3 E4 G4"},["13sus4"]={label="A13sus4",frets={5,false,4,4,3,3},dia="5x4433",shape="E-shape @5",notes="A2 Gb3 B3 D4 G4"},["9sus4"]={label="A9sus4",frets={false,0,0,0,0,0},dia="x00000",shape="A-shape @0",notes="A2 D3 G3 B3 E4"},["6/9"]={label="A6/9",frets={5,4,4,4,false,5},dia="5444x5",shape="E-shape @5",notes="A2 Db3 Gb3 B3 A4"},["m6/9"]={label="Am6/9",frets={5,3,4,4,false,5},dia="5344x5",shape="E-shape @5",notes="A2 C3 Gb3 B3 A4"},["add11"]={label="Aadd11",frets={false,0,0,2,2,0},dia="x00220",shape="A-shape @0",notes="A2 D3 A3 Db4 E4"},["mMaj7"]={label="AmMaj7",frets={5,false,6,5,5,5},dia="5x6555",shape="E-shape @5",notes="A2 Ab3 C4 E4 A4"},["7alt"]={label="A7alt",frets={5,4,false,5,5,3},dia="54x553",shape="E-shape @5",notes="A2 Db3 C4 E4 G4"},["5"]={label="A5",frets={false,0,2,2,false,false},dia="x022xx",shape="A-shape @0",notes="A2 E3 A3"}},
["Bb"]={["maj"]={label="Bb",frets={false,1,3,3,3,1},dia="x13331",shape="A-shape @1",notes="Bb2 F3 Bb3 D4 F4"},["m"]={label="Bbm",frets={false,1,3,3,2,1},dia="x13321",shape="A-shape @1",notes="Bb2 F3 Bb3 Db4 F4"},["7"]={label="Bb7",frets={false,1,3,1,3,1},dia="x13131",shape="A-shape @1",notes="Bb2 F3 Ab3 D4 F4"},["m7"]={label="Bbm7",frets={false,1,3,1,2,1},dia="x13121",shape="A-shape @1",notes="Bb2 F3 Ab3 Db4 F4"},["maj7"]={label="Bbmaj7",frets={false,1,3,2,3,1},dia="x13231",shape="A-shape @1",notes="Bb2 F3 A3 D4 F4"},["m7b5"]={label="Bbm7b5",frets={false,1,2,1,2,false},dia="x1212x",shape="A-shape @1",notes="Bb2 E3 Ab3 Db4"},["dim7"]={label="Bbdim7",frets={false,1,2,0,2,false},dia="x1202x",shape="A-shape @1",notes="Bb2 E3 G3 Db4"},["dim"]={label="Bbdim",frets={false,1,2,3,2,false},dia="x1232x",shape="A-shape @1",notes="Bb2 E3 Bb3 Db4"},["aug"]={label="Bbaug",frets={false,1,4,3,3,2},dia="x14332",shape="A-shape @1",notes="Bb2 Gb3 Bb3 D4 Gb4"},["sus2"]={label="Bbsus2",frets={false,1,3,3,1,1},dia="x13311",shape="A-shape @1",notes="Bb2 F3 Bb3 C4 F4"},["sus4"]={label="Bbsus4",frets={false,1,3,3,4,1},dia="x13341",shape="A-shape @1",notes="Bb2 F3 Bb3 Eb4 F4"},["7sus4"]={label="Bb7sus4",frets={false,1,3,1,4,1},dia="x13141",shape="A-shape @1",notes="Bb2 F3 Ab3 Eb4 F4"},["6"]={label="Bb6",frets={false,1,3,3,3,3},dia="x13333",shape="A-shape @1",notes="Bb2 F3 Bb3 D4 G4"},["m6"]={label="Bbm6",frets={false,1,3,3,2,3},dia="x13323",shape="A-shape @1",notes="Bb2 F3 Bb3 Db4 G4"},["9"]={label="Bb9",frets={false,1,0,1,1,1},dia="x10111",shape="A-shape @1",notes="Bb2 D3 Ab3 C4 F4"},["add9"]={label="Bbadd9",frets={false,1,3,5,3,1},dia="x13531",shape="A-shape @1",notes="Bb2 F3 C4 D4 F4"},["maj9"]={label="Bbmaj9",frets={false,1,0,2,1,1},dia="x10211",shape="A-shape @1",notes="Bb2 D3 A3 C4 F4"},["m9"]={label="Bbm9",frets={6,4,false,5,6,4},dia="64x564",shape="E-shape @6",notes="Bb2 Db3 C4 F4 Ab4"},["m11"]={label="Bbm11",frets={6,false,6,6,4,6},dia="6x6646",shape="E-shape @6",notes="Bb2 Ab3 Db4 Eb4 Bb4"},["13"]={label="Bb13",frets={6,5,5,false,6,4},dia="655x64",shape="E-shape @6",notes="Bb2 D3 G3 F4 Ab4"},["13sus4"]={label="Bb13sus4",frets={6,false,5,5,4,4},dia="6x5544",shape="E-shape @6",notes="Bb2 G3 C4 Eb4 Ab4"},["9sus4"]={label="Bb9sus4",frets={false,1,1,1,1,1},dia="x11111",shape="A-shape @1",notes="Bb2 Eb3 Ab3 C4 F4"},["6/9"]={label="Bb6/9",frets={false,1,0,0,1,1},dia="x10011",shape="A-shape @1",notes="Bb2 D3 G3 C4 F4"},["m6/9"]={label="Bbm6/9",frets={6,4,5,5,false,6},dia="6455x6",shape="E-shape @6",notes="Bb2 Db3 G3 C4 Bb4"},["add11"]={label="Bbadd11",frets={false,1,1,3,3,1},dia="x11331",shape="A-shape @1",notes="Bb2 Eb3 Bb3 D4 F4"},["mMaj7"]={label="BbmMaj7",frets={6,false,7,6,6,6},dia="6x7666",shape="E-shape @6",notes="Bb2 A3 Db4 F4 Bb4"},["7alt"]={label="Bb7alt",frets={false,1,0,1,2,1},dia="x10121",shape="A-shape @1",notes="Bb2 D3 Ab3 Db4 F4"},["5"]={label="Bb5",frets={false,1,3,3,false,false},dia="x133xx",shape="A-shape @1",notes="Bb2 F3 Bb3"}},
["B"]={["maj"]={label="B",frets={false,2,4,4,4,2},dia="x24442",shape="A-shape @2",notes="B2 Gb3 B3 Eb4 Gb4"},["m"]={label="Bm",frets={false,2,4,4,3,2},dia="x24432",shape="A-shape @2",notes="B2 Gb3 B3 D4 Gb4"},["7"]={label="B7",frets={false,2,1,2,0,2},dia="x21202",shape="open",notes="B2 Eb3 A3 B3 Gb4"},["m7"]={label="Bm7",frets={false,2,4,2,3,2},dia="x24232",shape="A-shape @2",notes="B2 Gb3 A3 D4 Gb4"},["maj7"]={label="Bmaj7",frets={false,2,4,3,4,2},dia="x24342",shape="A-shape @2",notes="B2 Gb3 Bb3 Eb4 Gb4"},["m7b5"]={label="Bm7b5",frets={false,2,3,2,3,false},dia="x2323x",shape="A-shape @2",notes="B2 F3 A3 D4"},["dim7"]={label="Bdim7",frets={false,2,3,1,3,false},dia="x2313x",shape="A-shape @2",notes="B2 F3 Ab3 D4"},["dim"]={label="Bdim",frets={false,2,3,4,3,false},dia="x2343x",shape="A-shape @2",notes="B2 F3 B3 D4"},["aug"]={label="Baug",frets={false,2,5,4,4,3},dia="x25443",shape="A-shape @2",notes="B2 G3 B3 Eb4 G4"},["sus2"]={label="Bsus2",frets={false,2,4,4,2,2},dia="x24422",shape="A-shape @2",notes="B2 Gb3 B3 Db4 Gb4"},["sus4"]={label="Bsus4",frets={false,2,4,4,5,2},dia="x24452",shape="A-shape @2",notes="B2 Gb3 B3 E4 Gb4"},["7sus4"]={label="B7sus4",frets={false,2,4,2,5,2},dia="x24252",shape="A-shape @2",notes="B2 Gb3 A3 E4 Gb4"},["6"]={label="B6",frets={false,2,4,4,4,4},dia="x24444",shape="A-shape @2",notes="B2 Gb3 B3 Eb4 Ab4"},["m6"]={label="Bm6",frets={false,2,4,4,3,4},dia="x24434",shape="A-shape @2",notes="B2 Gb3 B3 D4 Ab4"},["9"]={label="B9",frets={false,2,1,2,2,2},dia="x21222",shape="A-shape @2",notes="B2 Eb3 A3 Db4 Gb4"},["add9"]={label="Badd9",frets={false,2,4,6,4,2},dia="x24642",shape="A-shape @2",notes="B2 Gb3 Db4 Eb4 Gb4"},["maj9"]={label="Bmaj9",frets={false,2,1,3,2,2},dia="x21322",shape="A-shape @2",notes="B2 Eb3 Bb3 Db4 Gb4"},["m9"]={label="Bm9",frets={false,2,0,2,2,2},dia="x20222",shape="A-shape @2",notes="B2 D3 A3 Db4 Gb4"},["m11"]={label="Bm11",frets={false,2,0,2,0,0},dia="x20200",shape="A-shape @2",notes="B2 D3 A3 B3 E4"},["13"]={label="B13",frets={false,2,1,2,0,4},dia="x21204",shape="A-shape @2",notes="B2 Eb3 A3 B3 Ab4"},["13sus4"]={label="B13sus4",frets={false,2,2,2,0,4},dia="x22204",shape="A-shape @2",notes="B2 E3 A3 B3 Ab4"},["9sus4"]={label="B9sus4",frets={false,2,2,2,2,2},dia="x22222",shape="A-shape @2",notes="B2 E3 A3 Db4 Gb4"},["6/9"]={label="B6/9",frets={false,2,1,1,2,2},dia="x21122",shape="A-shape @2",notes="B2 Eb3 Ab3 Db4 Gb4"},["m6/9"]={label="Bm6/9",frets={false,2,0,1,2,2},dia="x20122",shape="A-shape @2",notes="B2 D3 Ab3 Db4 Gb4"},["add11"]={label="Badd11",frets={false,2,2,4,4,2},dia="x22442",shape="A-shape @2",notes="B2 E3 B3 Eb4 Gb4"},["mMaj7"]={label="BmMaj7",frets={false,2,0,3,0,2},dia="x20302",shape="A-shape @2",notes="B2 D3 Bb3 B3 Gb4"},["7alt"]={label="B7alt",frets={false,2,1,2,3,2},dia="x21232",shape="A-shape @2",notes="B2 Eb3 A3 D4 Gb4"},["5"]={label="B5",frets={false,2,4,4,false,false},dia="x244xx",shape="A-shape @2",notes="B2 Gb3 B3"}}
}
local PROGS = {moods={"Rock","Metal","Phrygian","Blues","Emotional","Beautiful","Sad","Jazz","Pop","Dark","Sexy","Inspiring","Unique","Other"},progressions={{mood="Metal",name="Aeolian vamp · i-♭VI-♭VII",chords={{0,"5"},{8,"5"},{10,"5"}}},{mood="Metal",name="Descending · i-♭VII-♭VI-♭VII",chords={{0,"5"},{10,"5"},{8,"5"},{10,"5"}}},{mood="Metal",name="Epic cadence · ♭VI-♭VII-i",chords={{8,"5"},{10,"5"},{0,"5"}}},{mood="Metal",name="Aeolian four · i-♭VI-♭III-♭VII",chords={{0,"5"},{8,"5"},{3,"5"},{10,"5"}}},{mood="Metal",name="Minor drive · i-iv-♭VII",chords={{0,"5"},{5,"5"},{10,"5"}}},{mood="Metal",name="Gallop · i-♭VII-♭VI-V",chords={{0,"5"},{10,"5"},{8,"5"},{7,"5"}}},{mood="Metal",name="Power anthem · i-♭III-♭VI-♭VII",chords={{0,"5"},{3,"5"},{8,"5"},{10,"5"}}},{mood="Metal",name="Doom · i-♭VI",chords={{0,"5"},{8,"5"}}},{mood="Phrygian",name="Phrygian · i-♭II",chords={{0,"5"},{1,"5"}}},{mood="Phrygian",name="Phrygian dominant · I-♭II",chords={{0,"maj"},{1,"maj"}}},{mood="Phrygian",name="Neoclassical · i-♭II-♭III-♭II",chords={{0,"5"},{1,"5"},{3,"5"},{1,"5"}}},{mood="Phrygian",name="Andalusian · i-♭VII-♭VI-V",chords={{0,"m"},{10,"maj"},{8,"maj"},{7,"maj"}}},{mood="Rock",name="Mixolydian rock · I-♭VII-IV",chords={{0,"maj"},{10,"maj"},{5,"maj"}}},{mood="Rock",name="Three-chord · I-IV-V",chords={{0,"maj"},{5,"maj"},{7,"maj"}}},{mood="Rock",name="The anthem · I-V-vi-IV",chords={{0,"maj"},{7,"maj"},{9,"m"},{5,"maj"}}},{mood="Rock",name="Sad-punk · vi-IV-I-V",chords={{9,"m"},{5,"maj"},{0,"maj"},{7,"maj"}}},{mood="Rock",name="Classic · I-♭VII-IV-I",chords={{0,"maj"},{10,"maj"},{5,"maj"},{0,"maj"}}},{mood="Rock",name="Grunge · I-♭III-♭VI-♭VII",chords={{0,"maj"},{3,"maj"},{8,"maj"},{10,"maj"}}},{mood="Rock",name="Lift · I-V-♭VII-IV",chords={{0,"maj"},{7,"maj"},{10,"maj"},{5,"maj"}}},{mood="Blues",name="12-bar blues",chords={{0,"7"},{0,"7"},{0,"7"},{0,"7"},{5,"7"},{5,"7"},{0,"7"},{0,"7"},{7,"7"},{5,"7"},{0,"7"},{7,"7"}}},{mood="Blues",name="Minor blues · i-iv-i-v",chords={{0,"m7"},{5,"m7"},{0,"m7"},{7,"7"}}},{mood="Emotional",name="",chords={{0,"maj"},{2,"maj"},{4,"m"},{2,"maj"}}},{mood="Emotional",name="",chords={{0,"maj9"},{3,"maj9"},{10,"maj9"},{5,"m9"}}},{mood="Emotional",name="",chords={{0,"maj"},{7,"maj"},{4,"m"},{11,"m"}}},{mood="Emotional",name="",chords={{0,"m"},{7,"m"},{8,"maj"},{3,"maj"}}},{mood="Emotional",name="",chords={{0,"m9"},{8,"add9"},{3,"add9"},{7,"m7"}}},{mood="Emotional",name="",chords={{0,"add11"},{8,"add9"},{3,"add9"},{7,"m7"}}},{mood="Emotional",name="",chords={{0,"maj"},{9,"m"},{4,"m"},{2,"maj"}}},{mood="Emotional",name="",chords={{0,"maj"},{9,"m"},{7,"maj"},{2,"maj"}}},{mood="Emotional",name="",chords={{0,"m"},{10,"maj"},{7,"m"},{8,"maj"}}},{mood="Emotional",name="",chords={{0,"m7"},{0,"add11"},{8,"maj9"},{8,"maj9"},{5,"m9"}}},{mood="Emotional",name="",chords={{0,"m"},{7,"m"},{3,"maj7"},{10,"maj"},{5,"maj"}}},{mood="Emotional",name="",chords={{0,"add9"},{7,"add9"},{5,"add9"},{9,"m7"},{7,"add9"}}},{mood="Emotional",name="",chords={{0,"maj9"},{8,"maj9"},{0,"maj9"},{8,"maj9"},{5,"maj9"}}},{mood="Emotional",name="",chords={{0,"add9"},{2,"add9"},{10,"maj7"},{9,"m7"},{2,"13sus4"},{7,"maj9"}}},{mood="Emotional",name="",chords={{0,"maj"},{2,"maj"},{0,"maj"},{2,"maj"},{0,"maj"},{2,"maj"},{4,"maj"}}},{mood="Emotional",name="",chords={{0,"m"},{10,"maj"},{8,"maj"},{5,"m"},{7,"m"},{8,"maj"},{10,"maj"}}},{mood="Emotional",name="",chords={{0,"add9"},{0,"m7"},{3,"maj7"},{3,"maj7"},{0,"add9"},{0,"m7"},{3,"maj7"},{3,"maj7"}}},{mood="Emotional",name="",chords={{0,"m"},{0,"m7"},{8,"maj9"},{8,"maj7"},{3,"sus2"},{3,"maj"},{2,"m7b5"},{7,"7"}}},{mood="Emotional",name="",chords={{0,"maj"},{2,"maj"},{9,"maj"},{4,"maj"},{0,"maj"},{2,"maj"},{9,"maj"},{4,"maj"}}},{mood="Emotional",name="",chords={{0,"maj9"},{4,"m9"},{5,"maj7"},{2,"m7"},{9,"add9"},{4,"m7"},{5,"maj7"},{2,"maj"}}},{mood="Emotional",name="",chords={{0,"m"},{8,"maj"},{7,"m"},{7,"m"},{0,"m"},{8,"maj"},{7,"maj"},{7,"maj"}}},{mood="Emotional",name="",chords={{0,"m"},{10,"maj"},{3,"maj"},{5,"m"},{7,"m"},{8,"maj"},{10,"maj"},{0,"maj"}}},{mood="Emotional",name="",chords={{0,"m"},{10,"maj"},{5,"maj"},{10,"maj"},{5,"maj"},{7,"m"},{3,"maj"},{10,"maj"}}},{mood="Beautiful",name="",chords={{0,"sus2"},{0,"add9"},{2,"sus4"},{2,"sus4"}}},{mood="Beautiful",name="",chords={{0,"m7"},{3,"maj7"},{10,"add11"},{8,"add9"}}},{mood="Beautiful",name="",chords={{0,"sus2"},{5,"sus2"},{0,"sus2"},{3,"maj7"}}},{mood="Beautiful",name="",chords={{0,"maj9"},{5,"maj9"},{0,"maj9"},{5,"maj9"}}},{mood="Beautiful",name="",chords={{0,"add9"},{7,"add9"},{2,"add9"},{9,"add11"}}},{mood="Beautiful",name="",chords={{0,"m9"},{7,"m9"},{10,"add9"},{5,"add9"}}},{mood="Beautiful",name="",chords={{0,"m11"},{10,"maj9"},{0,"m11"},{10,"maj9"}}},{mood="Beautiful",name="",chords={{0,"m7"},{10,"add9"},{8,"add9"},{3,"maj"}}},{mood="Beautiful",name="",chords={{0,"maj9"},{5,"6/9"},{0,"maj9"},{3,"maj7"},{1,"maj7"}}},{mood="Beautiful",name="",chords={{0,"maj9"},{5,"6/9"},{0,"maj9"},{3,"maj7"},{1,"maj"}}},{mood="Beautiful",name="",chords={{0,"m"},{10,"maj"},{1,"sus2"},{6,"maj"},{8,"add9"},{3,"maj9"}}},{mood="Beautiful",name="",chords={{0,"m7"},{10,"6"},{3,"add9"},{3,"maj"},{8,"maj7"},{8,"maj7"}}},{mood="Beautiful",name="",chords={{0,"m9"},{10,"add9"},{7,"add11"},{10,"add9"},{10,"6"},{0,"m9"},{5,"13sus4"}}},{mood="Beautiful",name="",chords={{0,"9sus4"},{10,"add9"},{7,"add11"},{10,"add9"},{10,"6"},{0,"9sus4"},{5,"13sus4"}}},{mood="Beautiful",name="",chords={{0,"maj7"},{0,"add9"},{7,"maj"},{7,"add9"},{2,"add9"},{2,"maj"},{9,"m7"},{9,"add9"}}},{mood="Beautiful",name="",chords={{0,"sus2"},{2,"m7"},{0,"add9"},{5,"add9"},{8,"maj7"},{10,"add9"},{5,"add9"},{5,"maj"}}},{mood="Beautiful",name="",chords={{0,"sus2"},{7,"sus2"},{2,"maj"},{9,"m7"},{0,"maj"},{4,"m7"},{2,"add11"},{9,"m7"}}},{mood="Beautiful",name="",chords={{0,"m9"},{10,"add9"},{3,"maj9"},{3,"m9"},{5,"m7"},{6,"maj7"},{8,"maj9"},{3,"maj9"}}},{mood="Beautiful",name="",chords={{0,"m7"},{5,"sus2"},{7,"m"},{10,"maj"},{5,"sus4"},{0,"m9"},{7,"m7"},{5,"sus4"},{5,"maj"}}},{mood="Sad",name="",chords={{0,"m11"},{5,"m9"},{0,"m11"},{7,"7alt"}}},{mood="Sad",name="",chords={{0,"sus2"},{0,"maj"},{4,"m"},{2,"maj"},{2,"add11"},{9,"m7"}}},{mood="Sad",name="",chords={{0,"m"},{0,"add9"},{8,"maj9"},{8,"maj9"},{5,"m7"},{5,"m7"},{7,"sus2"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"maj9"},{0,"maj9"},{8,"maj9"},{8,"maj9"}}},{mood="Jazz",name="",chords={{0,"6/9"},{0,"9sus4"},{10,"9"},{11,"9"}}},{mood="Jazz",name="",chords={{0,"m"},{1,"maj"},{3,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{1,"maj"},{8,"maj"},{10,"m"}}},{mood="Jazz",name="",chords={{0,"maj"},{2,"maj"},{4,"m"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"6/9"},{2,"m9"},{8,"maj7"},{7,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj"},{2,"m"},{10,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"maj7"},{3,"dim7"},{2,"m7"},{7,"7alt"}}},{mood="Jazz",name="",chords={{0,"m"},{3,"maj"},{7,"m"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{3,"maj"},{8,"maj"},{1,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{3,"maj"},{8,"maj"},{2,"m"}}},{mood="Jazz",name="",chords={{0,"m"},{3,"maj"},{8,"maj"},{10,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{3,"maj"},{10,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{3,"maj"},{10,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"7alt"},{4,"maj7"},{5,"7"},{5,"add9"}}},{mood="Jazz",name="",chords={{0,"maj"},{4,"m"},{7,"maj"},{2,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{5,"m"},{0,"maj"},{5,"m"}}},{mood="Jazz",name="",chords={{0,"sus2"},{5,"7"},{2,"m7"},{7,"7"}}},{mood="Jazz",name="",chords={{0,"maj"},{5,"maj"},{7,"maj"},{0,"maj"}}},{mood="Jazz",name="",chords={{0,"m9"},{5,"m9"},{7,"7alt"},{0,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{5,"m"},{7,"maj"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{5,"maj"},{7,"maj"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{5,"maj"},{9,"m"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{7,"maj"},{2,"maj"},{4,"m"}}},{mood="Jazz",name="",chords={{0,"m"},{7,"m"},{3,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{7,"maj"},{4,"m"},{2,"maj"}}},{mood="Jazz",name="",chords={{0,"maj9"},{7,"m9"},{5,"maj9"},{8,"maj9"}}},{mood="Jazz",name="",chords={{0,"m"},{7,"maj"},{8,"maj"},{10,"maj"}}},{mood="Jazz",name="",chords={{0,"maj"},{7,"maj"},{9,"m"},{5,"m"}}},{mood="Jazz",name="",chords={{0,"maj"},{7,"maj"},{9,"m"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{8,"maj"},{3,"maj"},{10,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{8,"maj"},{10,"maj"},{5,"m"}}},{mood="Jazz",name="",chords={{0,"maj"},{9,"m"},{0,"maj"},{9,"m"}}},{mood="Jazz",name="",chords={{0,"maj"},{9,"m"},{5,"maj"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{7,"m"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{8,"maj"},{5,"m"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{8,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{8,"maj"},{10,"maj"}}},{mood="Jazz",name="",chords={{0,"maj7"},{11,"7"},{4,"m7"},{6,"m7"}}},{mood="Jazz",name="",chords={{0,"13sus4"},{11,"m7"},{10,"maj7"},{2,"add9"}}},{mood="Jazz",name="",chords={{0,"9"},{11,"9"},{10,"9"},{11,"9"}}},{mood="Jazz",name="",chords={{0,"6/9"},{0,"13sus4"},{7,"m7"},{6,"maj7"},{5,"maj7"}}},{mood="Jazz",name="",chords={{0,"6/9"},{0,"13sus4"},{7,"m7"},{6,"maj"},{5,"maj7"}}},{mood="Jazz",name="",chords={{0,"maj9"},{1,"dim7"},{2,"m9"},{3,"maj9"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"m9"},{3,"maj9"},{0,"m9"},{5,"9sus4"},{10,"maj7"}}},{mood="Jazz",name="",chords={{0,"9sus4"},{3,"maj9"},{0,"m9"},{5,"9sus4"},{10,"maj7"}}},{mood="Jazz",name="",chords={{0,"7"},{3,"maj7"},{5,"7"},{5,"7"},{3,"maj7"}}},{mood="Jazz",name="",chords={{0,"maj9"},{3,"maj9"},{6,"maj9"},{9,"maj9"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"m"},{3,"maj"},{7,"m"},{10,"maj"},{5,"maj"}}},{mood="Jazz",name="",chords={{0,"m7"},{5,"add9"},{8,"maj9"},{3,"maj7"},{10,"13sus4"}}},{mood="Jazz",name="",chords={{0,"maj9"},{5,"9sus4"},{10,"mMaj7"},{11,"maj9"},{8,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj9"},{5,"9sus4"},{10,"maj9"},{11,"maj9"},{8,"maj9"}}},{mood="Jazz",name="",chords={{0,"7"},{7,"7"},{0,"7"},{11,"7"},{4,"m7"}}},{mood="Jazz",name="",chords={{0,"9sus4"},{7,"m7"},{8,"maj9"},{1,"13sus4"},{7,"7alt"}}},{mood="Jazz",name="",chords={{0,"m"},{7,"m"},{8,"maj"},{3,"maj"},{10,"maj"}}},{mood="Jazz",name="",chords={{0,"m9"},{8,"maj9"},{5,"m"},{11,"maj7"},{3,"maj9"}}},{mood="Jazz",name="",chords={{0,"7"},{9,"9"},{7,"m9"},{3,"m9"},{2,"m9"}}},{mood="Jazz",name="",chords={{0,"maj7"},{2,"m7"},{4,"aug"},{5,"maj7"},{5,"m7"},{5,"m7"}}},{mood="Jazz",name="",chords={{0,"sus2"},{4,"m9"},{4,"7alt"},{2,"m"},{4,"7"},{9,"m7"}}},{mood="Jazz",name="",chords={{0,"sus2"},{4,"m9"},{4,"7alt"},{2,"maj"},{4,"7"},{9,"m7"}}},{mood="Jazz",name="",chords={{0,"maj7"},{4,"7"},{9,"m7"},{2,"m9"},{7,"13sus4"},{7,"13sus4"}}},{mood="Jazz",name="",chords={{0,"maj9"},{5,"m9"},{3,"maj7"},{2,"m7"},{1,"maj7"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj9"},{5,"m9"},{3,"maj7"},{2,"7"},{1,"maj7"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj9"},{5,"m9"},{3,"maj7"},{2,"m7"},{1,"maj"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj9"},{6,"9"},{5,"maj7"},{8,"maj7"},{7,"13sus4"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj"},{7,"maj"},{9,"m"},{5,"maj"},{0,"maj"},{7,"maj"}}},{mood="Jazz",name="",chords={{0,"maj9"},{9,"m11"},{2,"13sus4"},{7,"maj7"},{2,"m7"},{7,"7"}}},{mood="Jazz",name="",chords={{0,"13sus4"},{0,"9"},{11,"dim"},{10,"maj9"},{9,"7alt"},{1,"dim"},{2,"add9"}}},{mood="Jazz",name="",chords={{0,"maj9"},{1,"m9"},{0,"maj9"},{1,"m9"},{0,"9"},{2,"maj"},{1,"maj"}}},{mood="Jazz",name="",chords={{0,"maj7"},{3,"maj7"},{3,"m7"},{2,"m7"},{3,"m7"},{6,"maj7"},{9,"maj7"}}},{mood="Jazz",name="",chords={{0,"m9"},{5,"m7"},{7,"m7"},{10,"maj7"},{3,"maj7"},{8,"maj7"},{0,"maj7"}}},{mood="Jazz",name="",chords={{0,"9"},{10,"9"},{7,"9"},{0,"9"},{10,"9"},{7,"9"},{0,"9"}}},{mood="Jazz",name="",chords={{0,"m7"},{11,"m7"},{10,"7"},{9,"m9"},{0,"maj9"},{3,"maj9"},{7,"maj9"}}},{mood="Jazz",name="",chords={{0,"sus2"},{1,"sus2"},{2,"sus2"},{3,"sus2"},{4,"sus2"},{5,"sus2"},{6,"sus2"},{7,"13sus4"}}},{mood="Jazz",name="",chords={{0,"maj7"},{2,"m7"},{1,"m7b5"},{9,"m7"},{7,"maj"},{4,"m7"},{9,"m7"},{2,"9sus4"}}},{mood="Jazz",name="",chords={{0,"m7"},{2,"m7"},{3,"maj7"},{5,"m7"},{3,"maj7"},{2,"m7"},{0,"m7"},{8,"add9"}}},{mood="Jazz",name="",chords={{0,"m7b5"},{2,"maj7"},{4,"m7"},{2,"maj7"},{11,"m7"},{10,"maj7"},{9,"maj7"},{6,"maj7"}}},{mood="Jazz",name="",chords={{0,"m7b5"},{2,"maj7"},{4,"m7"},{2,"maj7"},{11,"m7"},{10,"maj"},{9,"maj7"},{6,"maj7"}}},{mood="Jazz",name="",chords={{0,"m"},{3,"maj"},{4,"dim"},{5,"maj"},{6,"dim"},{7,"m"},{0,"m"},{3,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{3,"maj"},{4,"dim"},{5,"maj"},{6,"dim"},{7,"m"},{0,"maj"},{3,"maj"}}},{mood="Jazz",name="",chords={{0,"maj9"},{4,"7alt"},{9,"m7"},{8,"m7"},{7,"m7"},{0,"7"},{5,"maj7"},{4,"7alt"}}},{mood="Jazz",name="",chords={{0,"maj9"},{5,"maj9"},{0,"maj9"},{5,"maj9"},{0,"maj9"},{5,"maj9"},{7,"maj7"},{0,"maj9"}}},{mood="Jazz",name="",chords={{0,"m9"},{5,"m9"},{7,"m9"},{3,"maj9"},{0,"m9"},{5,"m9"},{7,"m9"},{3,"maj7"}}},{mood="Jazz",name="",chords={{0,"maj9"},{6,"m9"},{0,"maj9"},{6,"m9"},{7,"maj7"},{7,"maj7"},{4,"m7"},{4,"maj9"}}},{mood="Jazz",name="",chords={{0,"m9"},{8,"maj7"},{10,"add9"},{5,"m9"},{0,"m9"},{8,"maj7"},{10,"add9"},{0,"maj"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{0,"m"},{10,"maj"},{8,"maj"},{3,"maj"},{3,"sus2"},{5,"m7"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{8,"maj"},{10,"maj"},{0,"m"},{10,"maj"},{8,"maj"},{5,"m"}}},{mood="Jazz",name="",chords={{0,"m"},{10,"maj"},{8,"maj"},{10,"maj"},{5,"m"},{7,"m"},{8,"maj"},{10,"maj"}}},{mood="Jazz",name="",chords={{0,"maj7"},{11,"7alt"},{4,"m7"},{2,"m7"},{1,"m7b5"},{9,"m7"},{2,"13sus4"},{7,"maj9"}}},{mood="Jazz",name="",chords={{0,"maj7"},{11,"7"},{4,"maj7"},{6,"m7"},{0,"maj9"},{11,"m"},{4,"maj7"},{6,"m7"}}},{mood="Jazz",name="",chords={{0,"m9"},{5,"13sus4"},{2,"m7"},{5,"m7"},{10,"7"},{3,"maj9"},{3,"m7"},{6,"maj7"},{8,"add9"}}},{mood="Jazz",name="",chords={{0,"m7"},{6,"maj7"},{0,"m7"},{6,"maj7"},{5,"7"},{9,"dim7"},{6,"maj7"},{6,"m7"},{1,"maj9"}}},{mood="Jazz",name="",chords={{0,"m9"},{10,"maj"},{5,"m"},{3,"sus2"},{8,"m"},{3,"sus2"},{8,"add9"},{10,"maj"},{3,"maj"}}},{mood="Jazz",name="",chords={{0,"m9"},{10,"m9"},{3,"9"},{8,"maj9"},{7,"7"},{0,"m9"},{10,"m9"},{3,"9"},{8,"maj9"},{7,"7"}}},{mood="Jazz",name="",chords={{0,"maj"},{11,"maj"},{0,"maj"},{1,"maj"},{2,"maj"},{0,"maj7"},{9,"m7"},{0,"maj"},{2,"maj"},{0,"maj7"}}},{mood="Jazz",name="",chords={{0,"maj9"},{11,"7alt"},{4,"m7"},{3,"m7"},{2,"m7"},{7,"9"},{0,"maj7"},{8,"maj7"},{10,"maj7"},{5,"maj7"}}},{mood="Jazz",name="",chords={{0,"maj9"},{2,"m9"},{4,"m7"},{5,"add9"},{4,"7alt"},{9,"m9"},{8,"9"},{7,"9"},{7,"13sus4"},{7,"13sus4"},{0,"maj"}}},{mood="Jazz",name="",chords={{0,"maj7"},{11,"m7"},{4,"m7"},{9,"m9"},{11,"m7"},{0,"maj7"},{11,"m7"},{4,"m7"},{9,"m9"},{11,"m7"},{4,"7"}}},{mood="Pop",name="",chords={{0,"sus2"},{0,"maj"},{4,"m7"},{5,"add9"},{5,"sus2"},{0,"maj"}}},{mood="Pop",name="",chords={{0,"sus2"},{7,"maj"},{2,"maj"},{4,"m"},{9,"m"},{7,"maj"},{2,"maj"}}},{mood="Pop",name="",chords={{0,"m"},{10,"maj"},{3,"sus2"},{3,"maj"},{10,"maj"},{5,"maj"},{3,"maj"}}},{mood="Pop",name="",chords={{0,"maj"},{7,"maj"},{2,"maj"},{3,"dim"},{4,"m"},{9,"m9"},{0,"maj"},{2,"maj"}}},{mood="Pop",name="",chords={{0,"maj"},{7,"maj"},{2,"maj"},{3,"dim"},{4,"m"},{9,"9"},{0,"maj"},{2,"maj"}}},{mood="Pop",name="",chords={{0,"maj"},{7,"maj"},{2,"maj"},{7,"maj"},{0,"maj"},{7,"maj"},{2,"sus4"},{2,"maj"}}},{mood="Pop",name="",chords={{0,"maj9"},{11,"m7"},{9,"m7"},{7,"maj7"},{6,"m7b5"},{11,"7"},{4,"m7"},{7,"maj"}}},{mood="Dark",name="",chords={{0,"m6"},{0,"m7"},{9,"m7"},{2,"7"}}},{mood="Dark",name="",chords={{0,"m"},{2,"dim7"},{0,"m"},{7,"maj"}}},{mood="Dark",name="",chords={{0,"m"},{2,"m"},{3,"maj"},{7,"m"}}},{mood="Dark",name="",chords={{0,"m"},{3,"maj"},{7,"m"},{2,"m"}}},{mood="Dark",name="",chords={{0,"m9"},{5,"m9"},{0,"m9"},{2,"m7b5"}}},{mood="Dark",name="",chords={{0,"m"},{5,"m"},{0,"m"},{7,"m"}}},{mood="Dark",name="",chords={{0,"m7b5"},{6,"maj7"},{10,"add9"},{10,"m"}}},{mood="Dark",name="",chords={{0,"m"},{7,"m"},{0,"m"},{7,"7alt"}}},{mood="Dark",name="",chords={{0,"m"},{7,"m"},{8,"maj"},{7,"m"}}},{mood="Dark",name="",chords={{0,"m"},{7,"m"},{9,"7sus4"},{7,"m"}}},{mood="Dark",name="",chords={{0,"m"},{8,"maj"},{10,"maj"},{0,"m"}}},{mood="Dark",name="",chords={{0,"m"},{10,"maj"},{0,"m"},{5,"m"}}},{mood="Dark",name="",chords={{0,"m"},{10,"maj"},{0,"m"},{7,"m"}}},{mood="Dark",name="",chords={{0,"9sus4"},{11,"m7"},{10,"7alt"},{7,"sus4"},{2,"13sus4"}}},{mood="Dark",name="",chords={{0,"m"},{5,"m"},{0,"m"},{0,"m"},{7,"m"},{0,"m"}}},{mood="Dark",name="",chords={{0,"m"},{7,"m7"},{8,"maj7"},{7,"m7"},{0,"m"},{5,"m7"}}},{mood="Dark",name="",chords={{0,"sus2"},{10,"add9"},{3,"sus2"},{0,"sus2"},{10,"sus2"},{3,"add9"}}},{mood="Dark",name="",chords={{0,"m"},{2,"maj"},{7,"m"},{5,"maj"},{0,"m7"},{2,"maj"},{7,"5"}}},{mood="Dark",name="",chords={{0,"m9"},{2,"7alt"},{7,"m9"},{7,"m9"},{0,"m9"},{2,"7alt"},{7,"m9"}}},{mood="Dark",name="",chords={{0,"5"},{5,"sus2"},{0,"m"},{7,"sus2"},{0,"5"},{0,"m"},{0,"5"}}},{mood="Dark",name="",chords={{0,"m"},{7,"add9"},{0,"m"},{5,"sus2"},{0,"m"},{10,"maj"},{0,"m"}}},{mood="Dark",name="",chords={{0,"m"},{7,"m"},{0,"m"},{7,"m"},{0,"m6"},{7,"m"},{0,"m"}}},{mood="Dark",name="",chords={{0,"m"},{7,"m"},{0,"m"},{7,"m"},{0,"m6"},{7,"m"},{0,"maj"}}},{mood="Dark",name="",chords={{0,"m9"},{7,"m7"},{0,"m9"},{7,"m7"},{0,"m9"},{7,"m7"},{0,"m9"},{7,"m7"}}},{mood="Dark",name="",chords={{0,"m9"},{3,"dim7"},{7,"m7"},{0,"m9"},{7,"m7"},{5,"dim"},{0,"m9"},{7,"7"},{5,"dim"},{5,"dim"},{0,"m9"}}},{mood="Sexy",name="",chords={{0,"6/9"},{3,"6/9"},{5,"6/9"},{4,"7"}}},{mood="Sexy",name="",chords={{0,"m7"},{3,"maj"},{8,"maj9"},{5,"m7"},{7,"m7"},{8,"maj7"},{7,"7alt"}}},{mood="Sexy",name="",chords={{0,"maj9"},{11,"7alt"},{11,"7alt"},{1,"dim7"},{3,"dim7"},{4,"9sus4"},{4,"m7"}}},{mood="Sexy",name="",chords={{0,"maj"},{11,"maj"},{4,"m"},{7,"maj"},{2,"maj"},{0,"maj"},{11,"maj"},{4,"5"}}},{mood="Inspiring",name="",chords={{0,"maj7"},{0,"m7"},{8,"maj7"},{5,"maj9"}}},{mood="Inspiring",name="",chords={{0,"add9"},{3,"add9"},{5,"add9"},{10,"maj9"}}},{mood="Inspiring",name="",chords={{0,"maj"},{7,"m7"},{10,"add9"},{5,"add9"}}},{mood="Inspiring",name="",chords={{0,"m"},{10,"add11"},{3,"maj"},{5,"m"}}},{mood="Inspiring",name="",chords={{0,"m"},{10,"add11"},{3,"maj"},{5,"maj"}}},{mood="Inspiring",name="",chords={{0,"maj"},{10,"add9"},{8,"maj7"},{5,"add9"}}},{mood="Inspiring",name="",chords={{0,"add9"},{2,"m7"},{10,"add9"},{5,"add9"},{5,"maj"}}},{mood="Inspiring",name="",chords={{0,"9sus4"},{11,"dim7"},{0,"m"},{0,"add9"},{0,"add9"}}},{mood="Inspiring",name="",chords={{0,"sus2"},{0,"maj"},{10,"add9"},{5,"sus2"},{5,"maj"},{0,"maj"}}},{mood="Inspiring",name="",chords={{0,"maj"},{5,"m"},{0,"maj"},{8,"maj7"},{10,"maj"},{0,"maj"}}},{mood="Inspiring",name="",chords={{0,"sus2"},{2,"add9"},{4,"m"},{4,"m7"},{0,"add9"},{2,"add11"},{4,"m7"},{7,"add9"}}},{mood="Inspiring",name="",chords={{0,"add9"},{7,"add9"},{2,"m"},{2,"m"},{5,"add9"},{7,"maj"},{0,"add9"},{0,"add9"}}},{mood="Inspiring",name="",chords={{0,"add9"},{7,"add9"},{2,"maj"},{2,"maj"},{5,"add9"},{7,"maj"},{0,"add9"},{0,"add9"}}},{mood="Inspiring",name="",chords={{0,"m"},{10,"maj"},{3,"add9"},{5,"maj"},{7,"m"},{5,"maj"},{10,"maj"},{5,"add9"}}},{mood="Inspiring",name="",chords={{0,"m"},{10,"maj"},{3,"maj"},{5,"m7"},{7,"sus4"},{7,"7sus4"},{7,"sus4"},{7,"maj"}}},{mood="Unique",name="",chords={{0,"m9"},{2,"m7b5"},{8,"mMaj7"}}},{mood="Unique",name="",chords={{0,"m7"},{3,"add9"},{7,"m"},{10,"maj7"}}},{mood="Unique",name="",chords={{0,"m9"},{8,"maj9"},{5,"m11"},{8,"mMaj7"}}},{mood="Unique",name="",chords={{0,"m"},{8,"maj"},{10,"maj"},{5,"maj"}}},{mood="Unique",name="",chords={{0,"maj"},{10,"maj9"},{3,"maj7"},{5,"maj9"}}},{mood="Unique",name="",chords={{0,"m9"},{10,"maj9"},{3,"maj7"},{7,"maj7"}}},{mood="Unique",name="",chords={{0,"add9"},{10,"6/9"},{5,"6"},{5,"m"}}},{mood="Unique",name="",chords={{0,"m7b5"},{11,"maj9"},{3,"m7"},{10,"7"}}},{mood="Unique",name="",chords={{0,"m9"},{5,"m6/9"},{8,"maj9"},{11,"maj7"},{1,"6/9"}}},{mood="Unique",name="",chords={{0,"m9"},{5,"6/9"},{8,"maj9"},{11,"maj7"},{1,"6/9"}}},{mood="Unique",name="",chords={{0,"m7"},{2,"m7"},{7,"m7"},{5,"m9"},{5,"13sus4"},{7,"7"}}},{mood="Unique",name="",chords={{0,"m7"},{2,"m7"},{7,"m7"},{5,"9sus4"},{5,"13sus4"},{7,"7"}}},{mood="Unique",name="",chords={{0,"maj"},{7,"maj"},{9,"m7"},{7,"m7"},{5,"maj9"},{0,"maj"},{2,"m9"},{7,"13sus4"}}},{mood="Unique",name="",chords={{0,"maj"},{11,"maj"},{4,"m"},{2,"maj"},{7,"maj"},{2,"maj"},{0,"maj"},{11,"maj"},{4,"5"}}},{mood="Other",name="",chords={{0,"m7"},{8,"maj7"},{7,"maj"},{7,"7"}}},{mood="Other",name="",chords={{0,"m7"},{2,"m7"},{3,"maj7"},{5,"maj"},{3,"maj7"},{5,"maj"},{7,"m"},{2,"7"}}}}}

local OPEN   = {40,45,50,55,59,64}                    -- low E -> high E
local NAMES  = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local ROOTS  = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
local QUALS  = {'maj','m','7','m7','maj7','m7b5','dim7','dim','aug',
                'sus2','sus4','7sus4','6','m6','9','add9'}
-- the extended voicings chorddata carries beyond the common set — so any chord a progression
-- can use (e.g. m9, maj9, 13sus4) is voiceable here too. Power's '5' stays on the Power tab.
local QUALS_EXT = {'maj9','m9','m11','13','13sus4','9sus4','6/9','m6/9','add11','mMaj7','7alt'}

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
-- functional harmony analysis: chord + key -> roman numeral, function, tendency


-- triad type and printed suffix for each quality in the pack
local QINFO = {
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
local function analyze(keyPC, mode, chordPC, quality)
  local q = QINFO[quality] or QINFO.maj
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
local function diatonicChords(keyPC, mode, sevenths)
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
    local a = analyze(keyPC, mode, pc, quals[i])
    out[#out+1] = {pc=pc, quality=quals[i], numeral=a.numeral, root=NAMES[pc+1], func=a.func}
  end
  return out
end


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

-- the Song/arranger is the EZbass-style scratch lane: audition on a tab, "+ Add to Song",
-- arrange the blocks, then "Send to REAPER" commits the whole thing as MIDI items at the
-- cursor. Tempo/metronome/looping are left to REAPER itself — the tool just emits clean MIDI.
local SONG_ENABLED = true

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
  if S.playSong then return renderSongBars(bqn) end
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
-- serialize the arrangement to a flat string (one block per line) for save/load. Kept pure so
-- it's testable; prog blocks inline their chords so they reconstruct without a library lookup.
local function songSerialize()
  local lines = {}
  for _,b in ipairs(S.song) do
    local g = b.g
    if b.kind=='chord' then
      lines[#lines+1] = table.concat({'chord',b.startBar,b.bars,g.root,g.qual,g.strumIdx}, '|')
    elseif b.kind=='power' then
      lines[#lines+1] = table.concat({'power',b.startBar,b.bars,g.proot,g.three and 1 or 0,g.powerIdx}, '|')
    elseif b.kind=='riff' then
      lines[#lines+1] = table.concat({'riff',b.startBar,b.bars,g.rroot,g.scale,g.rhythmIdx,g.riffSeed}, '|')
    else
      local cs = {}
      for _,c in ipairs(g.prog.chords) do cs[#cs+1] = c[1]..':'..c[2] end
      lines[#lines+1] = table.concat({'prog',b.startBar,b.bars,g.keyPC,g.keyMode,g.strumIdx,
                                      (g.prog.name or ''), table.concat(cs, ',')}, '|')
    end
  end
  return table.concat(lines, '\n')
end
local function songDeserialize(str)
  local song = {}
  for line in (str..'\n'):gmatch('(.-)\n') do
    if line ~= '' then
      local f = {}
      for tok in (line..'|'):gmatch('(.-)|') do f[#f+1] = tok end
      local kind, startBar, bars = f[1], tonumber(f[2]) or 0, math.max(1, tonumber(f[3]) or 1)
      local b
      if kind=='chord' and CHORDS[f[4]] and CHORDS[f[4]][f[5]] then
        b = {kind='chord', startBar=startBar, bars=bars, label=CHORDS[f[4]][f[5]].label,
             g={root=f[4], qual=f[5], strumIdx=tonumber(f[6]) or 1}}
      elseif kind=='power' and CHORDS[f[4]] then
        b = {kind='power', startBar=startBar, bars=bars, label=f[4]..'5',
             g={proot=f[4], three=f[5]=='1', powerIdx=tonumber(f[6]) or 1}}
      elseif kind=='riff' and CHORDS[f[4]] then
        b = {kind='riff', startBar=startBar, bars=bars, label=f[4]..' '..scaleName(f[5])..' riff',
             g={rroot=f[4], scale=f[5], rhythmIdx=tonumber(f[6]) or 1, riffSeed=tonumber(f[7]) or 1}}
      elseif kind=='prog' then
        local chords = {}
        for pair in ((f[8] or '')..','):gmatch('(.-),') do
          local d,q = pair:match('(%-?%d+):(.+)')
          if d and q and CHORDS['C'][q] then chords[#chords+1] = {tonumber(d), q} end
        end
        if #chords>0 then
          local name = f[7] or ''
          b = {kind='prog', startBar=startBar, bars=bars, label=(name~='' and name or 'progression'),
               g={prog={name=name, chords=chords}, keyPC=tonumber(f[4]) or 0,
                  keyMode=(f[5]=='min' and 'min' or 'maj'), strumIdx=tonumber(f[6]) or 1}}
        end
      end
      if b then song[#song+1] = b end
    end
  end
  return song
end
-- arranger undo: snapshot the song before each edit (reusing the serializer), so a wrong drag or
-- delete is one click back. The project isn't touched, so this is the song lane's own history.
local songUndo = {}
local function songSnapshot()
  local s = songSerialize()
  if songUndo[#songUndo] ~= s then songUndo[#songUndo+1] = s; if #songUndo > 50 then table.remove(songUndo, 1) end end
end
local function songUndoPop()
  if #songUndo == 0 then S.status = 'Nothing to undo.'; return end
  S.song, S.songSel = songDeserialize(songUndo[#songUndo]), nil
  table.remove(songUndo)
  S.status = 'Undone  ·  '..#S.song..' block'..(#S.song==1 and '' or 's')..' now.'
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
local songPlayOff = 0             -- first bar of the queued window (nonzero when looping a region)

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
  local bars = eventBars(bqn)
  songPlayOff = 0
  -- looping a chosen region of the song: queue only those bars; the re-queue then repeats them
  if S.playSong and S.loop and S.loopA and S.loopB and S.loopB > S.loopA then
    local sub = {}
    for i = S.loopA + 1, math.min(S.loopB, #bars) do sub[#sub+1] = bars[i] end
    if #sub > 0 then bars = sub; songPlayOff = S.loopA end
  end
  for _,evlist in ipairs(bars) do
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

local function audition(songMode)
  S.playSong = songMode and true or false
  if S.playSong and #S.song==0 then
    S.status = 'The song is empty — add blocks from the other tabs first.' return
  end
  local why = checkAudible()
  if why then S.status = why
  elseif S.playSong then S.status = 'Playing song · '..#S.song..' blocks, '..songLen()..' bars'
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
-- chord the "IN KEY" numeral row shows and auditions it with the current strum.
-- Each tab has its own idea of "root": the Power tab's power-chord root, the Riff
-- tab's pedal root, otherwise the Chords tab's chord (and its quality). We stay on the
-- current tab, so you can comp power and riff parts by scale degree too — and jump to
-- Chords from anywhere else so the board confirms what's sounding.
local function playDegree(i)
  local dia = diatonicChords(S.keyPC, S.keyMode, S.sevenths)
  local dc = dia[i]
  if not dc then return end
  local name = NAMES[dc.pc+1]
  if S.tab==2 then S.proot = name
  elseif S.tab==4 then S.rroot = name
  else S.tab, S.root, S.qual, S.inv = 1, name, dc.quality, 0 end
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
    local loops = (currentArt().p ~= nil or S.playSong) and S.loop   -- patterns and the song re-queue
    if loops and now > nextStart - 0.12 then
      queueBar(nextStart)
    elseif #sched == 0 and not loops then
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
  if S.playSong and #S.song==0 then S.status = 'The song is empty — nothing to send.' return end
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
  if S.playSong then
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

local function exportMidi(songMode)
  local PPQ, bqn, bpm = 480, barQN(), tempo()
  local list = {}
  local function push(qn, len, p, v)
    list[#list+1] = {t=math.floor(qn*PPQ+0.5), on=1, p=p, v=v}
    list[#list+1] = {t=math.floor((qn+len)*PPQ+0.5), on=0, p=p, v=0}
  end
  if songMode then                                        -- the whole arrangement, bar by bar
    if #S.song==0 then S.status = 'The song is empty — nothing to export.' return end
    for bar,evlist in ipairs(renderSongBars(bqn)) do
      local off = (bar-1)*bqn
      for _,e in ipairs(evlist) do push(off+e.qn, e.len, e.pitch, e.vel) end
    end
  else                                                    -- the current tab's one bar
    local evs = (S.tab==4)
      and buildRiffEvents(currentRiff(), rootBaseOf(S.rroot), bqn)
      or  buildEvents(currentFrets(), currentArt(), bqn)
    for _,e in ipairs(evs) do push(e.qn, e.len, e.pitch, e.vel) end
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
  local name = songMode
    and ('Song_' .. #S.song .. 'x' .. songLen() .. 'bars')
    or  (currentLabel() .. '_' .. currentArt().name):gsub('[^%w%+%-]', '_')
  local path = dir .. '/' .. name .. '.mid'
  local f = io.open(path, 'wb')
  if not f then S.status = 'Could not write to ' .. dir return end
  f:write(mid) f:close()
  S.status = 'Saved ' .. name .. '.mid  ->  ' .. dir
end

if _G.GCP_TEST then
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
-- OS cursor ids: arrow, horizontal-resize (edges), size-all/move (bodies). Set each frame.
local CUR_ARROW, CUR_EW, CUR_MOVE = 32512, 32644, 32646
local hoverCursor = CUR_ARROW
local pressed, released, held = false, false, false   -- mouse edges/state for dragging
local songDragMode, songDragOff = nil, 0              -- timeline drag: 'move' | 'stretch'
local songLoopDrag = nil                              -- loop-region drag: 'l' | 'r' | 'move' | 'new'
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

-- the "IN KEY" numeral strip: the seven diatonic chords of the current key, each
-- playable by click or by the home-row key beneath it (a s d f g h j = I..vii°).
-- Shared by the Chords, Power and Riff tabs, so the strip and its keys mean the same
-- thing everywhere — both route through playDegree(), which knows what "root" each tab
-- sets. The lit numeral tracks whichever root the current tab is using.
local function drawInKeyStrip(x0, y)
  txt('IN KEY', x0, y, C.mute, 2)
  txt('press  a s d f g h j  to play and sing along', x0+58, y, {0.36,0.37,0.40}, 2)
  if chip(x0+620, y+18, 60, 26, S.sevenths and '7ths' or 'triads', S.sevenths, 2) then
    S.sevenths = not S.sevenths
  end
  local rootPC = (S.tab==2 and pcOf(S.proot))
              or (S.tab==4 and pcOf(S.rroot))
              or pcOf(S.root)
  for i,dc in ipairs(diatonicChords(S.keyPC, S.keyMode, S.sevenths)) do
    local x = x0 + (i-1)*88
    -- on Chords the quality must match too; Power and Riff take only the root
    local sel = (rootPC==dc.pc) and (S.tab~=1 or S.qual==dc.quality)
    if chip(x, y+18, 84, 26, dc.numeral, sel, 2) then playDegree(i) end
    txt(DEG_KEYS[i], x+5, y+21, sel and C.selink or C.mute, 2)  -- keyboard hint
    -- the chord name under each numeral only means something on Chords; a power chord
    -- is always a 5th and a riff is a single line, so the quality there would mislead
    if S.tab==1 then
      txtc(dc.root .. (dc.quality=='maj' and '' or dc.quality), x, y+46, 84, C.mute, 2)
    end
  end
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
local LOOP_H = 14                                   -- top strip of the lane = the loop-region ruler
local function drawTimeline()
  local L, barW = LANE, laneBarW()
  box(L.x, L.y, L.w, L.h, C.panel, true)
  local barAt = function(x) return math.max(0, math.floor((x - L.x)/barW + S.songScroll + 0.5)) end

  -- input, resolved before drawing. TOP strip = loop region (edge-aware); below it = blocks.
  if pressed and hit(L.x, L.y, L.w, LOOP_H) then
    S.songSel, songDragMode = nil, nil
    local press, hasR = barAt(mx), (S.loopA and S.loopB and S.loopB > S.loopA)
    if     hasR and math.abs(press - S.loopA) <= 0.6 then songLoopDrag = 'l'
    elseif hasR and math.abs(press - S.loopB) <= 0.6 then songLoopDrag = 'r'
    elseif hasR and press > S.loopA and press < S.loopB then songLoopDrag, songDragOff = 'move', press - S.loopA
    else   songLoopDrag, S.loopA, S.loopB = 'new', press, press end
  elseif pressed and hit(L.x, L.y+LOOP_H, L.w, L.h-LOOP_H) then
    S.songSel, songDragMode = nil, nil
    for idx=#S.song,1,-1 do                      -- topmost block under the cursor wins
      local b  = S.song[idx]
      local bx = L.x + (b.startBar - S.songScroll) * barW
      local bw = b.bars * barW
      if mx>=bx and mx<bx+bw and my>=L.y+LOOP_H and my<L.y+L.h-15 then
        S.songSel = idx
        if mx >= bx+bw-18 and my < L.y+LOOP_H+18 then          -- the × in the top-right removes just this block
          songSnapshot()
          table.remove(S.song, idx); S.songSel, songDragMode = nil, nil
          S.status = 'Removed a block  ·  '..#S.song..' left  ·  Undo to restore.'
        elseif mx >= bx+bw-8 then songSnapshot(); songDragMode = 'stretch'
        else songSnapshot(); songDragMode, songDragOff = 'move', (S.songScroll + (mx-L.x)/barW) - b.startBar end
        break
      end
    end
  end
  if held and songLoopDrag then
    local cur = barAt(mx)
    if     songLoopDrag=='new' then S.loopB = cur; if S.loopB < S.loopA then S.loopA, S.loopB = S.loopB, S.loopA end
    elseif songLoopDrag=='l'   then S.loopA = math.max(0, math.min(S.loopB-1, cur))
    elseif songLoopDrag=='r'   then S.loopB = math.max(S.loopA+1, cur)
    else   local len = S.loopB - S.loopA; S.loopA = math.max(0, cur - songDragOff); S.loopB = S.loopA + len end
  elseif held and S.songSel and songDragMode then
    local b, mbar = S.song[S.songSel], S.songScroll + (mx - L.x)/barW
    if songDragMode=='move' then b.startBar = math.max(0, math.floor(mbar - songDragOff + 0.5))
    else b.bars = math.max(1, math.floor(mbar + 0.5) - b.startBar) end
  end
  if released then
    if songLoopDrag then
      if songLoopDrag=='new' and S.loopA==S.loopB then S.loopA, S.loopB = nil, nil   -- a click clears it
      else S.loop = true end
      songLoopDrag = nil
    end
    songDragMode = nil
  end

  -- cursor feedback: resize over an edge, move over a body (active drag wins so it doesn't flicker)
  if songLoopDrag=='l' or songLoopDrag=='r' or songDragMode=='stretch' then hoverCursor = CUR_EW
  elseif songLoopDrag=='move' or songDragMode=='move' then hoverCursor = CUR_MOVE
  elseif hit(L.x, L.y, L.w, LOOP_H) then
    local hb, hasR = barAt(mx), (S.loopA and S.loopB and S.loopB > S.loopA)
    if hasR and (math.abs(hb-S.loopA)<=0.6 or math.abs(hb-S.loopB)<=0.6) then hoverCursor = CUR_EW
    elseif hasR and hb>S.loopA and hb<S.loopB then hoverCursor = CUR_MOVE end
  elseif hit(L.x, L.y+LOOP_H, L.w, L.h-LOOP_H-15) then
    for idx=#S.song,1,-1 do
      local b=S.song[idx]
      local bx, bw = L.x + (b.startBar - S.songScroll)*barW, b.bars*barW
      if mx>=bx and mx<bx+bw then hoverCursor = (mx >= bx+bw-8) and CUR_EW or CUR_MOVE; break end
    end
  end

  -- bar grid + numbers every 4 bars
  for i=0,L.view do
    local gx, bar = L.x + i*barW, S.songScroll + i
    col(bar % 4 == 0 and C.line or C.chip)
    gfx.line(gx, L.y+LOOP_H, gx, L.y+L.h)
    if bar % 4 == 0 then txt(tostring(bar+1), gx+3, L.y+L.h-13, C.mute, 2) end
  end

  -- loop region: a strip on the ruler + edge lines down the lane, or a hint when unset
  if S.loopA and S.loopB and S.loopB > S.loopA then
    local lx0 = L.x + (S.loopA - S.songScroll)*barW
    local lx1 = L.x + (S.loopB - S.songScroll)*barW
    local vx0, vx1 = math.max(lx0, L.x), math.min(lx1, L.x+L.w)
    if vx1 > vx0 then
      box(vx0, L.y, vx1-vx0, LOOP_H, C.accentDim, true)
      col(C.accent); gfx.line(vx0, L.y, vx0, L.y+L.h); gfx.line(vx1-1, L.y, vx1-1, L.y+L.h)
      box(vx0, L.y, 5, LOOP_H, C.accent, true); box(vx1-5, L.y, 5, LOOP_H, C.accent, true)
      txt('loop '..(S.loopA+1)..'-'..S.loopB, vx0+9, L.y+2, C.selink, 2)
    end
  else
    txt('drag here to loop a range', L.x+6, L.y+2, {0.36,0.37,0.40}, 2)
  end

  -- blocks (below the loop strip)
  for idx,b in ipairs(S.song) do
    local bx = L.x + (b.startBar - S.songScroll) * barW
    local bw = b.bars * barW
    local vx0, vx1 = math.max(bx, L.x), math.min(bx+bw, L.x+L.w)
    if vx1 > vx0 then
      local sel = idx == S.songSel
      box(vx0, L.y+LOOP_H+2, vx1-vx0, L.h-LOOP_H-15, KIND_COL[b.kind] or C.accent, true)
      box(vx0, L.y+LOOP_H+2, vx1-vx0, L.h-LOOP_H-15, sel and C.ink or C.bg, false)
      txt(b.label, vx0+6, L.y+LOOP_H+6, C.bg, 2)
      if vx1-vx0 > 26 then txt('x', vx1-13, L.y+LOOP_H+3, C.bg, 2) end          -- per-block remove
      if sel then box(vx1-6, L.y+LOOP_H+20, 6, L.h-LOOP_H-33, C.ink, true) end  -- stretch handle (below the ×)
    end
  end

  -- playhead (offset by the region's first bar when looping a region)
  if playing then
    local phx = L.x + (songPlayOff + playingBar()-1 - S.songScroll) * barW
    if phx >= L.x and phx <= L.x+L.w then
      col(C.accent); gfx.line(phx, L.y, phx, L.y+L.h); gfx.line(phx+1, L.y, phx+1, L.y+L.h)
    end
  end
end

local W, H = 900, 812             -- design canvas: fixed width, fixed *minimum* height
-- The canvas grows taller than H to fill a tall (docked) window instead of letterboxing:
-- the extra height goes into the fretboard/timeline, everything below it shifts down, and
-- the footer anchors to the true bottom. Width still governs the scale, so nothing reflows
-- horizontally. drawHc is the current canvas height, recomputed each frame from the window.
local drawHc = H
-- ...but the fretboard only takes a slice of that extra height so it stays a landscape
-- rectangle instead of ballooning; any slack past this becomes open space above the footer.
local BOARD_MAX_EXTRA = 70
-- STABLE title (no version): REAPER remembers a gfx window's position by its title, so
-- the version lives in the status bar instead — otherwise every build looks like a new
-- window and its remembered position is lost. We set the size (for zoom); REAPER the spot.
local TITLE  = 'Guitar Songwriter'
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
local winW, winH = nil, nil        -- last drawable size, so a hand-resized (docked) window
local winDock = nil                -- and its dock state come back exactly next launch
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

-- song favorites: named arrangements kept in their own ExtState section, with a newline index
-- so they can be listed (global ExtState has no key enumeration). The project is still your real
-- save — this is for reusable block-sets you want to drop into any project.
local FAV = EXT .. '_songs'
local function favNames()
  local out = {}
  for nm in (reaper.GetExtState(FAV, '__index')..'\n'):gmatch('(.-)\n') do
    if nm ~= '' then out[#out+1] = nm end
  end
  return out
end
local function favSetIndex(list) reaper.SetExtState(FAV, '__index', table.concat(list, '\n'), true) end
local function saveFav()
  if #S.song == 0 then S.status = 'Nothing to save — the song is empty.'; return end
  local ok, name = reaper.GetUserInputs('Save song', 1, 'Name:', S.curFav or '')
  if not ok then return end
  name = (name or ''):gsub('^%s+',''):gsub('%s+$','')
  if name == '' then return end
  reaper.SetExtState(FAV, 's_'..name, songSerialize(), true)
  local names = favNames()
  if not inList(name, names) then names[#names+1] = name; table.sort(names); favSetIndex(names) end
  S.curFav = name
  S.status = 'Saved song "'..name..'".'
end
local function loadFav(name)
  local str = reaper.GetExtState(FAV, 's_'..name)
  if str == '' then S.status = 'That favorite is gone.'; return end
  S.song, S.songSel, S.curFav = songDeserialize(str), nil, name; S.loopA, S.loopB = nil, nil
  S.status = 'Loaded "'..name..'"  ·  '..#S.song..' block'..(#S.song==1 and '' or 's')..', '..songLen()..' bars.'
end
local function delFav()
  if not S.curFav then S.status = 'No favorite selected to delete.'; return end
  reaper.DeleteExtState(FAV, 's_'..S.curFav, true)
  local out = {}
  for _,n in ipairs(favNames()) do if n ~= S.curFav then out[#out+1] = n end end
  favSetIndex(out); S.status = 'Deleted "'..S.curFav..'".'; S.curFav = nil
end

local function saveState()
  local set = function(k,v) reaper.SetExtState(EXT, k, tostring(v), true) end
  set('tab', S.tab)         set('root', S.root)       set('qual', S.qual)  set('inv', S.inv)
  set('strumIdx', S.strumIdx) set('proot', S.proot)   set('three', S.three and 1 or 0)
  set('powerIdx', S.powerIdx) set('rroot', S.rroot)   set('scale', S.scale)
  set('rhythmIdx', S.rhythmIdx) set('riffSeed', S.riffSeed) set('loop', S.loop and 1 or 0)
  set('keyPC', S.keyPC)     set('keyMode', S.keyMode) set('sevenths', S.sevenths and 1 or 0)
  set('mood', S.mood)       set('progSel', S.progSel) set('uiIdx', uiIdx)
  if winX and winY then set('winX', math.floor(winX)); set('winY', math.floor(winY)) end
  if winW and winH then set('winW', math.floor(winW)); set('winH', math.floor(winH)) end
  if winDock then set('winDock', math.floor(winDock)) end
end
local function loadState()
  local g = function(k) local v = reaper.GetExtState(EXT, k); return v ~= '' and v or nil end
  local n = function(k) local v = g(k); return v and tonumber(v) or nil end
  local maxTab = 4   -- Song is a docked lane now, not a tab (1 chord, 2 power, 3 prog, 4 riff)
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
  winW, winH = n('winW'), n('winH')
  winDock = n('winDock')
end
loadState()

-- open where and how we last were: the hand-resized size wins over the zoom preset, plus
-- the remembered position and dock state, so a window docked tall on the side stays put
do
  local w0, h0 = levelSize(uiIdx)
  w0, h0 = winW or w0, winH or h0
  local dk = winDock or 0
  if winX and winY then gfx.init(TITLE, w0, h0, dk, winX, winY)
  else gfx.init(TITLE, w0, h0, dk) end
end
afterInit()

local PADX, SIDE_W = 184, 170      -- work area left edge, favorites sidebar width
local SOURCES = {'Progression','Chord','Power','Riff'}   -- S.tab 1..4 map: 1 Chord,2 Power,3 Prog,4 Riff
-- source switch order (left→right) with the S.tab each maps to
local SRCSW = {{'Progression',3},{'Chord',1},{'Power',2},{'Riff',4}}

local function drawSidebar(dh)
  box(0, 0, SIDE_W, dh-52, C.panel, true)
  col(C.line); gfx.line(SIDE_W, 0, SIDE_W, dh-52)
  txt('FAVORITES', 16, 16, C.mute, 2)
  if button(16, 38, SIDE_W-32, 26, '+ Save song') then saveFav() end
  local names = favNames()
  if #names == 0 then
    txt('No saved songs yet.', 16, 78, C.mute, 2)
    txt('Build a song, then', 16, 96, C.mute, 2)
    txt('press + Save song.', 16, 112, C.mute, 2)
  else
    for i,nm in ipairs(names) do
      local ry = 76 + (i-1)*30
      if ry > dh - 96 then break end
      if chip(16, ry, SIDE_W-32, 26, nm, nm==S.curFav, 2) then loadFav(nm) end
    end
    if S.curFav and button(16, dh-84, SIDE_W-32, 24, 'Delete selected') then delFav() end
  end
  txt('The project is your', 16, dh-46, {0.36,0.37,0.40}, 2)
  txt('real save.', 16, dh-32, {0.36,0.37,0.40}, 2)
end

local function drawHeader()
  txt('Guitar Songwriter', PADX, 14, C.ink, 3)
  gfx.setfont(3); local kx = PADX + gfx.measurestr('Guitar Songwriter') + 34   -- KEY sits just past the title
  txt('KEY', kx, 20, C.mute, 2)
  if button(kx+32, 12, 26, 28, '<') then S.keyPC = (S.keyPC + 11) % 12 end
  txtc(NAMES[S.keyPC+1], kx+60, 15, 40, C.ink, 3)   -- font 3 is taller; lift it to sit centred with the arrows
  if button(kx+102, 12, 26, 28, '>') then S.keyPC = (S.keyPC + 1) % 12 end
  if chip(kx+136, 12, 56, 28, 'major', S.keyMode=='maj', 2) then S.keyMode='maj' end
  if chip(kx+194, 12, 56, 28, 'minor', S.keyMode=='min', 2) then S.keyMode='min' end
  -- tempo is REAPER's project tempo (shown in REAPER's own transport); no duplicate control here
end

local function draw(dh)
  dh = dh or H
  local grow  = dh - H
  local bgrow = math.min(grow, BOARD_MAX_EXTRA)
  gfx.setfont(1)
  col(C.bg); gfx.rect(0,0,W,dh,1)
  hoverCursor = CUR_ARROW              -- reset each frame; drawTimeline raises it over draggable areas

  drawSidebar(dh)
  drawHeader()

  -- UI zoom stepper (top-right)
  do
    local px  = W - 16 - 26
    local lx  = px - 46
    local mnx = lx - 26
    if button(mnx, 12, 26, 24, '-') and uiIdx < #PCTS then
      uiIdx = uiIdx + 1; local w0,h0 = levelSize(uiIdx); pendingSize = {w=w0, h=h0}
    end
    txtc(PCTS[uiIdx]..'%', lx, 18, 46, C.mute, 2)
    if button(px, 12, 26, 24, '+') and uiIdx > 1 then
      uiIdx = uiIdx - 1; local w0,h0 = levelSize(uiIdx); pendingSize = {w=w0, h=h0}
    end
  end

  -- source switch
  for i,sw in ipairs(SRCSW) do
    local x = PADX + (i-1)*128
    if chip(x, 52, 120, 30, sw[1], S.tab==sw[2], 2) then S.tab = sw[2]; stopAudition() end
  end

  -- ---- the docked Song lane (bottom strip), laid out first so the work area knows its top ----
  local laneTop = dh - 168
  LANE.x, LANE.y, LANE.w, LANE.h = PADX, laneTop + 34, W - PADX - 16, dh - 60 - (laneTop + 34)
  -- song header + transport
  local sy = laneTop
  txt('SONG', PADX, sy+5, C.mute, 2)
  local info = (#S.song==0) and 'add blocks, then drag to arrange'
               or (#S.song..' block'..(#S.song==1 and '' or 's')..'  ·  '..songLen()..' bars')
  local tx = W - 16
  local function rbtn(w, label, primary)
    tx = tx - w; local hit_ = button(tx, sy, w, 26, label, primary); tx = tx - 6; return hit_
  end
  local hasLoop = S.loopA and S.loopB and S.loopB > S.loopA
  if rbtn(60, S.loop and 'loop: on' or 'loop: off', S.loop) then S.loop = not S.loop end
  if hasLoop and rbtn(78, 'Clear loop') then S.loopA, S.loopB = nil, nil; S.status='Loop cleared.' end
  if rbtn(58, 'Undo') then songUndoPop() end
  if rbtn(96, 'Clear song') then songSnapshot(); S.song, S.songSel, S.curFav = {}, nil, nil; S.loopA, S.loopB = nil, nil; stopAudition(); S.status='Song cleared  ·  Undo to restore.' end
  if rbtn(132, 'Send to REAPER', true) then S.playSong=true; insertAtCursor() end
  if rbtn(86, 'Export .mid') then exportMidi(true) end
  if rbtn(96, playing and S.playSong and 'Stop' or 'Play song') then
    if playing and S.playSong then stopAudition() else audition(true) end
  end
  -- the hint/summary fills whatever space is left of the leftmost button (dropped when the row is full)
  gfx.setfont(2)
  if (tx - 8) - (PADX+56) > gfx.measurestr(info) then txt(info, PADX+56, sy+5, C.mute, 2) end
  drawTimeline()

  -- ---- the work area for the active source: PADX-based, between the switch and the lane ----
  local WX = PADX
  local f = currentFrets()
  local bx, byT = WX+448, 96                      -- board on the right, info on the left
  local infoY = 96

  if S.tab==3 then                                 -- Progression
    local p = currentProg()
    local cs = progChords(p)
    local bar = math.min(playingBar(), #cs)
    f = cs[bar].frets
    txt(p.name ~= '' and p.name or (p.mood..' progression'), WX, infoY, C.ink, 3)
    gfx.setfont(4); local lx = WX
    for j,c in ipairs(cs) do col(j==bar and C.accent or C.mute); gfx.x=lx; gfx.y=infoY+30; gfx.drawstr(c.label)
      lx = lx + gfx.measurestr(c.label) + gfx.measurestr('  ') end
    local romans = {}
    for _,c in ipairs(cs) do romans[#romans+1] = analyze(S.keyPC,S.keyMode,pcOf(c.root),c.qual).numeral end
    txt(table.concat(romans,'   '), WX, infoY+60, C.mute, 2)
    txt('in '..NAMES[S.keyPC+1]..' '..(S.keyMode=='maj' and 'major' or 'minor')..'  ·  '..#cs..' bars', WX, infoY+80, C.mute, 2)
  elseif S.tab==4 then                             -- Riff
    txt(currentLabel()..' riff', WX, infoY, C.ink, 3)
    txt(currentDia(), WX, infoY+34, C.accent, 4)
    txt('procedural line · pedal root + scale · Re-roll for a new line', WX, infoY+66, C.mute, 2)
  else                                             -- Chord / Power
    local label = currentLabel()
    if S.tab==1 and S.inv>0 then
      local lo=999 for _,nt in ipairs(pitchesOf(f)) do if nt.pitch<lo then lo=nt.pitch end end
      label = label..'/'..NAMES[lo%12+1]
    end
    txt(label, WX, infoY, C.ink, 3)
    txt(currentDia(), WX, infoY+34, C.accent, 4)
    local INVN = {'1st inversion','2nd inversion','3rd inversion'}
    local meta = noteNames(f)
    if S.tab==1 then meta = meta..'   '..(S.inv>0 and INVN[S.inv] or CHORDS[S.root][S.qual].shape)
    else meta = meta..'   '..(S.three and 'root + 5th + octave' or 'root + 5th') end
    txt(meta, WX, infoY+64, C.mute, 2)
    local chordPC = pcOf(S.tab==1 and S.root or S.proot)
    local a = analyze(S.keyPC, S.keyMode, chordPC, S.tab==1 and S.qual or '5')
    txt(a.numeral..'  ·  '..a.func, WX, infoY+84, C.mute, 2)
  end
  drawBoard(f, bx, 112, W-16-bx, 90)          -- fixed height: never grows into the transport row

  -- transport row (source-level audition / insert / setup / add-to-song)
  local ty = 218
  if button(WX, ty, 96, 30, playing and not S.playSong and 'Stop' or 'Audition', not (playing and not S.playSong)) then
    if playing and not S.playSong then stopAudition() else audition(false) end
  end
  if button(WX+102, ty, 116, 30, 'Insert at cursor') then S.playSong=false; insertAtCursor() end
  if button(WX+224, ty, 84, 30, 'Save .mid') then exportMidi() end
  if button(WX+314, ty, 104, 30, 'Set up track') then setupTrack() end
  if button(WX+424, ty, 116, 30, '+ Add to Song', true) then songSnapshot(); addToSong(tabKind()) end
  if chip(WX+548, ty+2, 68, 26, S.loop and 'loop: on' or 'loop: off', S.loop, 2) then S.loop = not S.loop end

  -- ---- per-source selectors ----
  local y = ty + 46
  if S.tab==1 then                                 -- Chord
    txt('QUALITY', WX, y, C.mute, 2)
    if chip(WX+80, y-3, 92, 22, '+ extended', S.qualExt, 2) then S.qualExt = not S.qualExt end
    local qset = S.qualExt and QUALS_EXT or QUALS
    for i,q in ipairs(qset) do
      local x = WX + ((i-1)%8)*84
      local yy = y + 18 + math.floor((i-1)/8)*30
      if chip(x, yy, 80, 26, q, q==S.qual, 2) then S.qual=q; S.inv=0; audition(false) end
    end
    drawInKeyStrip(WX, y+82)
    txt('CHORD ROOT', WX, y+156, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = WX + ((i-1)%12)*56
      if chip(x, y+174, 52, 26, r, r==S.root, 2) then S.root=r; S.inv=0; audition(false) end
    end
    txt('INVERSION', WX, y+210, C.mute, 2)
    local invNames = {'root','1st','2nd','3rd'}
    for iv=0,3 do
      local x = WX + iv*88
      local avail = (iv==0) or (invertShape(S.root, S.qual, iv) ~= nil)
      if avail then
        if chip(x, y+228, 84, 26, invNames[iv+1], S.inv==iv, 2) then S.inv=iv; audition(false) end
      else
        box(x, y+228, 84, 26, C.chip, true); box(x, y+228, 84, 26, C.line, false)
        txtc(invNames[iv+1], x, y+235, 84, {0.36,0.37,0.40}, 2)
      end
    end
    txt('STRUM', WX, y+266, C.mute, 2)
    for i,st in ipairs(STRUM) do
      local x = WX + ((i-1)%5)*136
      local yy = y+284 + math.floor((i-1)/5)*30
      if iconChip(x, yy, 132, 26, i==S.strumIdx, st.name,
                  function(ix,iy,iw,ih,on) drawStrumIcon(ix,iy,iw,ih,st,on) end) then
        S.strumIdx=i; audition(false) end
    end
  elseif S.tab==2 then                             -- Power
    txt('ROOT', WX, y, C.mute, 2)
    for i,r in ipairs(ROOTS) do
      local x = WX + (i-1)*56
      if chip(x, y+18, 52, 26, r..'5', r==S.proot, 2) then S.proot=r; audition(false) end
    end
    if chip(WX, y+58, 84, 26, S.three and '3-note' or '2-note', S.three, 2) then S.three = not S.three; audition(false) end
    drawInKeyStrip(WX, y+94)
    txt('PATTERN', WX, y+168, C.mute, 2)
    for i,pp in ipairs(POWER) do
      local x = WX + ((i-1)%5)*140
      local yy = y+186 + math.floor((i-1)/5)*34
      if patternChip(x, yy, 136, 30, i==S.powerIdx, pp.name, pp) then S.powerIdx=i; audition(false) end
    end
  elseif S.tab==4 then                             -- Riff
    txt('SCALE', WX, y, C.mute, 2)
    for i,sc in ipairs(SCALES) do
      local x = WX + (i-1)*140
      if chip(x, y+18, 136, 26, sc.name, sc.key==S.scale, 2) then S.scale=sc.key; audition(false) end
    end
    do
      local bx2 = WX + 3*140 + 12
      box(bx2, y+16, 150, 30, C.chip, true); box(bx2, y+16, 150, 30, hit(bx2,y+16,150,30) and C.mute or C.line, false)
      drawDice(bx2+9, y+23, 16, (S.riffSeed - 1) % 6 + 1)
      txt('Re-roll', bx2+36, y+24, C.ink, 2)
      if clicked and hit(bx2, y+16, 150, 30) then S.riffSeed = S.riffSeed + 1; audition(false) end
    end
    drawInKeyStrip(WX, y+58)
    txt('RHYTHM', WX, y+132, C.mute, 2)
    for i,pp in ipairs(POWER) do
      local x = WX + ((i-1)%5)*140
      local yy = y+150 + math.floor((i-1)/5)*34
      if patternChip(x, yy, 136, 30, i==S.rhythmIdx, pp.name, pp) then S.rhythmIdx=i; audition(false) end
    end
  else                                             -- Progression (tab 3)
    txt('MOOD', WX, y, C.mute, 2)
    for i,m in ipairs(PROGS.moods) do
      local x = WX + ((i-1)%7)*100
      local yy = y+18 + math.floor((i-1)/7)*30
      local on = m==S.mood
      local hov = hit(x, yy, 94, 26)
      box(x, yy, 94, 26, on and C.accentDim or C.chip, true)
      box(x, yy, 94, 26, on and C.accent or (hov and C.mute or C.line), false)
      box(x+7, yy+9, 8, 8, moodCol(m), true)
      txt(m, x+22, yy+7, on and C.selink or C.ink, 2)
      if clicked and hov then S.mood=m; S.progSel=1; S.progScroll=0; stopAudition() end
    end
    local list = progList()
    local lx, ly, lw = WX, y+84, W-16-WX
    local rowH, rows = 24, 7
    progListRect = {lx, ly, lw, rowH*rows}
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
        box(lx, ry, 4, rowH, moodCol(p.mood), true)
        local names = {}
        for _,c in ipairs(progChords(p)) do names[#names+1] = c.label end
        local text = table.concat(names, ' - ')
        if p.name ~= '' then text = p.name..'    '..text end
        txt(text, lx+12, ry+5, sel and C.selink or C.ink, 2)
        if clicked and hov then S.progSel=idx; audition(false) end
      end
    end
    if #list > rows then
      local bh = rowH*rows * rows/#list
      local by = ly + (rowH*rows-bh) * (S.progScroll/maxScroll)
      box(lx+lw-5, ly, 5, rowH*rows, C.chip, true)
      box(lx+lw-5, by, 5, bh, C.mute, true)
    end
    txt(#list..' progressions · scroll to browse · click to audition', WX, ly+rowH*rows+6, C.mute, 2)
    txt('STRUM', WX, ly+rowH*rows+28, C.mute, 2)
    for i,st in ipairs(STRUM) do
      local x = WX + ((i-1)%5)*136
      local yy = ly+rowH*rows+46 + math.floor((i-1)/5)*30
      if iconChip(x, yy, 132, 26, i==S.strumIdx, st.name,
                  function(ix,iy,iw,ih,on) drawStrumIcon(ix,iy,iw,ih,st,on) end) then
        S.strumIdx=i; audition(false) end
    end
  end

  -- status bar
  box(0, dh-52, W, 52, C.panel, true)
  txt(S.status, 16, dh-36, C.mute, 2)
  do
    gfx.setfont(2); col(C.mute)
    local vs = 'v'..VERSION; local vw = gfx.measurestr(vs)
    gfx.x = W - vw - 16; gfx.y = dh-36; gfx.drawstr(vs)
  end
  if gfx.setcursor then gfx.setcursor(hoverCursor) end   -- feedback: resize/move cursor over draggable areas
end

local function loop()
  -- the UI is drawn on the fixed 720x812 canvas; fit it into the actual window
  -- (aspect preserved, letterboxed) and map the mouse back into canvas space
  local ww, wh = gfx.w, gfx.h
  do
    local dk, wx, wy = gfx.dock(-1, 0, 0, 0, 0)   -- dock state + position (macOS-safe)
    if wx then winX, winY, winDock = wx, wy, dk end
    winW, winH = ww, wh                            -- gfx.w/h is the size gfx.init expects
  end
  -- width governs the scale (never overflow); then grow the canvas *height* to exactly
  -- fill the window at that scale, so a tall docked window has no letterbox bars
  local s  = math.min(ww / W, wh / H)
  local Hc = math.max(H, math.floor(wh / s + 0.5))
  if Hc ~= drawHc then drawHc = Hc; gfx.setimgdim(CANVAS, W, Hc) end
  -- LANE geometry is set per-frame in draw() now (docked bottom strip)
  local dw, dh = W * s, Hc * s
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
    elseif hit(LANE.x, LANE.y, LANE.w, LANE.h) then
      local maxScroll = math.max(0, songLen() - 1)
      S.songScroll = math.max(0, math.min(maxScroll, S.songScroll - dir))
    end
    gfx.mouse_wheel = 0
  end

  gfx.dest = CANVAS                            -- render the UI to the offscreen canvas
  draw(Hc)
  gfx.dest = -1                                -- then blit it, scaled, into the window
  col(C.bg); gfx.rect(0, 0, ww, wh, 1)         -- letterbox fill around the canvas
  gfx.blit(CANVAS, 1, 0, 0, 0, W, Hc, ox, oy, dw, dh)

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
    if winX and winY then gfx.init(TITLE, pendingSize.w, pendingSize.h, winDock or 0, winX, winY)
    else gfx.init(TITLE, pendingSize.w, pendingSize.h, winDock or 0) end
    afterInit()
    pendingSize, mousePrev = nil, 1               -- swallow the click that resized
  end
  reaper.defer(loop)
end

reaper.atexit(function() panic(); saveState() end)
loop()
