; --- Keep every style: no 2-style cap ----------------------------------------------------------
; Vanilla holds Normal + 2 styles (+ Hub): a 3rd needs overwriting one, and the MegaMan-menu switcher
; keeps its list in a 4-byte buffer (menu+0x54) that overflows (and crashes) with more.
;   1. The scene never shows the overwrite prompt.
;   2. The type pick skips types whose 4 elements are all owned (else Style Change could only repeat
;      one), and a Style Change only triggers if some type can still give a new style.
;   3. The pre-rolled element (0x0200112B) excludes every element owned in ANY style, and rolling it
;      divides by zero once all four are owned: roll_next_element is disabled, and the scene setup
;      instead rolls one of the elements the picked type doesn't have yet. (elemchoice.asm, if
;      present, then lets the player override it.)
;   4. The switcher shows the styles a page at a time (up to 4 + "More" + "Cancel"), looking them up on
;      the fly instead of storing a list. Pages hold whole groups (Normal + Hub, then one per type), so
;      with every style each type gets its own page. menu+0x54 now holds the page's first entry.

STYLE_ITEMS     equ 0x02000E80      ; item quantities; style item 0x80 + type*5 + elem holds its level
STYLE_POINTS    equ 0x02003A68      ; u32[4]: Guts, Custom, Team, Shield
ACTIVE_STYLE    equ 0x02000DC1      ; level<<6 | type<<3 | elem
STYLE_CODES     equ (0x08029A6C + OFS_MENU)      ; item-0x80 -> type<<3 | elem
SELECTED        equ (0x08020F50 + OFS_LOW)      ; -> index of the option picked in a select menu
FOLDER          equ (0x08025634 + OFS_MENU)      ; -> current folder
NAVI_LIMIT      equ (0x08029E5C + OFS_MENU)      ; (folder, type) -> flags "gt" if too many NaviChips for type
PLAY_SOUND      equ (0x08000598 + OFS_BOOT)
RNG             equ (0x08001494 + OFS_BOOT)      ; -> r0 random (uses r0-r3, r7)
SCENE_SETUP     equ (0x0801250C + OFS_LOW)      ; (type, elem): Style Change scene setup
PAGE_SIZE       equ 4
PAGE            equ 0x54        ; menu byte: first entry of the switcher page shown (was the 4-byte list)

; 1. cap check after the element text: count_styles() >= 0xFF never happens
.org (0x08012408 + OFS_LOW)
.thumb
    cmp     r0, 0xFF

