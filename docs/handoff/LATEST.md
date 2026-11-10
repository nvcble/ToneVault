# Handoff - 2026-11-10 - Ampero Mini: factory-name read built, editor Bank Select layout added, both untested on the pedal

## 1. Snapshot

- Date: 2026-11-10. Branch: `feature/mg30-v5-protocol`.
- Last commit: `0128ceb Docs: record the verified Ampero Mini name-read protocol`. Before it: `1f21351` (handoff), `faeaee9` (names notice reworded).
- **Working tree is NOT clean - 10 files uncommitted** (section 3). `docs/handoff/LATEST.md` is also rewritten by this handoff.
- Goal: finish Ampero Mini patch reading (names for user AND factory patches), then block ON/OFF and factory-patch selection from the phone.

## 2. What the user asked

1. "Read LATEST.md, check git status, continue with next step 1" - **Done/answered**: step 1 was a hardware run. The user then reported: "I test it now and successfully fetched all the patch names" (99 user names; Verified by user report).
2. "What's next where we left off?" - **Done**: full test baseline, banner reworded, memory notes updated.
3. `/ship` - **Done** (`faeaee9`, `1f21351`, pushed).
4. "go" - **Done**: protocol docs updated (`0128ceb`, pushed).
5. "Go first the step 11. But I think there's an issue in skill /handoff, does the latest document also includes that one of the tasks is to develop a feature that I can turned ON and OFF those pedals ... Also in Read Patch Names, it only reads the user patches and did not read the factory patches." - **Done**: probe-sheet wording; the handoff skill now carries open requirements forward; both requirements added to LATEST.md.
6. "Go proceed" - **Built, unverified on hardware**: factory-name read (section 3).
7. Screenshot: "All factory patches has slashes on it. And when I tried to tap it, it shows this dialog." - **Answered, partly built**: slashes mean "not selectable over MIDI" (by design); the dialog lacked the editor's layout, so two attempts were added.
8. `/handoff` - this file.

### Carried-over requirements (still open)

