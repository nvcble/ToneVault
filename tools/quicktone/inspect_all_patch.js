const fs = require('fs');
const b = fs.readFileSync(process.argv[2]);
const SIZE = 9902, HEAD = 4, SCENE = 142, NAME = 106, CHAIN = 94;
const scene = (r, s) => b.subarray(r * SIZE + HEAD + s * SCENE, r * SIZE + HEAD + (s + 1) * SCENE);
const name = (buf) => {
  let out = '';
  for (let i = NAME; i < NAME + 16 && buf[i] !== 0; i++) out += String.fromCharCode(buf[i]);
  return out;
};

let differing = 0, chainOk = 0;
const rows = [];
for (let r = 0; r < 128; r++) {
  const s = [0, 1, 2].map((i) => scene(r, i));
  const diffs = [[], []];
  for (let i = 0; i < SCENE; i++) {
    if (s[1][i] !== s[0][i]) diffs[0].push(i);
    if (s[2][i] !== s[0][i]) diffs[1].push(i);
  }
  const d = diffs[0].length + diffs[1].length;
  if (d) differing++;
  const chain = [...s[0].subarray(CHAIN, CHAIN + 12)];
  if (new Set(chain).size === 12 && chain.every((v) => v < 12)) chainOk++;
  rows.push({ r, slot: b[r * SIZE], name: name(s[0]), d, chain: chain.join(',') });
}
console.log(`patches whose scenes are not all identical: ${differing}/128`);
console.log(`records whose bytes 94..105 are a permutation of 0..11: ${chainOk}/128`);
console.log(`slot byte equals record index for all: ${rows.every((x) => x.slot === x.r)}`);
console.log('\nfirst 12 patches:');
for (const x of rows.slice(0, 12)) console.log(`  ${String(x.r).padStart(3)} "${x.name}"  scene-diff bytes: ${x.d}  chain: ${x.chain}`);
console.log('\npatches with scene differences:');
for (const x of rows.filter((x) => x.d)) console.log(`  ${String(x.r).padStart(3)} "${x.name}"  ${x.d} bytes differ`);
