; BN2 Style Change QoL (US AE2E / EU AM2P), all features. See NOTES.md for the research behind each address.
; Each feature also builds on its own: projects/bn2_{battles,elemchoice,allstyles,progress}.
.gba
.relativeinclude on
.open ROM_IN, ROM_OUT, 0x08000000
.include "common.asm"
.include "battles.asm"      ; Style Change every 100 battles
.include "elemchoice.asm"   ; pick the element
.include "stylecap.asm"     ; keep every style
.include "progress.asm"     ; battles left, in the MegaMan screen
.close
