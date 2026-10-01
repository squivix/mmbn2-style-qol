; --- Choose the element at a Style Change -------------------------------------
; The Style Change scene (struct 0x0200F010, run by 0x0801227C) starts with the transformation
; (0x08091CC8 gets old and new type/element) before any text, so the choice must come first.
; New first step: MegaMan asks for an element, the menu only offers the ones this style type
; doesn't have yet, and the answer replaces the pre-rolled element in scene+7. Then the vanilla
; step (fade out, 0x080122F0) runs as before. Hub Style (type 5) has no element: no menu.
;
; Scene struct: +3 text phase (0 = not shown, 4 = waiting; vanilla expects 0 after us),
;               +6 new type, +7 new element.
; The menu scripts (gen_text.py) leave elem-1 in flags 0x39 (bit 0) / 0x3A (bit 1): the
; replace prompt later in the same scene uses those as scratch too, and so do we.

SCENE           equ 0x0200F010
SCENE_STEP0     equ (0x080122E4 + OFS_LOW)      ; jump-table slot: sub-state 0, step 0
VANILLA_STEP0   equ (0x080122F0 + OFS_LOW)
FLAG_LO         equ 0x39
FLAG_HI         equ 0x3A

.org SCENE_STEP0
    .word elem_choice|1

.org ELEMCHOICE_SPACE
.align 4
.thumb
elem_choice:                        ; r5 = SCENE
    push    r4, r6, r14
    ldrb    r0, [r5, 6]
    cmp     r0, 5
    beq     @@vanilla               ; Hub Style
    ldrb    r0, [r5, 3]
    cmp     r0, 0
    bne     @@waiting

    ; mask of elements (bit e-1) whose style item 0x80 + type*5 + e isn't owned yet
    mov     r4, 0
    mov     r6, 1
@@scan:
    ldr     r5, =SCENE
    ldrb    r0, [r5, 6]
    mov     r1, 5
    mul     r0, r1
    add     r0, r0, r6
    add     r0, 0x80
    ldr     r7, =ITEM_COUNT|1
    bl      @@call_r7
    cmp     r0, 0
    bne     @@owned
    mov     r0, 1
    sub     r1, r6, 1
    lsl     r0, r1
    orr     r4, r0
@@owned:
    add     r6, 1
    cmp     r6, 4
    ble     @@scan
    ldr     r5, =SCENE
    cmp     r4, 0
    beq     @@vanilla               ; nothing left to pick: keep the pre-rolled element

    ldr     r0, =elem_choice_text
    mov     r1, r4                  ; script N = menu for mask N
    ldr     r7, =TEXT_START|1
    bl      @@call_r7
    ldr     r5, =SCENE
    mov     r0, 4
    strb    r0, [r5, 3]
    b       @@return

@@waiting:
    mov     r0, 0x80
    ldr     r7, =TEXT_STATUS|1
    bl      @@call_r7
    cmp     r0, 0
    bne     @@return                ; menu still open
    mov     r4, 1                   ; element = 1 + flag39 + 2*flag3A
    mov     r0, 0
    mov     r1, FLAG_LO
    ldr     r7, =FLAG_TEST|1
    bl      @@call_r7
    cmp     r0, 0
    beq     @@lo_clear
    add     r4, 1
@@lo_clear:
    mov     r0, 0
    mov     r1, FLAG_HI
    ldr     r7, =FLAG_TEST|1
    bl      @@call_r7
    cmp     r0, 0
    beq     @@hi_clear
    add     r4, 2
@@hi_clear:
    mov     r0, 0
    mov     r1, FLAG_LO
    ldr     r7, =FLAG_CLEAR|1
    bl      @@call_r7
    mov     r0, 0
    mov     r1, FLAG_HI
    ldr     r7, =FLAG_CLEAR|1
    bl      @@call_r7
    ldr     r5, =SCENE
    strb    r4, [r5, 7]
    mov     r0, 0
    strb    r0, [r5, 3]             ; vanilla's first text step expects 0

@@vanilla:                          ; tail-call the vanilla step with our caller's lr
    ldr     r5, =SCENE
    pop     r4, r6
    pop     r0
    mov     r14, r0
    ldr     r7, =VANILLA_STEP0|1
    bx      r7

@@return:
    pop     r4, r6, r15

@@call_r7:
    bx      r7

.pool
.align 4
elem_choice_text:
    .import "elem_choice.msg"

.if . > STYLECAP_SPACE
    .error "elemchoice.asm overflows its free space"
.endif
