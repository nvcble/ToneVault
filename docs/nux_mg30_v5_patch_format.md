# NUX MG-30 V5 patch format, as QuickTone exports it

Established by reading one `MG30AllPatch.mg30patch` (1,267,456 bytes) exported by
QuickTone 2.4.12.27 from a physical MG-30 on firmware V5.0.2, 2026-10-06. No
hardware command was involved, so everything here describes the **file**; what it
implies about the SysEx frame is marked as such.

Reproduce with `node tools/quicktone/inspect_all_patch.js <file>`.

## File envelope — VERIFIED

```
1,267,456 = 128 x 9,902      no file header, no footer, no checksum seen
```

| Offset in record | Size | Field | Evidence |
|---|---|---|---|
| 0 | 1 | Slot index 0-127 | equals the record index in all 128 records |
| 1-3 | 3 | Zero | all 128 records |
| 4 | 142 | Scene 1 | see below |
| 146 | 142 | Scene 2 | |
| 288 | 142 | Scene 3 | |
| 430 | 1 | User-IR present (0/1) | 1 in exactly the 17 records carrying a blob |
| 431-433 | 3 | Zero | |
| 434 | 32 | IR name, ASCII NUL-padded | e.g. `CHPBOGIE212` |
| 466 | ~8.2 KB | RIFF/WAVE, 48 kHz mono PCM | `RIFF....WAVEfmt ` with rate 0xBB80 |
| … | | Zero padding to 9,902 | |

So **a patch is three complete 142-byte scene snapshots**, not one configuration
plus three bypass masks. That is what makes V5 Pro Scene able to hold a different
model per scene, and it is the structural fact the editor has to be built around.

## Scene block (142 bytes) — partly verified

| Offset | Size | Field | Status |
|---|---|---|---|
| 3 | 1 | AMP model code (0 = bypass, 1-35 = catalog order) | **VERIFIED** |
| 94-105 | 12 | Signal chain order: a permutation of block indices 0-11 | **VERIFIED** |
| 106-121 | 16 | Patch name, ASCII NUL-padded | **VERIFIED** |
| 0-93 | 94 | Per-block enable, model code and parameter values | INFERRED |
| 122-141 | 20 | Tail; ends in three identical 16-bit LE values | UNKNOWN |

AMP model was confirmed semantically against all 128 patch names: `CT-RectoBeast`
= 16 (DUAL RECT), `CT-DriveJCM` = 12 (BRIT 800), `CT-PlexiLead` = 10 (PLEXI 100),
`PeteT Raw BE` = 15 (FIREMAN HBE), `LT BLUES DELUXE` = 2 (DELXUE RVB),
`LT UBER CHUNK` = 25 (UBER). Chain order is a valid 12-block permutation in
128/128 records and varies between patches, so routing is readable per patch.

Parameter values in bytes 0-93 sit in 0-100, matching the ranges
`MG30_DisplayConfig.json` gives every knob.

## What this implies about the SysEx frame — INFERRED, offline-testable

A preset reply is 222 bytes on V5 and 218 on firmware v4.0.3. SysEx data bytes
must stay under 0x80, so 8-bit patch data has to be packed - and the patch name
is already known to be stored as alternating plain and encoded characters, three
frame bytes per two data bytes. Applying that to a scene block:

```
v4.0.3   140-byte scene -> 70 pairs x 3 = 210  + 8 framing = 218   exact
V5       142-byte scene -> 71 pairs x 3 = 213  + 8 framing = 221   observed 222
name     data offset 106 -> frame 7 + 159 = 166                    decoder uses 167
```

Three independent numbers line up, so the working hypothesis is: **the `0x0B`
read returns exactly one scene**, not a whole patch, with one byte unaccounted
for (checksum or flag) on V5. If that holds, reading a full patch needs three
reads with a scene change between them, or a different command.

Testing it needs no hardware: decode a stored 222-byte capture with that codec
and compare it byte-for-byte against this file's scene block for the same slot.

## Still unknown

Per-block field map inside bytes 0-93 · the 20-byte scene tail · whether the
extra V5 frame byte is a checksum · the write/save command · how a scene is
selected for reading · whether the export's byte order matches the SysEx payload
exactly.

## Not yet demonstrated: per-scene independence

All 128 patches in this export have three byte-identical scene blocks, so the
file proves the *capacity* for per-scene models but not the behaviour. A patch
with deliberately different scenes (see the golden-patch plan) and a second
export settle it, and the diff will name the scene-specific bytes directly.
