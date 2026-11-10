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

- **Correction:** the `12 00 02 0D 00 00 <n> 01` requests number **99** per
  session, not 198 (the earlier count included both USB directions). 99 = the
  user patches P01-1..P33-3, so `<n>` is plausibly the patch index 0-98, but
  the values I looked at (04, 0D, 0E, 14, 15, 16, 1F ...) are not yet checked
  against a known slot. **Inferred, not confirmed.**
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
