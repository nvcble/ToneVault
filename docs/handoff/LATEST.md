# Handoff - 2026-11-10 - Ampero Mini: real patch-name read built, not yet run on hardware

## 1. Snapshot

- Date: 2026-11-10. Branch: `feature/mg30-v5-protocol`, pushed.
- Last commit: `d3be41b Add Ampero Mini read-sequence-verified handoff`. Before it: `160e575 Bump version to 1.1.5+8`, `03dbab1 Ampero Mini: read user patch names from the pedal (08 then 0D)`.
- Working tree was clean before this handoff was written. This file and `docs/handoff/LATEST.md` are the only uncommitted items.
- Goal: build the real read of patch names from the Hotone Ampero Mini (it was blocked on user approval; the user then said "Build the real read").

## 2. What the user asked

1. "Read docs/handoff/LATEST.md, check git status, then continue with next step 1." - **Answered/blocked then unblocked**: step 1 needed approval to write names into the database; I did step 2 (pull frames from the capture) meanwhile and asked.
2. "Build the real read" - **Done in code, unverified on hardware.**
3. `/version-update patch` - **Done**: `1.1.4+7` -> `1.1.5+8` in `pubspec.yaml`.
4. `/ship` - **Done**: three separate commits (feature, version bump, handoff docs), pushed. Split on purpose because the ship skill forbids bundling a version bump with other work.
5. `/handoff` - this file.

## 3. What was done

New (hand-written):
- `lib/features/midi/hotone_ampero_mini/data/ampero_mini_patch_name.dart` - pure `decodeAmperoMiniPatchName(payload, index:)`; returns null unless it is the first `12 00 02 0E` chunk (chunk byte 0) whose slot byte equals `index` and the name is printable ASCII.
- `.../data/ampero_mini_patch_reader.dart` - `AmperoMiniPatchReader.readName(index)`: sends `08`, waits for the `0C` ack for that bank/index, sends `0D`, waits for the first data frame, decodes. Throws `AmperoMiniReadFailure` on timeout or undecodable reply. User bank (1) only.
- `.../data/ampero_mini_patch_sync.dart` - `syncAmperoMiniUserPatchNames`: loops indices 0..98, saves each name immediately through `HotoneAmperoMiniPatchRepository.saveSynced` (with the raw frame), stops at the first failure.
- `.../widgets/ampero_mini_name_sync_sheet.dart` - sheet with Start / Stop / progress / "Stopped. Slot N: reason".
- `test/unit/ampero_mini_patch_name_test.dart` - 6 tests (real captured "WelcomeToAmpero" frame, zero-padded name, wrong slot, later chunk, empty name, bad byte, reader happy path, reader timeout).

Modified:
- `.../widgets/ampero_mini_diagnostics_menu.dart` - new menu item "Read pedal names" (a longer label overflowed 256 px in an existing widget test, so it was shortened).
- `pubspec.yaml` - version line only.

Generated files: none.

## 4. What was found

- **Verified (earlier sessions, hardware):** `08` draws only the `0C` ack; `0D` returns the data for the slot chosen by the **last 08**, not the slot in its own request.
- **Observed (editor capture `C:\Users\MarkN\ampero-captures\p02-1_read.pcapng`, tshark at `C:\Program Files\Wireshark\tshark.exe`, filter `usb.device_address==60`):** the reply to `0D` is a **run of several `12 00 02 0E` frames**, chunk counter at byte 4 after the `0E` byte (0,1,2,3...). Only chunk 0 holds the name. Name = nibble pairs (high, low) from byte 13; capture frame 1708 decodes to `WelcomeToAmpero` padded with a **space** to 16 characters.
- **Observed conflict:** "Slick Lead" (earlier probe) was `00`-padded; the capture sample is space-padded. The decoder stops at `00 00` or 16 chars and trims trailing spaces. End-of-name rule still **Unknown** beyond three samples.
- **Observed, unexplained:** in the capture's first 0E chunk the "sub-type" bytes (body 0-1) were `00 00`, while the earlier probe notes recorded `00 01`. The decoder ignores them and relies on chunk byte (body 4) == 0 and slot byte (body 8) == requested index. If hardware shows otherwise, this is the first place to look.
- **Observed:** capture's first `0D` was for bank 0 / index 0 yet returned "WelcomeToAmpero", which the display calls P01-1 - not reconciled. Factory bank 0 reads remain untested.
- Python is not installed on this machine (the `python` shortcut opens the Store). Use tshark, dart or bash for scripting.

## 5. Decisions and constraints

