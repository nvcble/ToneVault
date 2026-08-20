# ToneVault

Offline-first Android app for documenting a guitar rig: pedals, their controls,
saved configurations, change history, replacements and pedalboards. Android is
the only platform it ships for, so `flutter run` never has to be told which
device to use.

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
```

The vault lives in a file in the app's documents directory, so it belongs to the
phone it was made on; a backup file is the only way to carry gear between
devices.

Browser support was removed: it added a WebAssembly copy of sqlite3 and a drift
worker to keep in step with every drift upgrade, and a second device for
`flutter run` to ask about, for a build nothing depended on. `web/` and the
`DriftWebOptions` it needed are in the history if it is ever wanted back — see
`lib/core/database/connection.dart`.

## Conventions

- Files stay small and single-purpose; anything past ~250 lines gets split.
- Control values are stored in each control's own `[minValue, maxValue]` domain.
  Clock controls use a `0..1` domain; `ClockValue` is the single place that maps
  a normalized position to a `7:00`-`5:00` clock face.
- `change_logs` is append-only. Pedals are never deleted, only marked replaced.
