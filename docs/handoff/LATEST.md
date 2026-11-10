# Handoff - 2026-11-10 - Ampero Mini: patch name read sequence verified on hardware

## 1. Snapshot

- Date: 2026-11-10. Branch: `feature/mg30-v5-protocol`, pushed.
- Last commit: `7efd864 Add Ampero Mini capture handoff and update saved prompts`. Working tree was clean before this handoff was written (this file and `LATEST.md` are the only uncommitted items).
- Commits this session: `6279a6c` probe 0D/0F steps; `128065c` retraction (0D returned the same patch for another slot); `a8fb54c` second sample "Slick Lead"; `40792b1` 08 selects / 0D returns (verified); `7efd864` previous handoff + prompts file.
- Goal: use the app's Patch read probe on the real Hotone Ampero Mini to find the request that returns patch names.

## 2. What the user asked

1. "Read docs/handoff/LATEST.md, check git status, then continue with next step 1" - **Done** (step 1 = run the probe; I checked APK mtime and asked).
2. "I've executed the Patch read probe. What will I do next?" - **Answered** (asked for the result screen).
3. Sent screenshots of the probe results - **Done**, each decoded (section 4).
4. "My fault Teams are loading" - they re-sent the right (index 9) screenshot after a duplicate one.
5. Answers to my questions: pedal display read "P01-1 WelcomeToAmpero"; "Yes I requested [08] since it is on your step"; "No it did not change pedal's display".
6. "Commit and push first then after that, do /handoff" - **Done** (`7efd864` pushed); handoff = this file.

## 3. What was done

Modified (hand-written):
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_read_probe.dart` - `AmperoMiniProbeStep` enum (request08/0D/0F with `label`); `buildAmperoMiniReadProbe` takes `step` (default 08, old behaviour unchanged).
- `lib/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_midi_service.dart` - `probeRead(..., step: ...)`.
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_read_probe_sheet.dart` - segmented selector "Request 08 / 0D / 0F".
- `test/unit/ampero_mini_read_probe_test.dart` - one test for the 0D and 0F bytes (6 tests in file).
- `docs/ampero_mini_capture_1_findings.md` - hardware results, a retraction, and the verified sequence (159 lines).
- `docs/handoff/*`, `prompts/claude-prompts.txt` - committed in `7efd864`.

Generated files: none.

