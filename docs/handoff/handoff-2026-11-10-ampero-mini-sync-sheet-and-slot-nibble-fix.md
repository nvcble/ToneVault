# Handoff - 2026-11-10 - Ampero Mini: name sync runs on hardware, slot-nibble fix built but not yet re-run

## 1. Snapshot

- Date: 2026-11-10. Branch: `feature/mg30-v5-protocol`, pushed.
- Last commit: `c111218 Add Ampero Mini name-read-built handoff`. Before it: `28d5fdc Bump version to 1.1.6+9`, `8906fd7 Ampero Mini: fix name sync sheet layout and slot decoding past slot 16`.
- Working tree was clean before this handoff was written; this file and `docs/handoff/LATEST.md` are the only uncommitted items.
- Goal: get "Read pedal names" (reads the 99 user-patch names from the Hotone Ampero Mini) working on the real pedal.

## 2. What the user asked

1. "Read docs/handoff/LATEST.md, check git status, then continue with next step 1. I try to run the Read pedal names but it did not do anything. It just blurred the screen" - **Done**: cause found and fixed (section 3).
2. `/version-update patch` - **Done**: `1.1.5+8` -> `1.1.6+9`.
3. Screenshot: sync read 16 names then "Stopped. Slot 17: reply did not decode to a name" - **Diagnosed and fixed in code**; the failure now keeps the reply.
4. Screenshot "Still has same displayed error" - **Explained**: my scripted edit of the sheet had silently not applied, and I had wrongly reported it done. Fixed with a direct edit.
5. Screenshot showing the raw reply for slot 17 - **Done**: decoder fixed (slot byte is a nibble pair).
6. `/ship` - **Done**: three commits (code+tests, version bump, handoff docs), pushed.
7. `/handoff` - this file.

## 3. What was done

Modified (hand-written):
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_name_sync_sheet.dart` - buttons wrapped in `Expanded` (blank-sheet fix); shows `Reply: <hex>` (SelectableText) under the red message when a read failed with a reply; "Done." only when no failure.
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_patch_reader.dart` - `AmperoMiniReadFailure` now has `raw` and `rawHex` (first 72 bytes); the "did not decode" failure passes the payload.
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_patch_name.dart` - slot is read as a nibble pair, body bytes 7 (high) and 8 (low), compared with `index`.
- `test/unit/ampero_mini_patch_name_test.dart` - helper writes the slot as a nibble pair; new test with the real slot-17 frame (decodes to "Beefy Dirt" for index 16, null for index 0).
- `pubspec.yaml` - version line only.

New:
- `test/widget/ampero_mini_name_sync_sheet_test.dart` - opens the overflow menu, taps "Read pedal names", expects the title and a Start button.
- `docs/handoff/handoff-2026-11-10-ampero-mini-name-read-built.md` (committed in `c111218`).

Generated files: none.

## 4. What was found

- **Verified (widget test reproduced it):** the blank/blurred sheet was a `FilledButton` in a bare `Row`. The app theme gives buttons an infinite minimum width ("BoxConstraints forces an infinite width"). Wrap such buttons in `Expanded`. The sheet is `isDismissible: false`, which is why it looked stuck.
- **Verified on hardware (user's phone, screenshots):** with the sheet fixed, the sync read slots 1-16 and stopped at slot 17. The grid showed WelcomeToAmpero, Sparkling OD, D.Lead Gain 1, D.Classic 90s LD, Heavy Rhythm, Pure Clean in P01-1..P02-3.
- **Verified (real frame from the pedal, slot 17 / index 16):** `21 25 7f 4d 50 2d 32 | 12 00 02 0e | 00 01 10 00 00 00 01 01 00 00 01 03 02 04 02 06 05 06 05 06 06 07 09 02 00 04 04 06 09 07 02 07 04 00 00 ... 01`. After the `0E`, body byte 7 = `01` and byte 8 = `00`, so the slot is 0x10 = 16: a high/low nibble pair, like the name characters. The old decoder read byte 8 alone. The name from body byte 13 is "Beefy Dirt" (hand-decoded and unit-tested; **not yet seen on the pedal's display**).
- **Unknown:** body byte 2 was `10` in this frame; whether it relates to the slot is unclear. It is not used.
- **Unknown:** behaviour on empty slots, names with characters outside printable ASCII, slots 33+ (high nibble 2..6), and factory bank 0.
- Earlier findings still stand (`08` -> `0C` ack; `0D` returns data for the last `08`; multi-chunk `0E` reply where only chunk 0 holds the name). See `docs/handoff/handoff-2026-11-10-ampero-mini-name-read-built.md`.
- No Android device was connected to this machine (`adb devices` empty); all hardware runs are done by the user.

## 5. Decisions and constraints

- Names come only from the pedal, never hand-typed (user rule, 2026-09-16).
- Never store a name from a reply whose slot differs from the one asked for.
- User bank (99 slots) only; factory deliberately not read.
- File-size rule: under ~250 lines, 300 absolute. Changed files are well under.
- The `Reply: <hex>` line was deliberately left in the sheet so any new failure is diagnosable from a screenshot.
- Commit trailer used: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` (the ship skill text says `Claude Opus 5`; I used the actual model).
- The version bump was committed separately from other work, per the ship skill.