- Names come only from the pedal, never hand-typed (user rule, 2026-09-16). `local_label` stays unwritten; `upsertPatch` also resets `locallyModified` to false on each sync.
- Never store a name from a reply whose body slot differs from the slot asked for.
- File-size rule: under ~250 lines, 300 absolute. All new files are 40-120 lines.
- Read **user patches only** (bank 1, 99 slots). Factory deliberately left out: untested.
- Commit trailer used: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The ship skill text says `Claude Opus 5`; I used the actual model and told the user.
- No full-sequence replay, no `0F` requests, no factory reads.

## 6. State of verification

- Seen passing: `dart analyze lib/features/midi/hotone_ampero_mini test/unit/ampero_mini_patch_name_test.dart` = no issues; `flutter test test/unit/ampero_mini_patch_name_test.dart` = 6 passed; full `flutter test` = 1685 passed, 1 skipped, 1 failed (the menu-overflow widget test).
- That failure was fixed by shortening the label. After the fix I ran only `test/widget/hotone_ampero_mini_patch_list_screen_test.dart` and the new unit test (23 passed). **The full suite was not re-run after the fix.**
- **Not verified on hardware:** the whole sync. No APK was built from `03dbab1`; the phone still has the earlier build. Check APK mtime vs source mtime before claiming it is installed.
- The decoder's name-end rule and the `00 00`/`00 01` sub-type difference are unproven on a real pedal.
- Still unchecked from before: favorites persistence across restart; the v27 migration on the real database.

## 7. Open items and risks

1. If a slot is empty, the reply may not decode, and the sync stops at that slot with "reply did not decode to a name". Behaviour on empty slots is Unknown.
2. `AmperoMiniPatchReader` timeout is 2 s per request; a slow pedal could be reported as "did not answer".
3. Syncing 99 slots sends 198 requests one at a time; the pedal's display behaviour during the sync is unchecked (it did not change during single reads).
4. `lib/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart` (about 256 lines) is still over the soft limit.
5. Stale memory notes (not edited): `ampero-mini-patch-read-blocker` is now wrong (a read works and is built); `ampero-mini-next-hardware-session` is out of date. Update after the hardware run.
6. `docs/ampero_mini_protocol_capture.md` still describes capturing as future work; `docs/ampero_mini_capture_1_findings.md` has no top summary and does not mention the multi-chunk `0E` reply or the space padding found this session.
7. `ampero_mini_read_probe_sheet.dart` still says "No acknowledgement like the editor's was seen" for 0D/0F, which reads like a failure.
8. Git warns LF->CRLF on touched files (pre-existing).
9. This handoff is uncommitted: run `/ship` to keep it.

## 8. Next steps

1. **(User, hardware)** Build and install the app (`flutter build apk`, then install), open the overflow menu -> "Read pedal names" -> Start. Compare the first names with the pedal display (P01-1 should read "WelcomeToAmpero"). Report the count shown and where it stopped, if it did. Blocker: user.
2. **(Alone, after 1)** Fix whatever the run shows: name end rule, empty slots, the `00 00` vs `00 01` sub-type bytes, timeouts. Start from `ampero_mini_patch_name.dart` and `ampero_mini_patch_reader.dart`; add the real frames as test fixtures.
3. **(Alone)** Re-run the full `flutter test` to confirm the post-fix baseline (last full run had 1685 passed, 1 skipped before the label fix).
4. **(Alone)** Document the verified protocol: add a summary section to `docs/ampero_mini_capture_1_findings.md` (include multi-chunk reply, name layout, padding) and update `docs/ampero_mini_protocol_capture.md`.
5. **(Alone)** Update the stale memory notes (7.5) once step 1 confirms the read works.
6. **(User, hardware)** Try factory patches (bank 0) via 08+0D and an empty slot; send screenshots. Then extend the reader to bank 0 if it works.
7. **(Alone, optional)** Decode more of the `0E` frame (block on/off, `0F` k=0-4) using `C:\Program Files\Hotone\Ampero Editor\Resource\Ampero\File\algorithm_50.xml` for labels.
8. **(User, hardware)** Try the editor's Bank Select layout (`B0 3D 14`, `B0 00 <bank>`, `C0 <index>`) via the factory-patch sheet.
9. **(User)** Verify favorites on the phone: stars persist across restart, favorites-only filter works.
10. **(Alone)** Make the probe sheet say "reply received" for 0D/0F; split grid/filter code out of the patch list screen to get under the size limit (7.4, 7.7).
11. **(Ask user)** Add favorites to backup export (`lib/core/database/daos/backup_dao.dart`, `lib/features/backup/data/backup_document.dart`, `lib/features/backup/data/backup_upgrades.dart`). Version bump was already done this session (`1.1.5+8`).

## 9. First move for the new session

1. Read this file; run `git status --short` and `git log --oneline -3`.
2. Ask the user whether the build was installed and what the "Read pedal names" run showed (step 1); check APK mtime against source mtime first.
3. Run the full `flutter test` for a baseline.

Paste into the new session:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next step 1.