; 2a. type pick: replace the points argmax (still inside pick_style_type's push {lr})
.org (0x08011612 + OFS_LOW)
.thumb
    ldr     r7, =pick_type_new|1
    bx      r7
.pool

; 2b. battle counter: only flag a Style Change if pick_style_type has something to give
;     (0x08004E24.. is main.asm's counter compare; this replaces its setFlag(0, 0x2A) call)
.org (0x08004E2C + OFS_LOW)
.thumb
    ldr     r7, [pc, 0]
    bx      r7
    .word   maybe_flag_change|1

; 3. roll_next_element: return immediately
.org (0x08011634 + OFS_LOW)
.thumb
    mov     r15, r14

; 3b. scene setup (0x08005FFC): replace "elem = pre-rolled byte" after pick_style_type
.org (0x08006002 + OFS_LOW)
.thumb
    ldr     r7, [pc, 4]
    bx      r7
    nop
    .word   setup_scene|1           ; 0x08006008; back at 0x08006010

; 5. style trade (link): its list builder (0x0802C45C) copies every owned style into text buffers
;    1..3 and menu+0x58 without a bound. Stop after 3 (the most vanilla could have): only the first
;    three styles can be traded, but nothing overflows.
.org (0x0802C49E + OFS_MENU)
.thumb
    ldr     r0, [pc, 4]
    bx      r0
    nop
    .word   trade_list_next|1

; 4. switcher: the list builder only counts (menu[3]); our steps 0 (open) and 4 (pick) take over
.org (0x08029A62 + OFS_MENU)
.thumb
    nop
.org (0x080297C4 + OFS_MENU)
    .word   switcher_open|1
    .word   switcher_pick|1

.org STYLECAP_SPACE
.align 4
.thumb

; r0 = type -> Z set if all four elements of it are owned
type_full:
    mov     r1, 5
    mul     r1, r0
    ldr     r2, =STYLE_ITEMS + 0x80
    add     r2, r2, r1
    mov     r1, 1
@@loop:
    ldrb    r3, [r2, r1]
    cmp     r3, 0
    beq     @@no
    add     r1, 1
    cmp     r1, 4
    ble     @@loop
    mov     r0, 0                   ; Z = full
    bx      r14
@@no:
    mov     r0, 1
    bx      r14

pick_type_new:                      ; return (via the vanilla push {lr}) the not-full type with most points
    push    r4-r6
    mov     r4, 0                   ; best type
    mov     r5, 0                   ; best points
    mov     r6, 1
@@loop:
    mov     r0, r6
    bl      type_full
    beq     @@next
    ldr     r1, =STYLE_POINTS - 4
    lsl     r2, r6, 2
    ldr     r1, [r1, r2]
    cmp     r4, 0
    beq     @@take
    cmp     r1, r5
    blt     @@next                  ; ties go to the later type, like vanilla
@@take:
    mov     r4, r6
    mov     r5, r1
@@next:
    add     r6, 1
    cmp     r6, 4
    ble     @@loop
    mov     r0, r4
    pop     r4-r6
    pop     r15

maybe_flag_change:                  ; from the battle counter; must end at its pop {r5, pc}
    ldr     r7, =PICK_TYPE|1
    bl      @@call_r7
    cmp     r0, 0
    beq     @@done
    mov     r0, 0
    mov     r1, 0x2A
    ldr     r7, =FLAG_SET|1
    bl      @@call_r7
@@done:
    ldr     r7, =(0x08004E35 + OFS_LOW)         ; pop {r5, pc}
    bx      r7
@@call_r7:
    bx      r7

setup_scene:                        ; r0 = type; still inside the vanilla setup's push {lr}
    push    r4, r6
    mov     r4, r0                  ; type
    mov     r6, 0                   ; element: none for Hub
    cmp     r0, 5
    beq     @@set
    mov     r0, 5
    mul     r0, r4
    ldr     r2, =STYLE_ITEMS + 0x80
    add     r2, r2, r0
    mov     r0, 0                   ; elements not owned yet for this type
    mov     r1, 1
@@count:
    ldrb    r3, [r2, r1]
    cmp     r3, 0
    bne     @@counted
    add     r0, 1
@@counted:
    add     r1, 1
    cmp     r1, 4
    ble     @@count
    mov     r6, 1
    cmp     r0, 0
    beq     @@set                   ; can't happen (pick_type_new skips full types)
    mov     r6, r0
    ldr     r7, =RNG|1
    bl      @@call_r7
    mov     r1, r6
    swi     6                       ; r1 = random % n
    mov     r6, r1
    mov     r0, 5
    mul     r0, r4
    ldr     r2, =STYLE_ITEMS + 0x80
    add     r2, r2, r0
    mov     r0, 1
@@walk:                             ; the r6-th (from 0) element not owned yet
    ldrb    r3, [r2, r0]
    cmp     r3, 0
    bne     @@walk_next
    sub     r6, 1
    bmi     @@found
@@walk_next:
    add     r0, 1
    b       @@walk
@@found:
    mov     r6, r0
@@set:
    mov     r0, r4
    mov     r1, r6
    ldr     r7, =SCENE_SETUP|1
    bl      @@call_r7
    pop     r4, r6
    ldr     r7, =(0x08006011 + OFS_LOW)         ; movs r0, 4 / strb r0, [r5, 2] / pop {pc}
    bx      r7
@@call_r7:
    bx      r7

trade_list_next:                    ; loop tail of 0x0802C45C: r8 = item - 0x80, sb = styles listed
    mov     r0, r8
    add     r0, 1
    mov     r8, r0
    cmp     r0, 0x19
    bgt     @@end
    mov     r1, r9
    cmp     r1, 3
    bge     @@end
    ldr     r1, =(0x0802C479 + OFS_MENU)         ; next item; the loop expects r0 = r8
    bx      r1
@@end:
    ldr     r0, =(0x0802C4A9 + OFS_MENU)         ; mov r0, sb / pop {r5, pc}
    bx      r0

; r0 = n -> r0 = item id of the n-th style the switcher offers (owned, not active), or 0
nth_style:
    push    r4, r14
    ldr     r1, =ACTIVE_STYLE
    ldrb    r1, [r1]
    lsl     r1, r1, 26
    lsr     r1, r1, 26              ; type<<3 | elem
    ldr     r2, =switch_order
@@loop:
    ldrb    r3, [r2]
    cmp     r3, 0
    beq     @@none
    add     r2, 1
    ldr     r4, =STYLE_ITEMS
    ldrb    r4, [r4, r3]
    cmp     r4, 0
    beq     @@loop                  ; not owned
    ldr     r4, =STYLE_CODES - 0x80
    ldrb    r4, [r4, r3]
    cmp     r4, r1
    beq     @@loop                  ; active
    sub     r0, 1
    bge     @@loop
    mov     r0, r3
    pop     r4, r15
@@none:
    mov     r0, 0
    pop     r4, r15

switch_order:                       ; Normal and Hub first (always on page 1), then Guts, Custom, Team, Shield
    .byte   0x80, 0x99, 0x86, 0x87, 0x88, 0x89, 0x8B, 0x8C, 0x8D, 0x8E, 0x90, 0x91, 0x92, 0x93
    .byte   0x95, 0x96, 0x97, 0x98, 0
.align 2

; r0 = item -> r0 = its switcher group: 0 = Normal/Hub, 1..4 = type
style_group:
    ldr     r1, =STYLE_CODES - 0x80
    ldrb    r0, [r1, r0]
    lsr     r0, r0, 3
    cmp     r0, 5
    bne     @@done
    mov     r0, 0
@@done:
    bx      r14

; r0 = first entry s -> r0 = entries on the page starting there: as many whole groups as fit in
; PAGE_SIZE (a group never splits; none is larger than PAGE_SIZE).
page_len:
    push    r4-r7, r14
    mov     r4, r0                  ; i
    mov     r6, 0                   ; k
@@group:
    mov     r0, r4
    bl      nth_style
    cmp     r0, 0
    beq     @@done
    bl      style_group
    mov     r7, r0                  ; this group
    mov     r5, r4                  ; j
@@size:
    add     r5, 1
    mov     r0, r5
    bl      nth_style
    cmp     r0, 0
    beq     @@sized
    bl      style_group
    cmp     r0, r7
    beq     @@size
@@sized:
    sub     r0, r5, r4              ; group size
    add     r0, r6, r0
    cmp     r0, PAGE_SIZE
    bgt     @@done
    mov     r6, r0
    mov     r4, r5
    b       @@group
@@done:
    mov     r0, r6
    pop     r4-r7
    pop     r1
    bx      r1

; r5 = menu -> r0 = styles on this page (k), r1 = 1 if there is a "More" option, r2 = first entry
page_shape:
    push    r4, r14
    mov     r4, PAGE
    ldrb    r4, [r5, r4]
    mov     r0, r4
    bl      page_len
    mov     r1, 1
    cmp     r4, 0
    bne     @@done
    ldrb    r2, [r5, 3]
    cmp     r0, r2
    blt     @@done
    mov     r1, 0                   ; the first page holds everything
@@done:
    mov     r2, r4
    pop     r4
    pop     r3
    bx      r3

; r5 = menu. Shows the page starting at entry menu[PAGE]: text buffers 1..k, then style_menu script.
show_page:
    push    r4, r6, r14
    bl      page_shape
    push    r0, r1
    mov     r4, r2                  ; entry
    mov     r6, r0                  ; k
    mov     r7, r10
    ldr     r7, [r7, 0x48]
    add     r7, 0x34                ; text buffer 1
@@fill:
    push    r7
    mov     r0, r4
    bl      nth_style
    pop     r7
    str     r0, [r7]
    add     r7, 4
    add     r4, 1
    sub     r6, 1
    bne     @@fill
    pop     r0, r1
    lsl     r0, r0, 1
    sub     r0, 1                   ; 1 + (k-1)*2
    add     r1, r0, r1              ; + "More"
    ldr     r0, =style_menu_text
    ldr     r7, =TEXT_START|1
    bl      @@call_r7
    pop     r4, r6, r15
@@call_r7:
    bx      r7

switcher_open:                      ; step 0: vanilla shows "You have no styles" or script 54-56
    push    r5, r14
    ldrb    r0, [r5, 3]
    cmp     r0, 0
    bne     @@styles
    mov     r0, 8
    strb    r0, [r5, 2]
    ldr     r0, =MENU_TEXT
    mov     r1, 0x35
    ldr     r7, =TEXT_START|1
    bl      @@call_r7
    pop     r5, r15
@@styles:
    mov     r0, 0
    mov     r1, PAGE
    strb    r0, [r5, r1]            ; first page
    mov     r0, 4
    strb    r0, [r5, 2]
    bl      show_page
    pop     r5, r15
@@call_r7:
    bx      r7

switcher_pick:                      ; step 4: wait for the choice
    push    r4, r5, r14
    mov     r0, 0x20
    ldr     r7, =TEXT_STATUS|1
    bl      @@call_r7
    cmp     r0, 0
    beq     @@return
    ldr     r7, =SELECTED|1
    bl      @@call_r7
    mov     r4, r0
    bl      page_shape
    cmp     r4, r0
    blt     @@style
    cmp     r1, 0
    beq     @@cancel
    cmp     r4, r0
    bne     @@cancel                ; "Cancel" (or B)
    add     r0, r2, r0              ; "More": the next page starts after this one, wrapping around
    ldrb    r2, [r5, 3]
    cmp     r0, r2
    blt     @@page_ok
    mov     r0, 0
@@page_ok:
    mov     r1, PAGE
    strb    r0, [r5, r1]
    bl      show_page
    b       @@return
@@cancel:
    mov     r0, 8
    strb    r0, [r5, 2]
    b       @@return

@@style:                            ; same as vanilla 0x08029828..0x0802989A, for item nth_style(first + i)
    add     r0, r2, r4
    bl      nth_style
    mov     r4, r0                  ; item
    ldr     r7, =FOLDER|1
    bl      @@call_r7
    ldr     r1, =STYLE_CODES - 0x80
    ldrb    r1, [r1, r4]
    lsr     r1, r1, 3               ; type
    ldr     r7, =NAVI_LIMIT|1
    bl      @@call_r7
    bgt     @@too_many
    mov     r7, r10
    ldr     r7, [r7, 0x48]
    str     r4, [r7, 0x34]          ; for "Set to <style>"
    ldr     r1, =STYLE_CODES - 0x80
    ldrb    r1, [r1, r4]
    ldr     r0, =STYLE_ITEMS
    ldrb    r0, [r0, r4]            ; level 1..3
    sub     r0, 1
    lsl     r0, r0, 6
    orr     r1, r0
    ldr     r0, =ACTIVE_STYLE
    strb    r1, [r0]
    mov     r0, 0x30
    strb    r0, [r5, 0xE]
    mov     r1, 0x2B                ; "Normal Style!"
    cmp     r4, 0x80
    beq     @@normal
    mov     r1, 0x2C                ; "Set to <style>"
@@normal:
    ldr     r0, =MENU_TEXT
    ldr     r7, =TEXT_START|1
    bl      @@call_r7
    mov     r0, 0xE7
    ldr     r7, =PLAY_SOUND|1
    bl      @@call_r7
    mov     r0, 8
    strb    r0, [r5, 2]
    b       @@return
@@too_many:
    mov     r0, 0x1C
    strb    r0, [r5, 1]
    mov     r0, 0
    strb    r0, [r5, 2]
    ldr     r0, =MENU_TEXT
    mov     r1, 0x39
    ldr     r7, =TEXT_START|1
    bl      @@call_r7
    mov     r0, 0x6C
    ldr     r7, =PLAY_SOUND|1
    bl      @@call_r7
@@return:
    pop     r4, r5, r15
@@call_r7:
    bx      r7

.pool
.align 4
style_menu_text:
    .import "style_menu.msg"

.if . > PROGRESS_SPACE
    .error "stylecap.asm overflows its free space"
.endif