## 6. State of verification

- Seen passing: `test/unit/ampero_mini_patch_name_test.dart` 7 passed (after the nibble fix); `test/widget/ampero_mini_name_sync_sheet_test.dart` passed; earlier, that unit file plus all of `test/widget` = 379 passed (before the nibble fix); `dart analyze lib/features/midi/hotone_ampero_mini` no issues.
- **The full `flutter test` was NOT re-run** after today's changes (last full run, previous session: 1685 passed, 1 skipped, 1 failed before the label fix).
- **The phone does not have the nibble fix.** The user's last run (19:21) was the build with the Reply line but before the decoder fix. Compare the APK mtime (`build/app/outputs/flutter-apk/app-debug.apk`) with `ampero_mini_patch_name.dart` before assuming it is installed.
- Process lesson: a scripted edit (`dart /tmp/fix*.dart` using `replaceFirst`) silently did nothing and I reported it done. After scripted edits, grep for the change.
- A stray `flutter_tester.exe` locked `build\native_assets\windows\sqlite3.dll` and blocked `flutter test`; killing it fixed that.

## 7. Open items and risks

1. Slots 17+ are untested on hardware; the sync may stop again (empty slot, odd characters, slots >= 33).
2. The patch-list screen still shows "Names cannot be read from this pedal" with a Details link, which is now wrong. Look under `lib/features/midi/hotone_ampero_mini/` (patch list screen and its banner).
3. `AmperoMiniPatchReader` timeout is 2 s per request; 99 slots means 198 requests one at a time; pedal display behaviour during a long sync is unchecked.
4. `lib/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart` (about 256 lines) is over the soft limit.
5. Stale memory notes (not edited): `ampero-mini-patch-read-blocker` (a read now works and is built) and `ampero-mini-next-hardware-session`. Update after a full sync succeeds.
6. Stale docs: `docs/ampero_mini_protocol_capture.md` (capture described as future work); `docs/ampero_mini_capture_1_findings.md` lacks the multi-chunk reply, space padding and nibble-pair slot byte.
7. `ampero_mini_read_probe_sheet.dart` still says "No acknowledgement like the editor's was seen" for 0D/0F, which reads like a failure.
8. Git warns LF->CRLF on touched files (pre-existing). This handoff is uncommitted: run `/ship` to keep it.
9. Still unchecked from before: favorites persistence across restart; the v27 migration on the real database.

## 8. Next steps

1. **(User, hardware)** Build and install a new APK (newer than the nibble fix), open overflow menu -> "Read pedal names" -> Start. Report the count; if it stops, screenshot the red message and the `Reply:` hex line. Check that slot 17 (P06-2) reads "Beefy Dirt" on the pedal. Blocker: user.
2. **(Alone, after 1)** Fix whatever stops it (empty slots, odd characters, high nibble >= 2, timeouts). Start from `ampero_mini_patch_name.dart` and `ampero_mini_patch_reader.dart`; add each real frame as a fixture in `test/unit/ampero_mini_patch_name_test.dart`.
3. **(Alone)** Remove or reword the "Names cannot be read from this pedal" banner once a full sync works (7.2).
4. **(Alone)** Run the full `flutter test` for a baseline (kill a stray `flutter_tester.exe` first if `sqlite3.dll` is locked).
5. **(Alone)** Document the verified protocol in `docs/ampero_mini_capture_1_findings.md` and `docs/ampero_mini_protocol_capture.md` (7.6).
6. **(Alone)** Update the stale memory notes (7.5) after step 1 succeeds.
7. **(User, hardware)** Try factory patches (bank 0) and an empty user slot; extend the reader if it works.
8. **(Alone, optional)** Decode more of the `0E` frame using `C:\Program Files\Hotone\Ampero Editor\Resource\Ampero\File\algorithm_50.xml` for labels; find what body byte 2 (`10`) means.
9. **(User, hardware)** Try the editor's Bank Select layout (`B0 3D 14`, `B0 00 <bank>`, `C0 <index>`) via the factory-patch sheet.
10. **(User)** Verify favorites on the phone: stars persist across restart, favorites-only filter works.
11. **(Alone)** Make the probe sheet say "reply received" for 0D/0F; split grid/filter code out of the patch list screen (7.4, 7.7).
12. **(Ask user)** Add favorites to backup export (`lib/core/database/daos/backup_dao.dart`, `lib/features/backup/data/backup_document.dart`, `lib/features/backup/data/backup_upgrades.dart`).

## 9. First move for the new session

1. Read this file; run `git status --short` and `git log --oneline -3`.
2. Compare the APK mtime with `ampero_mini_patch_name.dart`; ask the user what the "Read pedal names" run showed (step 1).
3. Run the full `flutter test` for a baseline.

Paste into the new session:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next step 1.
