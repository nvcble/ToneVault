// The MG-30's own model lists, read from QuickTone's per-device string table,
// joined to its per-model knob layouts.
const fs = require('fs');
const buf = fs.readFileSync(process.argv[2]);
const cstring = (s) => { let e = s; while (e < buf.length && buf[e] !== 0) e++; return buf.toString('utf8', s, e); };

const lang = {};
for (const m of cstring(8092000).matchAll(/"([A-Z0-9_]+)"="([^"]*)"/g)) if (m[2].trim()) lang[m[1]] = m[2];
const doc = JSON.parse(cstring(108857552));

const lists = {
  WAH: ['CLYDE', 'CRY BB', 'V847', 'HORSE WAH', 'OCTAVE-SHIFT'],
  CMP: ['ROSE COMP', 'K COMP', 'STUDIO COMP'],
  NR: ['NOISE GATE'],
  EFX: ['DISTORTION+', 'RC BOOST', 'AC BOOST', 'DIST ONE', 'T SCREAM', 'BLUES DRV', 'MORNING DRV', 'EAT DIST',
    'RED DIRT', 'CRUNCH', 'MUFF FUZZ', 'KATANA', 'ST SINGER', 'RED FUZZ', 'TOUCH WAH'],
  AMP: ['JAZZ CLEAN', 'DELXUE RVB', 'BASSMATE', 'TWEEDY', 'TWIN RVB', 'HIWIRE', 'CALI CRUNCH', 'CLASS A15',
    'CLASS A30', 'PLEXI 100', 'PLEXI 45', 'BRIT 800', '1987 X 50', 'SLO 100', 'FIREMAN HBE', 'DUAL RECT',
    'DIE VH4', 'VIBRO KING', 'BUDDA', 'MR.Z 38', 'SUPER RVB', 'BRIT BLUES', 'MATCH', 'BRIT 2000', 'UBER',
    'AGL', 'BASSGUY', 'MLD', 'OPTIMA AIR', 'STAGEMAN', 'DGLASS', 'STARLIFT', 'VIVO', 'F PRINCETON', 'L STAR'],
  IR: ['JZ120', 'DR112', 'BS410', 'A212', 'TR212', '1960', 'GB412', 'V412', 'SWAMP THANG', 'CANNABIS REX 12',
    'LEGEND 1058', 'CV-75', 'AGL DB810', 'AMP SV810', 'AMP SV410', 'AMP SV212', 'MKB 410', 'TRC 410',
    'EDEN 410', 'BASSGUY 410', 'M-D45', 'G-HBIRD', 'G-J15', 'USER', 'COLLECTION'],
  EQ: ['6-BAND EQ', 'ALIGN EQ', '10-BAND EQ', 'PARA EQ'],
  MOD: ['CE-1', 'CE-2', 'ST.CHORUS', 'VIBRATOR', 'DETUNE', 'FLANGER', 'PHASE 90', 'PHASE 100', 'S.C.F',
    'U-VIBE', 'TREMOLO', 'ROTARY SPEAKER', 'HARMONIST', 'SCH-1'],
  DLY: ['ANALOG DELAY', 'DIGITAL DELAY', 'MODULATION', 'TAPE ECHO', 'REVERSE', 'PAN DELAY', 'DUOTIME', 'PHI DELAY'],
  RVB: ['ROOM', 'HALL', 'PLATE', 'SPRING', 'SHIMMER', 'DAMP'],
  SR: ['SEND/RETURN'],
  VOL: ['PATCH LEVEL'],
};

const out = {};
let withKnobs = 0, total = 0;
for (const [block, names] of Object.entries(lists)) {
  out[block] = [];
  console.log(`\n=== ${block} (${names.length})`);
  names.forEach((name, i) => {
    total++;
    const entry = doc[`${i + 1}. ${name}`];
    const knobs = (entry?.array ?? []).filter((e) => e.languageKey)
      .sort((a, b) => a.midiCC - b.midiCC)
      .map((e) => ({ knob: e.midiCC, label: lang[e.languageKey] ?? e.languageKey, min: e.parameter1, max: e.parameter2 }));
    if (knobs.length) withKnobs++;
    out[block].push({ index: i + 1, name, knobs });
    console.log(`  ${String(i + 1).padStart(2)}. ${name.padEnd(16)} ${knobs.length ? knobs.map((k) => `${k.knob}:${k.label}`).join(' ') : '(no knob entry)'}`);
  });
}
fs.writeFileSync('mg30_parameters.json', JSON.stringify(out, null, 1));
console.log(`\n${withKnobs}/${total} models have a knob layout -> mg30_parameters.json`);
