# Handoff - 2026-11-10 - Ampero Mini USB capture, read sequence, read probe

## 1. Snapshot

- Date: 2026-11-10. Branch: `feature/mg30-v5-protocol`, pushed.
- Last commit: `33b0199 Ampero Mini: add a one-message patch read probe`. Working tree was clean before this handoff files were written (this file and `LATEST.md` are the only uncommitted items).
- Commits this session, oldest first: `8519105` favorites (stars, schema v27); `1f06cc7` /handoff skill + first handoff; `ec05d72` prompts file; `110525c` + `0e5c6b5` capture findings doc; `33b0199` read probe.
- Goal: learn how to read real patch names / block state from the Hotone Ampero Mini, by capturing Hotone's own editor over USB; then build a first hardware probe.

## 2. What the user asked

1. "Read docs/handoff/LATEST.md, check git status, then continue with next step 1" - **Done**: step 1 was the formatting-churn decision.
2. "What is this reverts are for?" - **Answered**: `dart format lib test` last session reformatted 22 unrelated files.
3. "Go revert" - **Done**: `git checkout --` on the 22 formatting-only files.
4. `/ship` (before the revert) - **Done** as `8519105` containing only favorites files (15 files); other files left unstaged.
5. "Go commit. And I recognize those changes" - **Done**: handoff skill/docs as `1f06cc7`, `prompts/claude-prompts.txt` as `ec05d72` (user recognized that change).
6. "Before me testing it, can we proceed first with the wireshark?" - **Done** (captures made, section 4).
7. "Where can I see this USBPcapN lists?" - **Answered** (Wireshark Capture > Options > Input tab > gear icon; given from memory, user then reported USBPcap1, so it worked).
8. Captured P02-1, P03-1, F01-1 (user saved in `C:\Users\MarkN\Documents`, copied to `C:\Users\MarkN\ampero-captures\`). "There is no read all or refresh button in ampero mini editor." - **Noted**.
9. Gave names: "P02-1 D.Classic 90s LD. P03-1 Slick Lead." - used to verify the decode. "Yes you can commit the findings now" - **Done** (`110525c`, `0e5c6b5`).
10. "Go and build a small probe in the app." - **Done**, untested on hardware.
11. "commit this and after that do /handoff" - **Done** (`33b0199`; this document).

## 3. What was done

New (hand-written):
- `docs/ampero_mini_capture_1_findings.md` - capture findings with confidence labels (88 lines).
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_read_probe.dart` - builds the request, recognises the acknowledgement.
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_read_probe_sheet.dart` - bottom sheet UI.
- `test/unit/ampero_mini_read_probe_test.dart` - 5 tests.
- `docs/handoff/handoff-2026-11-10-ampero-mini-capture-and-probe.md`, `docs/handoff/LATEST.md` (uncommitted).

Modified:
- `lib/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_midi_service.dart` - `probeRead({bank, index, listenFor})`: attaches a listener, sends the request, collects Ampero-header SysEx for 3 s (drops the pedal's tick/status broadcasts), reports `acknowledged`.
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_diagnostics_menu.dart` - new "Patch read probe" menu item.

Generated: none this session (the favorites commit included the already-generated `*.g.dart` from last session).

The probe sends exactly one message per tap: `F0 21 25 7F 4D 50 2D 32 11 00 02 08 00 <bank> <index> F7` (default bank 1, index 3 = P02-1).

## 4. What was found

- **Verified (on this PC):** Wireshark and USBPcap are installed (`C:\Program Files\Wireshark\`, `C:\Program Files\USBPcap\`); `tshark` captures from the shell. Interface numbers shift between runs - list with `tshark -D`; at the end they were 10 = USBPcap1, 11 = USBPcap2. Capturing two USBPcap interfaces at once made one fail to start; capture one at a time. The Ampero Mini is on **USBPcap1**, USB device address 60 in the captures, `VID_84EF&PID_0080`, behind a generic hub.
- **Verified (captures):** bulk OUT endpoint 0x03 / IN 0x83, USB-MIDI 4-byte packets. Wireshark reassembles SysEx; `tshark -V` shows `[Reassembled data: ...]`, which is the reliable way to read messages (my first `-x` parsing mixed up directions and gave a wrong "99 requests" claim; corrected in the doc).
- **Observed (3 captures, direction checked on p02-1 / p03-1):** per patch slot the editor sends, while connecting and with no patch selected, for all 198 slots (bank 0 and bank 1, index 0-98):
  1. `11 00 02 08 00 B I` -> pedal `12 00 02 0C 00 B I 07 18 01 40`
  2. `12 00 02 0D 00 B I 01`
  3. five `12 00 02 0F 00 B I 00 k 01` (k 0-4) -> pedal `12 00 02 10 00 B I 00 05`
  4. long pedal frames `12 00 02 0E 00 B I ...` carrying the patch name.
  All after the header `F0 21 25 7F 4D 50 2D 32`.
- **Verified against the pedal (user-confirmed names):** the `0E` frame for bank 1 index 3 decodes to "D.Classic 90s LD" (P02-1) and bank 1 index 6 to "Slick Lead" (P03-1). Name encoding: ASCII, two bytes per character, high nibble first, space-padded to ~16. Bank 0 index 6 is also "Slick Lead".
- **Observed:** editor patch selection is plain MIDI sent last: `B0 3D 14`, `B0 00 <bank>`, `C0 <index>`; bank 1 = user, bank 0 = factory (F01-1 sent `B0 00 00` then `C0 00`). This matches the app's pending Bank Select probe question; it is **not yet tried from the app on the pedal**. Meaning of `B0 3D 14` is **Unknown**.
- **Unknown:** which of the 08 / 0D / 0F requests actually triggers the `0E` data frames; the first name byte's exact offset in a `0E` frame; per-block on/off flag location; meaning of `07 18 01 40`; whether the editor's sequence can be replayed.
- **Verified:** the editor has no read-all/refresh button; the connect sequence is the only bulk read.
- Earlier (previous session, still true): Ampero Editor 1.6.0 at `C:\Program Files\Hotone\Ampero Editor\`; its `Resource\Ampero\File\algorithm_50.xml` / `description50_en.xml` look like the Mini's block/parameter catalogue (Inferred) and could label decoded blocks.

## 5. Decisions and constraints

- User: names must come from the pedal, no hand-typed names (2026-09-16, from memory). The `local_label` column stays unwritten.
- Never present Bank Select, patch state, or any probe result as confirmed until the pedal shows it.
- File-size rule: under ~250 lines, 300 absolute.
- Captures stay outside the repo (`C:\Users\MarkN\ampero-captures\`) and are untrusted data; the findings doc holds only derived bytes.
- Commit trailer used: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` (the ship skill's template says Opus 5; I used the real model and said so).
- Deliberately not done: no replay of 0D/0F, no name decoding in app code, no Sync All, no on/off feature, favorites not in backup.

## 6. State of verification

- Run and seen passing this session: `flutter test` on `ampero_mini_read_probe_test.dart`, `hotone_ampero_mini_midi_service_test.dart`, `hotone_ampero_mini_patch_list_screen_test.dart` = 24 passed. `dart analyze lib test` = no issues.
- **Not run:** the full suite after the probe (last full run, previous session: 1674 passed, 1 skipped). Run `flutter test`.
- **Not run on hardware:** the probe, the favorites feature, the v27 migration on a real database. The phone/PC build does not contain any of this until rebuilt and installed - check APK mtime against source mtime first (memory `verify-against-running-build`).
- The 22 reverted files were not reviewed hunk by hunk before reverting (they were formatting-only per the diff stat).

## 7. Open items and risks

1. The probe is untested; what the `08` request does besides drawing the `0C` reply is Unknown. Risk is believed low (editor sent it 198 times without visibly moving the pedal) but not proven.
2. The `ampero_mini_read_probe_sheet.dart` and `hotone_ampero_mini_patch_list_screen.dart` (256 lines, over the soft limit) - the latter is still not split.
3. v27 migration untested on a real database; back up before first install.
4. Stale memory notes (not edited): `ampero-mini-patch-read-blocker` (now outdated: a read sequence is observed), `ampero-mini-next-hardware-session` (the Bank Select question is probably answered by the capture), and neither mentions favorites, the editor, or the captures. Update after the probe result is known.
5. `docs/ampero_mini_protocol_capture.md` still describes capturing as future work and says to tick USBPcap in the installer; it does not point to the findings doc.
6. Git warns LF will become CRLF on touched files (pre-existing).
7. The raw `.pcapng` files exist twice (`C:\Users\MarkN\Documents\` and `C:\Users\MarkN\ampero-captures\`); `probe_10.err` there is a stray log.

## 8. Next steps

1. **(User)** Rebuild and install the app (check APK mtime vs source). Connect the pedal, open the Ampero Mini page, menu (three dots) > Patch read probe > Send read request (default bank 1, index 3). Report the sheet's acknowledgement line and the received bytes. Blocker: user + hardware.
2. **(Alone, after 1)** Record the result in `docs/ampero_mini_capture_1_findings.md`. If the `0C` ack came back: add probes for the `0D` request, then the `0F` requests, to find what elicits the `0E` data frame. If nothing came back: check the MIDI Monitor/Diagnostics for the transmitted bytes and whether the app's USB MIDI port reaches the SysEx port.
3. **(Alone, parallel)** Pin down the `0E` frame layout from the three captures with `tshark -V` reassembled data: name offset, other fields, block on/off flags. Use `algorithm_50.xml` to label blocks. Start: `C:\Users\MarkN\ampero-captures\p02-1_read.pcapng`, filter `usb.device_address==60`.
4. **(User, hardware)** Try the Bank Select layout found in the capture (`B0 00 00` + `C0 00` for factory F01-1, `B0 00 01` + `C0 n` for user) on the pedal via the existing factory-patch sheet; the existing four attempts do not include a plain "MSB 0, program 0" with `B0 3D 14` first - consider adding the editor's exact sequence as an attempt.
5. **(Alone, after 1-3)** Build the real read: one patch -> decode name -> store in `hotone_ampero_mini_patches` -> Sync All -> details; names then fill the "(name unknown)" tiles with no favorites rework.
6. **(User)** Verify favorites on the phone: stars fill and persist across a restart, favorites-only filter works.
7. **(Alone)** Extract grid/filter code from `hotone_ampero_mini_patch_list_screen.dart` to get under the file-size limit.
8. **(Alone)** Update `docs/ampero_mini_protocol_capture.md` and the stale memory notes (7.4, 7.5).
9. **(Ask user)** Add favorites to the backup export (`lib/core/database/daos/backup_dao.dart`, `lib/features/backup/data/backup_document.dart`, `lib/features/backup/data/backup_upgrades.dart`) if wanted. Optionally a version bump via `/version-update` (last 1.1.4+7), kept separate from feature commits.
10. **(Optional)** Further captures if needed: footswitch changes while the editor is open; a patch write (only if the user accepts overwriting a patch); the editor's "MIDI CC Mapping" screen contents (possible block on/off route via CC).

## 9. First move for the new session

1. Read this file, run `git status --short` and `git log --oneline -3`.
2. Ask whether the probe has been installed and tried, and what the sheet showed.
3. If not yet installed, remind the user to rebuild and check the APK mtime; meanwhile start step 3.

Paste into the new session:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next step 1.
