# BN2 Style Change QoL — research notes (US, AE2E rev 0)

## Goals (2026-10-01)
1. Style Change every **100** battles (vanilla 280), `>=` compare. — DONE, verified in-game 2026-10-01.
2. **Choose the element** at Style Change (4-option text-box menu: Elec/Heat/Aqua/Wood) instead of the pre-rolled 0x0200112B.
   — DONE (elemchoice.asm + gen_text.py): the menu offers only elements not owned for the type.
3. **Keep all styles**: 16 elemental + Hub + Normal. Storage already supports it (items 0x80..0x99).
   Needs: remove cap check (0x08012408), skip replace prompt, rework MegaMan-menu style list (0x08029988 writes
   unbounded into a 4-entry buffer at menu+0x54 → crash) into a paged text-box menu (3 styles + "More").
   — DONE (stylecap.asm): no overwrite prompt; type pick skips full types
   and returns 0 when nothing is left (then the battle counter doesn't flag a Style Change); roll_next_element
   disabled; switcher pages hold whole groups (Normal+Hub, Guts, Custom, Team, Shield; max 4 + More + Cancel; B cancels, More wraps); style-trade list clamped to 3.
   NaviChip limit verified: 7 NaviChips + ElecTeam → ElecGuts refused (vanilla message), → Hub allowed.

4. **Show progress**: battles remaining until the next Style Change (from 0x02000DE4 vs STYLE_BATTLES), e.g. in
   the MegaMan menu. Do NOT show style points or the upcoming style/type — the result should stay a surprise.
   — DONE (progress.asm): small number in the MegaMan screen's title bar (BG2 buffer 0x03001000, cols 17-19,
   digit tiles 0x1E0+2d / 0x1E1+2d pal 4), drawn at the end of the list builder. Hidden before flag 0x2B or when
   nothing is left to earn. Verified at 37, 100, 1; nothing lingers after leaving the screen.
   (A text-box version was tried first; it was too conspicuous.)
   Text engine: printBuffer buffer 0 = Zenny (hard-wired), buffer N = text+0x34+(N-1)*4 (0x08021C18).

