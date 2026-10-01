; BN2 (US AE2E / EU AM2P): keep every style. Part of the Style Change QoL set (projects/bn2_styles = all of them).
.gba
.relativeinclude on
.open ROM_IN, ROM_OUT, 0x08000000
.include "../bn2_styles/common.asm"
.include "../bn2_styles/stylecap.asm"
.close
