.PHONY: all data test packs clean

all:
	@python3 src/build.py

data:
	@python3 src/make_data.py
	@python3 src/gen_progressions.py
	@$(MAKE) all

test: all
	@mkdir -p build
	@luac5.4 -p reaper/GuitarChordPack.lua && echo "lua syntax        ok"
	@lua5.4 tests/test_harmony.lua | tail -n 5
	@lua5.4 tests/test_events.lua
	@lua5.4 tests/test_analysis.lua
	@lua5.4 tests/test_progressions.lua
	@lua5.4 tests/test_riffs.lua
	@lua5.4 tests/test_song.lua
	@lua5.4 tests/test_song_fav.lua
	@lua5.4 tests/test_inversions.lua
	@lua5.4 tests/dump_analysis.lua >/dev/null && node tests/test_parity.js
	@node tests/test_arranger.js
	@lua5.4 tests/dump_riffs.lua >/dev/null && node tests/test_riffs_web.js
	@lua5.4 tests/dump_inversions.lua >/dev/null && node tests/test_inversions_web.js

packs:
	@python3 src/gen_chords.py
	@python3 src/gen_strum.py
	@python3 src/gen_power.py
	@echo "MIDI packs written to packs/"

clean:
	@rm -rf build packs
