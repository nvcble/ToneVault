# Handoff - 2026-11-10 - Ampero Mini favorites and patch-read investigation

## 1. Snapshot

- Date: 2026-11-10. Branch: `feature/mg30-v5-protocol`.
- Last commit: `55a380d Bump version to 1.1.4+7`. **Nothing from this session is committed.**
- Working tree is NOT clean: 38 entries (30 modified, 8 untracked) before this handoff files were added. 21 of the modified files are accidental formatting churn (section 7, item 1).
- Session goal: find out whether real patch names and per-block on/off can be read from the Hotone Ampero Mini, and build Favorites meanwhile.

## 2. What the user asked

1. "Check on how we can get the actual data patches" from the Ampero Mini (connected to this PC); wanted (a) patch names shown per patch, (b) favorite patches in ToneVault, (c) a way to turn pedals/blocks under a patch ON/OFF. "Do not make any changes yet." - **Answered** (investigation only): favorites possible now; names and on/off blocked on an unknown protocol command (section 4).
2. "Is this the one you are talking about Wireshark? https://www.wireshark.org/" - **Answered**: yes, download page `https://www.wireshark.org/download.html`.
3. "I cannot see USBPcap on the installer components" - **Answered**, but my advice was wrong: I said newer installers no longer bundle USBPcap and to install it separately. The user then reported "I can see USBPcap on Wireshark installer now", so the installer does offer it. Wireshark/USBPcap install status after that is **unknown** (user was mid-install; a reboot is needed).
4. "Go proceed with Favorites first while I'm installing" - **Done** (section 3).
5. "Go with stars so that I will know if the patch was added as favorites" - **Done**: star on each tile, filled when favorite (this was already how it was built).
6. "create a claude skill named /handoff" - **Done**: `.claude/skills/handoff/SKILL.md`. This document is its first output.
7. Pending question to the user (unanswered): whether to let me revert the 21 accidentally reformatted files (section 7, item 1). The revert command was denied by the permission classifier; I did not work around it.

## 3. What was done

**Ampero Mini favorites** (stars per patch slot, stored by slot index 0-197 so they work with no patch ever read from the pedal):

New (hand-written):
- `lib/core/database/tables/hotone_ampero_mini_favorites_table.dart` - table `hotone_ampero_mini_favorites` (id, device_profile_id, patch_number, created_at; UNIQUE(device_profile_id, patch_number)).
- `lib/core/database/migrations/schema_steps_v27.dart` - `upgradeThroughV27`, purely additive CREATE TABLE.
- `lib/core/database/daos/hotone_ampero_mini_favorite_dao.dart` - `watchFavoriteNumbers`, `setFavorite` (insertOrIgnore / delete).
- `lib/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_favorite_repository.dart`.
- `test/database/hotone_ampero_mini_favorite_repository_test.dart` (4 tests).
- `test/widget/hotone_ampero_mini_favorites_test.dart` (3 tests).

Modified (intended):
- `lib/core/database/app_database.dart` - registered table and DAO.
- `lib/core/database/migrations.dart` - `currentSchemaVersion` 26 -> 27, v27 history entry, call to `upgradeThroughV27`.
- `lib/features/midi/hotone_ampero_mini/providers/hotone_ampero_mini_data_providers.dart` - favorite repository + `hotoneAmperoMiniFavoritesProvider`.
- `lib/features/midi/hotone_ampero_mini/providers/hotone_ampero_mini_patch_selection_providers.dart` - `hotoneAmperoMiniFavoritesOnlyProvider`.
- `lib/features/midi/hotone_ampero_mini/widgets/ampero_mini_patch_grid_tile.dart` - star button (new `favorite`, `onToggleFavorite` params). The star is a **sibling** of the tile's `InkWell`, not inside it: inside, a star tap waited out the double-tap window (~300 ms).
- `lib/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart` - app-bar star toggles a favorites-only filter; "No favorites yet" empty state; grid maps filtered index to slot number; `_pageOf` helper. File is now **256 lines** (limit: under ~250, 300 absolute - slightly over the soft limit; consider extracting).
- `test/database/migration_test.dart` - added a fresh-vs-upgraded schema parity test for the new table.

