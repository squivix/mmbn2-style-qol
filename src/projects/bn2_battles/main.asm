; BN2 (US AE2E / EU AM2P): Style Change every 100 battles. Part of the Style Change QoL set (projects/bn2_styles = all of them).
.gba
.relativeinclude on
.open ROM_IN, ROM_OUT, 0x08000000
.include "../bn2_styles/common.asm"
.include "../bn2_styles/battles.asm"
.close
