# ToneVault

Offline-first Android app for documenting a guitar rig: pedals, their controls,
saved configurations, change history, replacements and pedalboards. It also runs
in a browser, which is the quickest way to look at it on a desktop.

## Stack

| Concern | Choice |
| --- | --- |
| UI | Flutter, Material 3, dark-first, portrait only |
| State | Riverpod 2.x (plain providers, no code generation) |
| Navigation | go_router with a 5-tab stateful shell |
| Persistence | Drift + SQLite, offline only |

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after schema changes
dart format lib test
flutter analyze
flutter test
flutter run
flutter run -d chrome            # the same app in a browser
```

## Running in a browser

Android keeps the vault in a file in the documents directory. A browser has no
such directory, so sqlite3 runs as WebAssembly against whichever storage the
browser offers — OPFS where it exists, IndexedDB otherwise. Two files in `web/`
make that work, and both are checked in because the app cannot open its database
without them:

| File | Where it comes from |
| --- | --- |
| `web/sqlite3.wasm` | the `sqlite3-<version>` release of `simolus3/sqlite3.dart`, matching the `sqlite3` version in `pubspec.lock` |
| `web/drift_worker.js` | the `drift` package in the pub cache (`drift-<version>/drift_worker.js`) |

Refresh both when drift or sqlite3 is upgraded; a worker built against a
different drift version is the first thing to suspect if the web build opens to a
blank page.

A browser vault belongs to the browser profile it was made in. It is a separate
collection from the one on a phone, and a backup file is the only way to carry
gear between them.

## Conventions

- Files stay small and single-purpose; anything past ~250 lines gets split.
- Control values are stored in each control's own `[minValue, maxValue]` domain.
  Clock controls use a `0..1` domain; `ClockValue` is the single place that maps
  a normalized position to a `7:00`-`5:00` clock face.
- `change_logs` is append-only. Pedals are never deleted, only marked replaced.