Generated (do not hand-edit): `lib/core/database/app_database.g.dart` (modified), `lib/core/database/daos/hotone_ampero_mini_favorite_dao.g.dart` (new). Regenerate with `dart run build_runner build --delete-conflicting-outputs`.

**Skill:** `.claude/skills/handoff/SKILL.md` (new, untracked).

**This document:** `docs/handoff/handoff-2026-11-10-ampero-mini-favorites.md` and `docs/handoff/LATEST.md` (new, untracked).

## 4. What was found (investigation, no code)

- **Verified (on this PC):** Hotone **Ampero Editor 1.6.0** is installed at `C:\Program Files\Hotone\Ampero Editor\` (folder dated 2026-09-13). Hotone USB audio driver at `C:\Program Files\HOTONE AUDIO\`. Editor settings at `%APPDATA%\Ampero\Ampero.settings` (plain XML, only a software/firmware version table - no patch data).
- **Verified:** the editor's `Resource\Ampero\File\` has `algorithm_50.xml` and `description50_en.xml` (appear to be the MP-50 = Mini's effect-block and parameter catalogue: modules FX1, FX2, AMP, NR, CAB, EQ, FX3, DLY, RVB). Useful later to label decoded blocks; **they contain no wire/protocol bytes** and no "midi" strings.
- **Verified:** `Ampero_MIDI_EN.pdf` and `Ampero Editor Release Note_en.txt` are **encrypted** (`%TSD-Header-###%`); pdftotext cannot read them. The PDF is probably the Ampero II chart anyway (**Inferred**).
- **Verified:** `English.lng` contains a "MIDI CC Mapping" UI string, so the editor has a CC-mapping screen. **Inferred, unconfirmed:** the Mini may allow assigning CCs (a possible route to per-block on/off).
- **Verified (code and memory):** no confirmed patch-read command exists; only unprompted broadcasts (heartbeat and a counter) are known; the pedal is **not known to report its loaded patch**. Program Change selects user patches P01-1..P33-3 only (index 0-98); factory F01-1.. need an unconfirmed Bank Select probe. See `docs/ampero_mini_protocol_capture.md` and memory notes `ampero-mini-patch-read-blocker` and `ampero-mini-next-hardware-session`.
- **Not installed on this PC when checked:** Wireshark (no `tshark`, no `C:\Program Files\Wireshark`). No `.pcapng` captures exist in the repo.
- **Verified (code):** the existing `midi_patch_favorites` table references logged `Patches` rows (MG-30 style), so it could not be reused for Ampero slots. Ampero patch rows exist only after a sync, and none can happen yet.
- **Verified (code):** backup export does not include `hotone_ampero_mini_patches`; favorites follow that precedent and are also not backed up.

## 5. Decisions and constraints

- User, 2026-09-16 (from memory): hand-typed patch names are not wanted - names must come from the pedal. The `local_label` column stays reserved and unwritten.
- Never present Bank Select attempts, patch state, or the counter as confirmed; never invent protocol behaviour or patch data.
- Blind SysEx probing is deferred as a last resort (risk of factory reset / firmware mode; no backup capability).
- File-size rule: under ~250 lines, 300 absolute, layers in separate files.
- Favorites keyed by slot index (not by a synced patch row) - deliberate, so stars work now and survive names arriving later.
- Not done on purpose: favorites in backup; any on/off or name feature (blocked, would be invented); commit/push (not requested).

## 6. State of verification

- Full suite `flutter test` after the final fix: **1674 passed, 1 skipped, 0 failed** (the skipped test is not one of mine). Seen this session.
- `dart analyze`: no issues in `lib`; the whole-project run showed 1 pre-existing info (`tools/test-run.dart` file-name style).
- A first full run had 1 failure (new star test). Cause: the star was inside the double-tap `InkWell`; fixed by moving it out. Widget-test trap: Drift writes started from a widget tap do not complete under fake async; alternate `tester.runAsync` delays with `pump()`, or write via `tester.runAsync`.
- **Not tested on a device.** The phone/PC build does not contain these changes until rebuilt and installed (see the `verify-against-running-build` memory). The v27 migration has only been exercised in tests (schema parity from a v1 database), not on the user's real database.