## Release layout (v1.0, published 2026-10-01: github.com/squivix/mmbn2-style-qol)
Each feature is its own file with its own free-space slice and builds alone (`projects/bn2_battles`, `bn2_elemchoice`,
`bn2_allstyles`, `bn2_progress`; `bn2_styles` = all): the per-feature patches touch disjoint bytes, so their IPS stack
in any order and the union equals the combined ROM (checked for all 24 orders). Cross-feature details:
- stylecap.asm alone: the scene setup (0x08006002) rolls a random element the picked type doesn't own; elemchoice.asm
  then overrides it if present. (Vanilla's pre-roll excludes elements owned in ANY style.)
- progress.asm reads the threshold back from 0x08004E24 (movs imm + optional adds 0xFF), so it works with 280 too.
- EU (AM2P): same RAM and text archives; code shifted +4 (< 0x08004000), +0xC (0x08004E14..0x080247A0),
  +0x144 (0x08025634..0x0802C4A9); free space 0x087F9088..end. Offsets in common.asm. US saves load in EU.
  EU verified in-game: boot with US save, MegaMan screen count, switcher paging and switching. The EU Style Change
  scene itself was not run (no EU battle savestate yet); its hook bytes match US exactly apart from pointers.

Test save: `python savetool.py <real.sav> --battles 99 --out ..\..\build\bn2_styles.sav` (makes a test copy of a save).

Base ROM: `roms/bn2_us.gba`, sha1 `601b5012f77001d2c5c11b31304afafc45a70d0b`.
Free space: 0xB4F0 bytes of 0xFF at `0x087F4B10` (same `fspace` Prof9's BN2-Plus uses — confirms US offsets).

## Prior art
- No existing hack found that changes Style Change (searched RHDN listings via web, TREZ forums, Nexus, GitHub).
- Prof9/bn2-plus (`reference/bn2-plus`): jack-in animation + Flappy AI fix only. Useful refs: memcpy `0x08000B50`, setTile `0x08001774`.
- vgperson/MMBNSaveEditor, functionFox/NaviDoctorLC (`reference/`): save layout. GBA save offset == RAM offset from 0x02000000.
- Mechanics summary: therockmanexezone.com/wiki/Style_Change_(MMBN2).

## RAM
`r10` = 0x0800049C (toolkit pointer table). `[r10+8]` = 0x02000DC0 (game state), `[r10+0x78]` = 0x02001120.

| Addr | Size | Meaning |
|---|---|---|
| 0x02000DC1 | u8 | active style: `level<<6 \| type<<3 \| elem` (level 0..2 = V1..V3) |
| 0x02000DE4 | u32 | battles since last style change (gamestate+0x24) |
| 0x02000DA1 | u8[16] | per-style version-up battle counters, index (type-1)*4 + (elem-1) |
| 0x02000E80 | u8[] | key item quantities. Styles are items 0x80 + type*5 + elem (Normal=0x80, Hub=0x99) |
| 0x02000F00 | u8[0x1A] | = items 0x80..0x99: style level 0 (none) / 1..3 |
| 0x0200112B | u8 | **pre-rolled element for the next style change** |
| 0x02003A68 | u32[4] | style points: Guts, Custom, Team, Shield |
| flag 0x2A (42) | | style change pending (set when counter hits 280) |
| flag 0x2B (43) | | style change system enabled / first-style guard |
| flag 0x6C | | Hub Style already offered |

Types: 1 Guts, 2 Custom, 3 Team, 4 Shield, 5 Hub. Elements: 1 Elec, 2 Heat, 3 Aqua, 4 Wood.
Flags: bitfield at 0x02000000 (flag n = byte n>>3, bit 0x80>>(n&7)); set 0x0801BF08 / clear 0x0801BF24 /
test 0x0801BF40 (r0=0, r1=flag). Flag 0x2A = bit 0x20 of 0x02000005.

## Code
| Addr | What |
|---|---|
| 0x08004E1A | after eligible battle: `counter++; if (counter == 0x19+0xFF /*280*/) setFlag(42)` — imm at 0x08004E24/26, `bne` at 0x08004E2A |
| 0x080247A0 | `item_count(id)` |
| 0x08024774 | `item_set(id, n)` |
| 0x080247A8 | `count_styles()` — counts items 0x81..0x99 |
| 0x080115F0 | `pick_style_type()` — Hub if !flag6C && styles>=2 && navi-S-ranks>=17, else argmax style points (ties → later index) |
| 0x080116B8 | count of V3-navi S-rank flags (table 0x080116E0, pairs, 0xFF end) |
| 0x08005FFC | style-change scene setup: type = pick_style_type(); elem = byte[0x0200112B] (Hub: elem 0) → 0x0801250C |
| 0x0801250C | stores (type, elem) into scene struct 0x0200F010 (+6 type, +7 elem) |
| 0x08012404 | **cap check**: `count_styles(); cmp r0,#2; bge → replace-prompt state` else just give style |
| 0x0801257A | collects owned style item ids 0x86..0x99 into a 4-byte stack buffer, returns first two (replace prompt). Overflows with >4 styles. |
| 0x080124E4 | after style change: clear flag 42, reset counter (0x08012500), call roll_next_element |
| 0x08011634 | `roll_next_element()`: mask of owned elems, candidates = elems not owned, `rand() % n` → 0x0200112B. n==0 → div by zero (matters if cap raised) |
| 0x0801142A | per-battle version-up counter; thresholds table 0x08011498 = `78 A0 82 64` (120/160/130/100) |
| 0x080114D0 | level up current style |
| 0x08001494 | RNG |
| 0x0802968A, 0x0802B20A, 0x0805C0F6 | other `count_styles` callers — MegaMan menu style switcher (to RE for raising cap) |
| 0x08005C98.. | post-battle state machine (r5): flag 0x2A → state 0x10 = style change (0x08005FE0 table: setup 0x08005FFC, run 0x08006016) |

Cheat-site note: >3 styles registered at once crashes when switching styles in the MegaMan menu.

## MegaMan-menu style switcher (menu struct r5; step table 0x080297C4)
- 0x08029988 list builder: for each style item (0x80, 0x86..0x99) owned and not active, 0x08029A28 appends
  `(level-1)<<6 | code` (code table 0x08029A6C) to menu+0x54 (4 bytes, unbounded) and counts → menu[3].
- Step 0 0x080297D0: script 0x35 ("no styles") or 0x35+count (54/55/56, 1-3 styles + Cancel) with item ids in
  text buffers 1-4 (text struct +0x34..+0x40). Step 4 0x08029814: index = 0x08020F50(); == count → cancel; else
  NaviChip limit check 0x08029E5C(folder 0x08025634(), type) (limit 8 for Team/Hub, else 5) → script 0x39, or set
  active style, script 0x2B/0x2C, sound 0xE7.
- Style trade (link, scripts 0x77..0x7B): list builder 0x0802C45C fills text buffers + menu+0x58 unbounded.

## Style Change scene (0x0200F010, runner 0x0801227C, setup 0x0801250C(type, elem))
Plays on the battle field right after the results screen.
Bytes: +0 state (0 init, 4 run, 8 finish 0x080124E4), +1 sub, +2 step, +3 text phase, +4/+5 old type/elem,
+6/+7 new type/elem, +8 running, +0xA timer.
- Sub 0 steps (table 0x080122E4): 0 fade (0x080122F0); 4 load scene + transformation 0x08091CC8(oldT, oldE, newT, newE)
  + fade in; 8 intro text (msg 0 the first time / msg 50 later). The sprite switches to the new style during the
  intro text, so the element must be chosen before step 4 — elemchoice.asm hooks step 0.
- Sub 4 (0x080123D0): element text (msg by elem from table 0x08012428: Elec 30, Heat 10, Aqua 20, Wood 40;
  Hub = msg 10), then `count_styles() >= 2` → sub 8 replace prompt (msg 60; answer in flags 0x39/0x3A, the two
  owned ids in 0x02008730+0x34/+0x38).
- Text archives per type: table 0x08012544 (Guts 0x08730CEC, Custom 0x0872FF04, Team 0x0872F128, Shield 0x08731AC8,
  Hub 0x0873298C). Extract with tools/textpet (see gen_text.py for the command line).
- Text API: 0x08020B88(archive, script) starts a script (clobbers r4/r6); 0x08020F44(0x80) is nonzero while a box
  is open. Text struct = [r10+0x48] = 0x02008730.
