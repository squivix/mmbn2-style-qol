; Shared by every BN2 Style Change patch (US AE2E / EU AM2P). Each feature lives in its own file and its own
; slice of free space, touching bytes no other feature touches, so the features also build (and
; their IPS patches stack) independently: battles.asm, elemchoice.asm, stylecap.asm, progress.asm.

; Addresses in these files are the US ones; the European ROM (AM2P) has the same code shifted by
; one of these offsets (found with tools/sigport.py), and the same RAM and text archives.
.if REGION == "us"
OFS_BOOT        equ 0
OFS_LOW         equ 0           ; 0x08004E14 .. 0x080247A0
OFS_MENU        equ 0           ; 0x08025634 .. 0x0802C4A9
FREE_SPACE      equ 0x087F4B10  ; 0xB4F0 bytes of 0xFF
.elseif REGION == "eu"
OFS_BOOT        equ 0x4
OFS_LOW         equ 0xC
OFS_MENU        equ 0x144
FREE_SPACE      equ 0x087F9090  ; 0x6F70 bytes of 0xFF up to the end of the ROM
.else
.error "REGION must be us or eu"
.endif
ELEMCHOICE_SPACE equ FREE_SPACE
STYLECAP_SPACE  equ FREE_SPACE + 0x1000
PROGRESS_SPACE  equ FREE_SPACE + 0x1800
PROGRESS_END    equ FREE_SPACE + 0x1C00

ITEM_COUNT      equ (0x080247A0 + OFS_LOW)      ; (id) -> count, Z set if none
TEXT_START      equ (0x08020B88 + OFS_LOW)      ; (archive, script); clobbers r4 and r6
TEXT_STATUS     equ (0x08020F44 + OFS_LOW)      ; (mask) -> nonzero while a text box is open (mask 0x80)
FLAG_SET        equ (0x0801BF08 + OFS_LOW)      ; (0, flag)
FLAG_CLEAR      equ (0x0801BF24 + OFS_LOW)      ; (0, flag)
FLAG_TEST       equ (0x0801BF40 + OFS_LOW)      ; (0, flag) -> nonzero if set
PICK_TYPE       equ (0x080115F0 + OFS_LOW)      ; -> next Style Change type (5 = Hub); 0 = none left (stylecap.asm)
MENU_TEXT       equ 0x087D7BC8      ; vanilla MegaMan-menu text archive