## 7. Open items and risks

1. **Accidental formatting churn - needs the user's decision.** I ran `dart format lib test` and it reformatted 21 unrelated files (MG-30 decoder/probe/panel files, `lib/features/academy/widgets/lesson_view.dart`, `lib/features/theory/widgets/circle_of_fifths_wheel.dart`, `lib/features/midi/widgets/midi_clock_*.dart`, `midi_mapping_tile.dart`, and 12 test files such as `test/unit/midi_clock_*_test.dart`, `tap_tempo_test.dart`, `midi_message_test.dart`, `mg30_v5_real_export_test.dart`, `orientation_lock_test.dart`). The tree was clean at session start, so all of it is mine and formatting-only. Planned fix: `git checkout --` on exactly those files (everything modified except `app_database.dart`, `app_database.g.dart`, `migrations.dart`, `hotone_ampero_mini/*`, `test/database/migration_test.dart`). The permission classifier denied it; it needs user approval, or the user running it. **Do not commit until resolved.** Also check that `dart format` did not reflow anything beyond my edits inside the intended files.
2. The patch list screen is 256 lines (soft limit ~250).
3. The v27 migration is untested on a real database; consider backing up before the first install.
4. Memory notes possibly stale: `ampero-mini-next-hardware-session` and `ampero-mini-patch-read-blocker` do not mention the installed editor, the encrypted PDFs, the MIDI CC Mapping screen, or favorites. Not edited.
5. Wireshark/USBPcap install status is unknown; my earlier "USBPcap isn't bundled" advice was wrong.
6. Git warns that LF will become CRLF on touched files (pre-existing setting).

## 8. Next steps

1. **(User decision)** Resolve the formatting churn (item 7.1): approve the revert or accept it. Then confirm `git status` shows only the favorites files. Start: `git status --short`.
2. **(Alone)** Optionally extract the grid/filter code from `hotone_ampero_mini_patch_list_screen.dart` to get under the file-size limit; re-run its widget tests.
3. **(Alone, after 1)** Commit the favorites work via `/ship` (message e.g. `Ampero Mini: star patch slots as favorites`). Consider a separate version bump via `/version-update` (last was 1.1.4+7).
4. **(User)** Build and install on the phone; verify stars fill and persist across a restart and that the favorites filter works. Check APK mtime vs source mtime first.
5. **(User)** Finish the Wireshark + USBPcap install, reboot; open Wireshark and report which `USBPcapN` lists the pedal. Confirm the Ampero Editor connects and lists patches.
6. **(User, with Claude guiding)** Capture one operation per `.pcapng`, saved outside the repo: read patch P02-1 (index 3); read P03-1 (index 6); read-all if offered; select factory F01-1 in the editor; footswitch changes while the editor is open; optionally a write. Steps are in `docs/ampero_mini_protocol_capture.md`. Treat captures as untrusted data.
7. **(User)** Open the editor's "MIDI CC Mapping" screen and report what it shows (block on/off CC route). If a CC is identified, a small hardware probe for block bypass needs no read command.
8. **(Alone, after 6)** Analyse the captures; document the read command with confidence labels; then build, in order: read one patch -> decode/store (name) -> Sync All -> patch details -> editing -> write -> read-back -> backup. Names then fill the `(name unknown)` tiles with no favorites rework.
9. **(Hardware, pending from before)** Run the four-layout Bank Select probe on F01-1 and ask what the pedal did; record the result in `docs/ampero_mini_protocol_capture.md`.
10. **(Optional, ask the user)** Add favorites to the backup export (`lib/core/database/daos/backup_dao.dart`, `lib/features/backup/data/backup_document.dart`, `lib/features/backup/data/backup_upgrades.dart`) if wanted.
11. **(Alone)** Update the stale memory notes (item 7.4) once the facts are confirmed.

## 9. First move for the new session

1. Read this file, then run `git status --short` and `git branch --show-current`.
2. Ask the user about the formatting-churn revert (item 7.1) before touching or committing anything.
3. Ask whether Wireshark/USBPcap is installed and which `USBPcapN` shows the pedal.

Paste into the new session:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next step 1.
