"""Generate the mod's text archives (*.tpl -> *.msg via TextPet).

elem_choice: script N (N = 1..15) is the Style Change element menu for element mask N (bit e-1 set =
  element e can be picked). Picking element e jumps to script 16 + (e-1), which leaves e-1 in flags
  0x39 (bit 0) / 0x3A (bit 1); elemchoice.asm reads and clears them.

style_menu: the MegaMan-menu style switcher, one page at a time. Script 1 + (k-1)*2 + more shows k
  styles (names from text buffers 1..k, filled by stylecap.asm) followed by "More" (if more = 1) and
  "Cancel". The selected option index is read back by the code, like vanilla scripts 54-56.
"""
import os
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
TEXTPET = os.path.join(ROOT, 'tools', 'textpet')
ELEMENTS = ['Elec', 'Heat', 'Aqua', 'Wood']
FLAG_LO, FLAG_HI = 0x39, 0x3A


def grid(options, col2_pad):
    """2-column option grid. options: list of lists of TPL lines (the label of each option).
    col2_pad(label_lines) -> TPL lines that move to the second column after a first-column label."""
    n = len(options)
    rows = (n + 1) // 2
    at = {(i // 2, i % 2): i for i in range(n)}
    out = []
    for i, label in enumerate(options):
        r, c = divmod(i, 2)
        other = at.get((r, 1 - c), i)
        up = at.get((r - 1, c), at.get((r - 1, 0))) if r > 0 else at.get((rows - 1, c), at.get((rows - 1, 0)))
        down = at.get((r + 1, c), at.get((r + 1, 0))) if r < rows - 1 else at.get((0, c))
        out += ['\toption', f'\t\tleft = {other}', f'\t\tright = {other}',
                f'\t\tup = {up}', f'\t\tdown = {down}', '\tspace', '\t\tcount = 2']
        out += label
        if c == 0 and i + 1 < n:
            out += col2_pad(label)
        elif r < rows - 1:
            out.append('\t"\\n"')
    return out


def text(s):
    return [f'\t"{s}"']


# --- elem_choice -----------------------------------------------------------------------------
ELEM_INTRO = '''\
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\\n"'''


def elem_menu(mask):
    elems = [e for e in range(4) if mask >> e & 1]
    pad = lambda label: [f'\t"{" " * (7 - len(label[0].strip()[1:-1]))}"']
    out = [f'script {mask} mmbn2 {{', ELEM_INTRO]
    out += grid([text(ELEMENTS[e]) for e in elems], pad)
    out += ['\tselect', '\t\tdefault = 0', '\t\tdisableB = true', '\t\tclear = true', '\t\ttargets = [']
    out += [f'\t\t\tjump = {16 + e},' for e in elems]
    out += ['\t\t\tjump = continue', '\t\t]', '\tend', '}']
    return '\n'.join(out)


def elem_result(e):
    cmd = lambda f, on: f'\t{"flagSet" if on else "flagClear"}\n\t\tflag = {f}'
    return '\n'.join([f'script {16 + e} mmbn2 {{', cmd(FLAG_LO, e & 1), cmd(FLAG_HI, e & 2), '\tend', '}'])


def elem_archive():
    parts = ['@archive elem_choice', '@size 20', '', 'script 0 mmbn2 {', '\tend', '}']
    parts += [elem_menu(m) for m in range(1, 16)]
    parts += [elem_result(e) for e in range(4)]
    return parts


# --- style_menu ------------------------------------------------------------------------------
def style_page(k, more):
    options = [['\tprintItem', f'\t\tbuffer = {i + 1}', '\t\titem = 0'] for i in range(k)]
    if more:
        options.append(text('More'))
    options.append(text('Cancel'))
    pad = lambda label: ['\tspaceLeft', '\t\tcount = 11']        # same as vanilla scripts 54-56
    out = [f'script {1 + (k - 1) * 2 + more} mmbn2 {{', '\tmsgOpenQuick', '\tmugshotShow', '\t\tmugshot = MegaMan',
           '\ttextSpeed', '\t\tdelay = 0']
    if len(options) <= 4:                                          # room for vanilla's header line
        out.append('\t"Use which style?\\n"')
    out += grid(options, pad)
    out += ['\tselect', '\t\tdefault = 0', '\t\tdisableB = false', '\t\tclear = false', '\t\ttargets = [']
    out += ['\t\t\tjump = continue,'] * len(options)
    out += ['\t\t\tjump = continue', '\t\t]', '\twaitHold', '}']
    return '\n'.join(out)


def style_archive():
    parts = ['@archive style_menu', '@size 9', '', 'script 0 mmbn2 {', '\tend', '}']
    parts += [style_page(k, more) for k in range(1, 5) for more in (0, 1)]
    return parts


def build(name, parts):
    tpl = os.path.join(HERE, name + '.tpl')
    with open(tpl, 'w', encoding='utf-8') as f:
        f.write('\n'.join(parts) + '\n')
    msg = os.path.join(HERE, name + '.msg')
    if not os.path.exists(os.path.join(TEXTPET, 'TextPet.exe')) and os.path.exists(msg):
        print(f'{name}.msg: TextPet not found, keeping the prebuilt archive')
        return
    if os.path.exists(msg):
        os.remove(msg)
    r = subprocess.run([os.path.join(TEXTPET, 'TextPet.exe'), 'load-plugins', os.path.join(TEXTPET, 'plugins'),
                        'game', 'mmbn2', 'read-text-archives', tpl, '-f', 'tpl',
                        'write-text-archives', msg, '-f', 'bin', '--single'], capture_output=True, text=True)
    if r.returncode or not os.path.exists(msg):
        raise SystemExit('TextPet failed:\n' + r.stdout + r.stderr)
    print(f'{name}.msg: {os.path.getsize(msg)} bytes')


def main():
    build('elem_choice', elem_archive())
    build('style_menu', style_archive())


if __name__ == '__main__':
    main()