- **Block ON/OFF in the mobile app** (first in `docs/handoff/handoff-2026-11-10-ampero-mini-favorites.md`): turn the effect blocks ("pedals") inside a patch ON/OFF from the phone, like the Hotone Ampero Editor. Blocked on protocol: the on/off flag location in the `0E` frame is Unknown; the editor's "MIDI CC Mapping" screen is a possible CC route. Not started.
- **Factory patch names**: code written, not yet seen working (sections 3, 6).
- **Select factory patches from the phone** (implied by the user's screenshot): blocked until a Bank Select layout is confirmed on the pedal.
- **Favorites in backup export** and **favorites persistence check**: steps 10-11.

## 3. What was done

Uncommitted, all `modified`:
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_patch_reader.dart` - `readName(patchNumber)`: 0-98 is bank 1 (user), 99-197 is bank 0 (factory, slot = number - 99). New `factoryBank = 0`, documented UNVERIFIED. Failures report the absolute patch number.
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_patch_sync.dart` - renamed `syncAmperoMiniUserPatchNames` to `syncAmperoMiniPatchNames`; new `count` (default 198); stops at the first failure and keeps what was saved.
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_name_sync_sheet.dart` - total 198; text says factory reading is new and untested.
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_bank_select_probe.dart` - two new attempts first: the editor's exact sequence `CC61=20, CC0=0, PC 0` (new `editorPreface` flag) and `CC0=0, PC 0`. Six attempts now.
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_bank_select_sheet.dart` - body wrapped in `SingleChildScrollView` (six attempts overflowed a test screen).
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_read_probe_sheet.dart` - headline now "The pedal sent no reply." or "The pedal replied (not the 08 acknowledgement; see below)." (old step 11).
- `test/unit/ampero_mini_patch_name_test.dart` - new test: patch 105 sends `11 00 02 08 00 00 06`.
- `test/unit/ampero_mini_bank_select_probe_test.dart` - counts 4 to 6 and 3 to 5, preface check.
- `.claude/skills/handoff/SKILL.md` - new "Carry forward open requirements" paragraph (the on/off requirement was lost because only the session's own requests were listed).
- `docs/handoff/LATEST.md` - replaced by this handoff.

Committed earlier this session: banner and Details reworded (`faeaee9`); handoff docs (`1f21351`); `docs/ampero_mini_capture_1_findings.md` and `docs/ampero_mini_protocol_capture.md` updated (`0128ceb`). Memory notes `ampero-mini-patch-read-blocker` and `ampero-mini-next-hardware-session` were rewritten (outside the repo).

Generated files: none.

## 4. What was found

- **Verified (user report):** "Read pedal names" read all 99 user names on the phone. The names were not checked one by one.
- **Verified (screenshot, 19:49):** factory tiles are struck through and F01-1 shows no name; tapping opens the Bank Select dialog.
- **Observed (capture 3, `docs/ampero_mini_capture_1_findings.md`):** the editor selects F01-1 with `B0 3D 14`, `B0 00 00`, `C0 00` (CC61=20, CC0=0, PC 0). The old probe's bank-0 attempt used `PC 99`, which does not match. The new attempts mirror the editor. **Unverified in the app.**
- **Observed (capture 2):** the same name appeared at bank 0 slot 6 and bank 1 slot 6, so factory names may duplicate user names or differ; unknown until read.
- **Unknown:** whether the pedal answers `08`/`0D` for bank 0; behaviour on empty slots; the meaning of CC61=20; the on/off flag location.
- Python is not installed on this machine; use `dart` scripts. After a scripted edit, grep or diff to confirm it applied.

## 5. Decisions and constraints

- Names come only from the pedal, never hand-typed (user rule, 2026-09-16).
- Never store a name from a reply whose slot differs from the one asked for.
- The user wants factory names read; the earlier "user bank only" note was a stopgap, not a user decision.
- No protocol behaviour may be presented as working until the pedal confirms it; the Bank Select sheet says "nothing here can tell whether it worked".
- File-size rule: under ~250 lines, 300 absolute. `hotone_ampero_mini_patch_list_screen.dart` (~256 lines) is pre-existing over the soft limit.
- Commit trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## 6. State of verification

- Seen passing after the last code change: `flutter test test/widget test/unit/ampero_mini_bank_select_probe_test.dart` = 378 passed; `dart analyze lib test` no issues. Earlier, before the Bank Select changes: `ampero_mini_patch_name_test.dart` + `test/widget` = 381 passed.
- Full `flutter test` baseline earlier this session: 1688 passed, 1 skipped, 0 failed - **before** the factory-read and Bank Select changes. Not re-run since.
- **Build vs source:** `build/app/outputs/flutter-apk/app-debug.apk` mtime 19:47:54; `ampero_mini_patch_reader.dart` 19:44:39 (APK likely includes the factory read); `ampero_mini_bank_select_probe.dart` 19:51:33 (**APK does NOT have the editor-layout attempts**). Whether the phone has the 19:47 APK is unknown. The 19:49 screenshot shows F01-1 with no name, so the name sync was probably not re-run, or stopped at slot 100.

## 7. Open items and risks

1. The factory read has never run on the pedal; it may stop at slot 100.
2. The banner "Names are read from the pedal for user patches only" (`lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_read_limitation_notice.dart`, its Details text, and `test/widget/hotone_ampero_mini_patch_list_screen_test.dart`) becomes wrong if the factory read works.
3. Name sync is 396 sequential requests at up to 2 s timeout each; pedal display behaviour during a long run is unchecked.
4. `lib/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart` is over the soft size limit.
5. No test covers the probe sheet's new wording.
6. `docs/ampero_mini_capture_1_findings.md` does not yet mention the factory read attempt; update after the hardware result.
7. Stale memory note: `ampero-mini-next-hardware-session` does not list the editor-layout Bank Select attempts. Not edited; refresh after the hardware run.
8. Still unchecked: favorites persistence across restart; the v27 migration on the real database. Git warns LF->CRLF (pre-existing).

## 8. Next steps

1. **(Alone)** Run the full `flutter test` for a new baseline (kill a stray `flutter_tester.exe` if `sqlite3.dll` is locked), then `/ship` the uncommitted work (code + tests in one commit, handoff docs in another).
2. **(User, hardware)** Build and install a fresh APK (must be newer than 19:51:33). Overflow menu -> "Read pedal names" -> Start; expect "of 198". If it stops, send the red message and the `Reply:` hex. Compare a few factory names with the pedal's display.
3. **(User, hardware)** Double-tap F01-1, press Send on the first attempt (`CC61=20, CC0=0, PC 0`), then the second; say whether the display moved to F01-1.
4. **(Alone, after 3)** If an attempt works: put it in `HotoneAmperoMiniProfile.patchSelectionDefaults`, make `amperoMiniIsSelectableOverMidi` (`lib/features/midi/hotone_ampero_mini/data/ampero_mini_patch_layout.dart`) accept factory patches, remove the strike-through, update tests. If none works, say so and keep the probe.
5. **(Alone, after 2)** Fix whatever stops the factory read (start in `ampero_mini_patch_reader.dart`; add each real frame as a fixture in `test/unit/ampero_mini_patch_name_test.dart`). Then update the banner (7.2) and the findings doc (7.6).
6. **(Alone, blocked on protocol)** Block ON/OFF feature: locate the on/off flags in the `0E` frame using `C:\Program Files\Hotone\Ampero Editor\Resource\Ampero\File\algorithm_50.xml`, or find a CC route in the editor's MIDI CC Mapping screen (needs a new capture; captures live in `C:\Users\MarkN\ampero-captures\`). Then design the toggle UI. Ask the user before any capture.
7. **(User, hardware)** Test an empty user slot and names with unusual characters.
8. **(Alone)** Split grid/filter code out of the patch list screen (7.4).
9. **(Alone)** Refresh the stale memory note (7.7).
10. **(User)** Verify favorites on the phone: stars persist across restart; the favorites-only filter works.
11. **(Ask user)** Add favorites to the backup export (`lib/core/database/daos/backup_dao.dart`, `lib/features/backup/data/backup_document.dart`, `lib/features/backup/data/backup_upgrades.dart`).

## 9. First move for the new session

1. Read this file; run `git status --short` and `git log --oneline -3`.
2. Compare the APK mtime with `ampero_mini_bank_select_probe.dart`; ask the user what the factory read and the Bank Select attempts showed (steps 2-3).
3. Run the full `flutter test`, then `/ship` the uncommitted work (step 1).

Paste into the new session:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next step 1.
