"""Inspect / tweak BN2 (US GBA) .sav files for testing. Never point --out at a real save.

  python savetool.py in.sav                       # show style state
  python savetool.py in.sav --battles 99 --out test.sav
  python savetool.py in.sav --give 0x0C=1 --give 0x16=2 --out test.sav   # style index=level
"""
import argparse
import struct

SAVE_LEN = 0x3A78          # checksummed area (MMBNSaveEditor BN2Definitions.saveAreaLengthGBA)
CHECKSUM = 0x114C
CHECKSUM_OFFSET = 0x16     # BN2 GBA
ACTIVE_STYLE, BATTLES, STYLES, NEXT_ELEM, POINTS = 0xDC1, 0xDE4, 0xF00, 0x112B, 0x3A68

TYPES = {1: 'Guts', 2: 'Cust', 3: 'Team', 4: 'Shld'}
ELEMS = {0: '', 1: 'Elec', 2: 'Heat', 3: 'Aqua', 4: 'Wood'}


def style_name(index):
    if index == 0:
        return 'Normal'
    if index == 0x19:
        return 'HubStyle'
    return ELEMS[index % 5] + TYPES[index // 5]


def checksum(s):
    total = sum(s[:SAVE_LEN]) - sum(s[CHECKSUM:CHECKSUM + 4])
    return (total + CHECKSUM_OFFSET) & 0xFFFFFFFF


def show(s):
    stored = struct.unpack_from('<I', s, CHECKSUM)[0]
    print(f'checksum stored {stored:#x} calculated {checksum(s):#x}', 'OK' if stored == checksum(s) else 'MISMATCH')
    a = s[ACTIVE_STYLE]
    print(f'active: {style_name((a >> 3 & 7) * 5 + (a & 7))} V{(a >> 6) + 1}')
    print('owned:', ', '.join(f'{style_name(i)} V{s[STYLES + i]} [{i:#x}]' for i in range(1, 0x1A) if s[STYLES + i]))
    print('battles since change:', struct.unpack_from('<I', s, BATTLES)[0])
    print('points Guts/Cust/Team/Shld:', struct.unpack_from('<4I', s, POINTS))
    print('next element:', ELEMS.get(s[NEXT_ELEM], s[NEXT_ELEM]))


def main():
    p = argparse.ArgumentParser()
    p.add_argument('save')
    p.add_argument('--battles', type=int)
    p.add_argument('--give', action='append', default=[], help='styleIndex=level (hex index ok)')
    p.add_argument('--out')
    a = p.parse_args()

    s = bytearray(open(a.save, 'rb').read())
    if a.battles is not None:
        struct.pack_into('<I', s, BATTLES, a.battles)
    for g in a.give:
        idx, lvl = g.split('=')
        s[STYLES + int(idx, 0)] = int(lvl, 0)
    if a.out:
        struct.pack_into('<I', s, CHECKSUM, checksum(s))
        open(a.out, 'wb').write(s)
        print('wrote', a.out)
    show(s)


if __name__ == '__main__':
    main()
