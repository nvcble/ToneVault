# Ampero Mini capture 1 - first reading (2026-11-10)

Source: `p02-1_read.pcapng` (USBPcap1, Ampero Editor 1.6.0 connecting, then one
patch selected; kept outside the repo in `C:\Users\MarkN\ampero-captures\`).
Pedal = USB device `VID_84EF&PID_0080`, bulk OUT endpoint 0x03, bulk IN 0x83,
USB-MIDI 4-byte packets. Everything below is **Observed in this one capture**
unless marked otherwise. Nothing here is hardware-verified from the app yet.

## Observed

- The editor sends SysEx with the known header `F0 21 25 7F 4D 50 2D 32`,
  then a command byte `11` or `12`, then `00 02 <op>`.
- Selecting a patch in the editor sent three plain MIDI messages, in this
  order: `B0 00 01`, `B0 3D 14`, `C0 03` (patch index 3 = P02-1).
  Not yet known which of the Bank Select / CC messages matters.
- On connect the editor sends a long run of requests, then the pedal answers.
  Counts of host-to-pedal requests, by op byte:
  - `12 00 02 0D 00 00 <n> 01 F7` - 198 of them, n counting up. 198 = the
    number of patch slots, so this looks like one request per patch.
  - `12 00 02 0F 00 00 00 00 <i> 01 F7` - 987 of them, i counting up.
  - `11 00 02 08 ...` - 198; `12 00 02 15 ...` - 5.
- The pedal answers with `12 00 02 0E ...` frames (549 seen), many bytes long,
  split over several USB packets.
- In the first `0E` reply, after 11 zero bytes, the data is **ASCII split into
  two 4-bit halves, high half first**: `05 07 06 05 06 0C ...` decodes to
  "WelcomeToAmpero". A later reply decodes to "-Zephyr Cleag". So **patch
  names are present in the pedal's replies.**

## Not yet known (do not build on these)

- Which request returns which patch, and where in the reply the slot number is.
- What op `0F` and `0D` each ask for, and what the `0E` frame layout is beyond
  the name.
- Where the per-block on/off flags are.
- Whether the editor's connect sequence can be replayed as-is.

## Next captures needed

One operation per file: read P03-1 (index 6) so the request differences show
where the slot number lives; the editor's read-all; selecting factory F01-1.

## Update after captures 2 and 3 (P03-1 and F01-1, same day)

Observed, one editor session each:

- **Correction to the correction:** the 198 requests are right. 99 per bank, two banks (0 = factory, 1 = user). See the read sequence below.
- **Patch selection from the editor** is plain MIDI, sent last in each capture:
  - P02-1 (index 3): `B0 3D 14`, `B0 00 01`, `C0 03`
  - P03-1 (index 6): `B0 3D 14`, `B0 00 01`, `C0 06`
  - F01-1: `B0 3D 14`, `B0 00 00`, `C0 06`, then `B0 00 00`, `C0 00`
  So Bank Select MSB (`B0 00 xx`) is **1 for user patches and 0 for factory**,
  followed by a Program Change with the index. This is the Bank Select layout
  the pending hardware probe was meant to find. The meaning of `B0 3D 14`
  (CC 61 = 20) is unknown. The F01-1 capture also contains a `C0 06` first,
  probably left over from the editor's previous selection (Inferred).
- Selecting a patch triggered **no further SysEx** after the Program Change in
  any capture. The patch data is fetched during the connect sequence.
- The editor has no read-all or refresh button, so the connect sequence is the
  only bulk read there is to capture.

## Read sequence, per patch (Observed in captures 1 and 2; direction checked)

Bytes after the header `F0 21 25 7F 4D 50 2D 32`. `B` = bank (0 factory, 1 user),
`I` = patch index 0-98 (0x00-0x62). The editor does this for **all 198 slots
(2 banks x 99) while connecting**, in order, with no patch selected:

1. HOST   `11 00 02 08 00 B I F7`          - 198 sent
2. PEDAL  `12 00 02 0C 00 B I 07 18 01 40 F7` - reply to 1
3. HOST   `12 00 02 0D 00 B I 01 F7`       - 198 sent
4. HOST   `12 00 02 0F 00 B I 00 k 01 F7`  - k = 0..4, five per patch (990)
5. PEDAL  `12 00 02 10 00 B I 00 05 F7`    - after the fifth `0F`
6. PEDAL  `12 00 02 0E 00 B I ...` - the long data frames; these carry the name.
   I have not yet worked out which request triggers them or how many there are
   per patch.

**Name check against the pedal (confirmed by the user):** the `0E` frame with
`B=1, I=3` decodes to "D.Classic 90s LD" (P02-1) and `B=1, I=6` decodes to
"Slick Lead" (P03-1). Both match what the editor shows. The same name also
appears at `B=0, I=6`, so factory slot 6 is the same patch.

Name encoding (Observed): ASCII, each character as two bytes, high 4 bits
first, e.g. `05 03` = 'S'. Names are space-padded to about 16 characters.
The exact offset of the first name byte inside the `0E` frame still needs
pinning down before it goes in code.

**Still unknown:** which of 1/3/4 is the actual "send me the patch" request,
the full `0E` layout, the block on/off flags, and what `07 18 01 40` means.
Replaying the sequence on the real pedal has **not** been tried.

## Hardware probe result (2026-11-10, app on phone, pedal on USB)

The app's Patch read probe, bank 1 index 3 (P02-1), one message per tap:

| Sent | Pedal answered | Verdict |
|---|---|---|
| `11 00 02 08 00 01 03` | `12 00 02 0C 00 01 03 07 18 01 40` | Verified: ack only, no name |
| `12 00 02 0D 00 01 03 01` | one `12 00 02 0E 00 01 03 00 00 ...` frame | Verified: **this request returns the patch data** |
| `12 00 02 0F 00 01 03 00 00 01` | one `0E` frame, sub-type `00 01` (not `00 00`), no name text | Verified it answers; contents not decoded |

The `0D` reply decodes to "D.Classic 90s LD", the name the user confirmed for
P02-1, using the nibble-pair encoding above. Counting from the `0E` byte, the
name's first pair is the 14th byte after it (13 bytes lie between), in this one
frame (Observed, one sample - confirm on a second slot before coding it). The
13 bytes are `00 01 03 00 00 00 01 00 03 00 00 06 03`; their meaning is
Unknown (`06 03` looks like a character pair but is not part of the name).

Nothing is known yet about other effects of `0D` on the pedal: the user saw
no visible change (not asked for `0D` specifically - ask). The probe sheet's
"No acknowledgement" line for `0D`/`0F` is expected: it only recognises the `0C`
ack of request `08`.

Screenshots cut the long frames at the bottom of the sheet, so the full
length of the `0D` reply is not recorded yet.

### Correction (same session): 0D does NOT yet read an arbitrary slot

`0D` for bank 1 index 6 (should be "Slick Lead", P03-1) came back with header
index 6 but a body byte-for-byte identical to the index-3 reply: still
"D.Classic 90s LD". So the statement above that `0D` "returns the patch data"
for the requested slot is **withdrawn**. Two explanations fit and are not
separated: (a) `0D` returns the patch currently loaded on the pedal and echoes
the requested index in its header; (b) it needs the editor's other requests
first (`08`, `0F`) to select the slot. Test: send `08` then `0D` for index 6,
and note which patch the pedal's display was on. No names may be stored from
`0D` until a second, different name is read correctly.

### Second 0D sample (same session): "Slick Lead"

`0D` for bank 1 index 6, sent after the correction above, returned a frame that
decodes to **"Slick Lead"** (P03-1, name confirmed by the user). The name starts
at the same place as in the first sample: byte 13 (0-based) after the `0E`
byte, so the layout after `0E` is `00 01 <idx> 00 00 00 01 00 <idx> 00 00
<2 unknown bytes> <name pairs...>`. The two unknown bytes were `06 03` for
P02-1 and `04 0E` for P03-1 (meaning Unknown). Name pairs are followed by
`00 00 ...` padding in this sample, not by space pairs `02 00`.

The pedal's own display read "P01-1 WelcomeToAmpero" at this point, so the
"0D returns the currently loaded patch" explanation is unlikely (it would have
returned that name). Whether the user sent `08` for index 6 before this `0D`
was not recorded - so "08 selects the slot that 0D reads" is **unconfirmed**.
Discriminating test: send `0D` for an index that has had no `08` (e.g. 9) and
see whose name comes back.