Bytes sent by the new steps (header `21 25 7F 4D 50 2D 32` first): 0D = `12 00 02 0D 00 <bank> <index> 01`; 0F = `12 00 02 0F 00 <bank> <index> 00 00 01` (only k=0 of the editor's five 0F messages).

## 4. What was found

All on the user's phone + pedal, bank 1, one message per tap:

- **Verified:** `08` (`11 00 02 08 00 B I`) draws only the ack `12 00 02 0C 00 B I 07 18 01 40`. Repeatable (twice).
- **Verified:** `0D` returns one `12 00 02 0E ...` frame containing the patch name. `0D` returns the slot chosen by the **last 08**, not the slot in its own request. Evidence (header slot / body slot / name): 06/03 "D.Classic 90s LD" (08 had been sent for 3); 06/06 "Slick Lead" (08 sent for 6); 09/06 "Slick Lead" (no 08 for 9).
- **Verified (names):** both names match what the user said the editor shows (P02-1 = index 3, P03-1 = index 6).
- **Observed (two samples):** `0E` body after the `0E` byte: `00 01 <echo> 00 00 00 01 00 <real slot> 00 00 <2 unknown bytes> <name pairs>`. The real slot is at byte 8, name pairs start at byte 13 (0-based). Unknown 2 bytes: `06 03` (P02-1), `04 0E` (P03-1). Name padding: `00` in the Slick Lead sample.
- **Verified (user):** the pedal display did not change during any of these reads (stayed on P01-1 WelcomeToAmpero). That also makes "0D returns the currently loaded patch" unlikely.
- **Observed, not decoded:** `0F` (k=0) returns a `0E` frame with sub-type `00 01` and no name text (may be block data).
- **Withdrawn mid-session:** I first said 0D "returns the patch data" after one sample; the second sample (index 6) returned the same name. Corrected in the doc (`128065c`) before the final test.
- **Unknown:** where a name ends; behaviour on empty/odd slots; factory bank (0) reads via 08+0D; full length of the `0D` reply (screenshots cut it); meaning of `07 18 01 40` and `B0 3D 14`.
- PC/tool facts from the previous session still hold (Wireshark/USBPcap, captures in `C:\Users\MarkN\ampero-captures\`); see `docs/handoff/handoff-2026-11-10-ampero-mini-capture-and-probe.md`.

## 5. Decisions and constraints

- Names must come from the pedal, no hand-typed names (user rule, 2026-09-16, from memory). `local_label` stays unwritten.
- Never present a probe result as confirmed until the pedal/editor agrees; do not store a name from a reply whose body slot differs from the slot asked for.
- File-size rule: under ~250 lines, 300 absolute.
- Commit trailer used: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Deliberately not done: the real read/sync was not built. I asked "Should I build it?"; the user asked for commit, push and handoff instead, so it is **not approved yet**. No replay of the full editor sequence, no 0F k=1-4, no factory-bank reads.

## 6. State of verification

- Seen passing: `dart analyze lib/features/midi/hotone_ampero_mini test/unit/ampero_mini_read_probe_test.dart` = no issues; `flutter test test/unit/ampero_mini_read_probe_test.dart` = 6 passed.
- **Not run:** the full `flutter test` suite (last full run, earlier session: 1674 passed, 1 skipped).
- Hardware: the installed phone build contains the 08/0D/0F selector (seen in screenshots). Favorites stars showed filled on P01-1/P01-2 in one screenshot; persistence across restart not checked. The v27 migration on the real database is unverified.
- The sheet says "No acknowledgement like the editor's was seen" for 0D/0F. That is expected (it only recognises the 08 ack) but reads like a failure.

## 7. Open items and risks

1. The 08+0D sequence is proven for slots 3 and 6 of bank 1 only. Empty slots, bank 0 and index 98 are untested.
2. The name-end rule is unknown. Check more names (long, trailing spaces) before coding it.
3. `lib/features/midi/hotone_ampero_mini/widgets/hotone_ampero_mini_patch_list_screen.dart` (about 256 lines) is still over the soft limit.
4. Stale memory notes (not edited): `ampero-mini-patch-read-blocker` (now wrong: a read works), `ampero-mini-next-hardware-session` (Bank Select question partly answered by the captures, still not tried from the app). Update after the real read exists.
5. `docs/ampero_mini_protocol_capture.md` still describes capturing as future work.
6. `docs/ampero_mini_capture_1_findings.md` is chronological with no top summary; add a short "verified protocol" section when building the real read.
7. Git warns LF->CRLF on touched files (pre-existing).
8. This handoff is uncommitted: run `/ship` to keep it.

## 8. Next steps

1. **(Alone, needs the user's go-ahead)** Build the real read: per slot send `08`, wait for the `0C` ack with the same bank/index, send `0D`, require body slot (byte 8 after `0E`) == requested slot, decode name pairs from byte 13, store via `lib/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_patch_repository.dart` into `hotone_ampero_mini_patches`, stop on the first timeout or mismatch. Start from `probeRead` in `hotone_ampero_mini_midi_service.dart`. Write the decoder as a pure function with unit tests on real frames (get them in step 2). Blocker: user approval to write names into their database.
2. **(Alone, before 1)** Pull the full `0D` frames from the capture (`tshark -V`, `[Reassembled data]`, file `C:\Users\MarkN\ampero-captures\p02-1_read.pcapng`, filter `usb.device_address==60`) to learn frame length, where the name ends, and what empty slots look like. Also gives test fixtures.
3. **(User, hardware)** Run 08 then 0D for an empty slot or one with a long name, and for bank 0 (factory); scroll the sheet to the bottom if the frame is cut; send screenshots.
4. **(Alone)** Make the probe sheet say "reply received" instead of "No acknowledgement" for the 0D/0F steps.
5. **(Alone, optional)** Decode more of the `0E` frame (block on/off, `0F` k=0-4) using `C:\Program Files\Hotone\Ampero Editor\Resource\Ampero\File\algorithm_50.xml` for labels.
6. **(User, hardware)** Try the editor's Bank Select layout on the pedal (`B0 3D 14`, `B0 00 <bank>`, `C0 <index>`) via the factory-patch sheet.
7. **(User)** Verify favorites on the phone: stars persist across restart, favorites-only filter works.
8. **(Alone)** Split grid/filter code out of `hotone_ampero_mini_patch_list_screen.dart` to get under the size limit.
9. **(Alone)** Update `docs/ampero_mini_protocol_capture.md` and the stale memory notes (7.4).
10. **(Ask user)** Add favorites to backup export (`lib/core/database/daos/backup_dao.dart`, `lib/features/backup/data/backup_document.dart`, `lib/features/backup/data/backup_upgrades.dart`); optional `/version-update` (last 1.1.4+7), kept separate from feature commits.
11. **(Alone)** Run the full `flutter test` for a baseline.

## 9. First move for the new session

1. Read this file; run `git status --short` and `git log --oneline -3`.
2. Ask the user whether to build the real read (step 1); meanwhile start step 2 (pull full frames from the capture).
3. Run the full `flutter test` to get a baseline.

Paste into the new session:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next step 1.
