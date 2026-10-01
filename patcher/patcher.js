// BN2 Style Change QoL patcher: detects the ROM, stacks the chosen IPS patches from patches/,
// and writes the battle count. Runs in the browser (index.html) and in Node (for testing).
(function (root) {
  'use strict';

  const ROMS = {
    0x6D961F82: { region: 'us', name: 'Mega Man Battle Network 2 (USA)', countOffset: 0x4E24 },
    0x66341F3B: { region: 'eu', name: 'Mega Man Battle Network 2 (Europe)', countOffset: 0x4E30 },
  };
  // Patch file stems, applied in this order (they touch disjoint bytes, so any order works).
  const FEATURES = ['100battles', 'pickelement', 'keepstyles', 'battlesleft'];
  const COUNT_MIN = 1, COUNT_MAX = 255;   // the count is the 8-bit immediate of "movs r1, #count"

  let crcTable = null;
  function crc32(data) {
    if (!crcTable) {
      crcTable = new Uint32Array(256);
      for (let n = 0; n < 256; n++) {
        let c = n;
        for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
        crcTable[n] = c;
      }
    }
    let crc = 0xFFFFFFFF;
    for (let i = 0; i < data.length; i++) crc = crcTable[(crc ^ data[i]) & 0xFF] ^ (crc >>> 8);
    return (crc ^ 0xFFFFFFFF) >>> 0;
  }

  function identify(rom) {
    const crc = crc32(rom);
    return { crc, info: ROMS[crc] || null };
  }

  function applyIps(rom, ips) {
    const magic = String.fromCharCode(...ips.subarray(0, 5));
    if (magic !== 'PATCH') throw new Error('Not an IPS patch');
    let i = 5;
    for (;;) {
      if (i + 3 > ips.length) throw new Error('Truncated IPS patch');
      const off = (ips[i] << 16) | (ips[i + 1] << 8) | ips[i + 2];
      if (off === 0x454F46 && i + 3 === ips.length) break;    // "EOF"
      const size = (ips[i + 3] << 8) | ips[i + 4];
      i += 5;
      if (size === 0) {
        const run = (ips[i] << 8) | ips[i + 1];
        rom.fill(ips[i + 2], off, off + run);
        i += 3;
      } else {
        rom.set(ips.subarray(i, i + size), off);
        i += size;
      }
    }
  }

  // rom: Uint8Array of a clean ROM. opts: { features: [...stems], count }.
  // loadPatch(stem, region) -> Promise<Uint8Array> of patches/bn2_<stem>_<region>.ips
  async function build(rom, opts, loadPatch) {
    const { crc, info } = identify(rom);
    if (!info) throw new Error('Unknown ROM (CRC32 ' + crc.toString(16).toUpperCase().padStart(8, '0') + ')');
    const features = FEATURES.filter(f => opts.features.includes(f));
    if (!features.length) throw new Error('No changes selected');
    const out = new Uint8Array(rom);
    for (const f of features) applyIps(out, await loadPatch(f, info.region));
    if (features.includes('100battles')) {
      const n = Number(opts.count);
      if (!Number.isInteger(n) || n < COUNT_MIN || n > COUNT_MAX) throw new Error('Battle count must be ' + COUNT_MIN + '-' + COUNT_MAX);
      out[info.countOffset] = n;
    }
    return { data: out, info, crc: crc32(out) };
  }

  const api = { ROMS, FEATURES, COUNT_MIN, COUNT_MAX, crc32, identify, applyIps, build };
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.StyleQoL = api;
})(this);
