; --- Battles needed for a Style Change ---------------------------------------
; Vanilla: counter++; if (counter == 280) setFlag(42)
; Now:     counter++; if (counter >= STYLE_BATTLES) setFlag(42)
; ">=" so saves already past the new threshold (or mid-way to 280) still trigger.
; progress.asm reads the threshold back from these instructions.
STYLE_BATTLES   equ 100     ; vanilla 280; must fit in 8 bits (movs imm)

.org (0x08004E24 + OFS_LOW)
.thumb
    mov     r1, STYLE_BATTLES
    nop
    cmp     r0, r1
    blt     (0x08004E34 + OFS_LOW)
