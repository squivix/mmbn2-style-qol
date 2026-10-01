; --- Battles left until the next Style Change -------------------------------------------------
; A small number in the MegaMan screen's title bar, between "MegaMan.exe" and "LV.": the battles
; left until the next Style Change. Only the count is shown, never the style points or which style
; comes next. Shown only once Style Changes are enabled (flag 0x2B, same check as the battle
; counter) and while some new style can still be earned.
;
; The threshold is read back from the battle counter's compare (0x08004E24), so this works with
; vanilla's 280 as well as battles.asm's 100.
;
; Drawn with the screen's own digit tiles (BG2, tiles 0x1E0 + 2*d over 0x1E1 + 2*d, palette 4, the
; ones "LV.100" uses) into BG2's tilemap buffer, from the end of the style-list builder 0x08029988,
; which runs when the screen opens and again after a style switch or cancel.

BATTLE_COUNTER  equ 0x02000DE4
FLAG_STYLES_ON  equ 0x2B
BG2_MAP         equ 0x03001000      ; BG2 tilemap buffer, copied to VRAM 0x0600F000
COUNT_LAST_COL  equ 19              ; rightmost digit column (row 0-1); "LV." starts at column 22
DIGIT_TILE      equ 0x4000 | 0x1E0  ; palette 4, digit 0 top half

.org (0x08029A1E + OFS_MENU)                     ; r1 = 0x28 / 0x29, menu[7] already set; replaces the text start + pop {pc}
.thumb
    ldr     r7, [pc, 4]
    bx      r7
    nop
    .word   progress_draw|1

.org PROGRESS_SPACE
.align 4
.thumb
progress_draw:                      ; still inside the list builder's push {lr}
    push    r4, r6
    mov     r4, r1                  ; vanilla text script
    mov     r0, 0
    mov     r1, FLAG_STYLES_ON
    ldr     r7, =FLAG_TEST|1
    bl      @@call_r7
    cmp     r0, 0
    beq     @@text
    ldr     r7, =PICK_TYPE|1
    bl      @@call_r7
    cmp     r0, 0
    beq     @@text                  ; nothing left to earn
    ldr     r0, =BATTLE_COUNTER
    ldr     r0, [r0]
    ldr     r2, =(0x08004E24 + OFS_LOW)         ; movs r1, #imm (+ adds r1, #0xFF in vanilla: 0x19 + 0xFF = 280)
    ldrb    r1, [r2]
    ldrh    r3, [r2, 2]
    ldr     r2, =0x31FF             ; adds r1, #0xFF
    cmp     r3, r2
    bne     @@threshold
    add     r1, 0xFF
@@threshold:
    sub     r6, r1, r0              ; battles left (the counter can be past the threshold: show 1)
    cmp     r6, 1
    bge     @@n_ok
    mov     r6, 1
@@n_ok:
    ldr     r2, =BG2_MAP + COUNT_LAST_COL * 2       ; top row
    ldr     r7, =BG2_MAP + COUNT_LAST_COL * 2 + 64  ; bottom row
    mov     r0, 0                   ; clear the 3 digit cells first
    strh    r0, [r2]
    strh    r0, [r7]
    sub     r1, r2, 2
    strh    r0, [r1]
    sub     r1, r7, 2
    strh    r0, [r1]
    sub     r1, r2, 4
    strh    r0, [r1]
    sub     r1, r7, 4
    strh    r0, [r1]
@@digit:                            ; right to left; at least one digit
    mov     r0, r6
    mov     r1, 10
    swi     6                       ; r0 = n / 10, r1 = n % 10 (BIOS Div keeps r2 and r7)
    mov     r6, r0
    lsl     r1, r1, 1
    ldr     r0, =DIGIT_TILE
    add     r0, r0, r1
    strh    r0, [r2]                ; top half
    add     r0, 1
    strh    r0, [r7]                ; bottom half
    sub     r2, 2
    sub     r7, 2
    cmp     r6, 0
    bne     @@digit
@@text:
    mov     r1, r4
    ldr     r0, =MENU_TEXT
    ldr     r7, =TEXT_START|1
    bl      @@call_r7
    pop     r4, r6
    pop     r15
@@call_r7:
    bx      r7

.pool

.if . > PROGRESS_END
    .error "progress.asm overflows its free space"
.endif
