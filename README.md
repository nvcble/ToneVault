# ToneVault

Offline-first Android app for documenting a guitar rig: pedals, their controls,
saved configurations, change history, replacements and pedalboards.

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
flutter analyze
flutter test
flutter run
```

## Conventions

- Files stay small and single-purpose; anything past ~250 lines gets split.
- Control values are stored in each control's own `[minValue, maxValue]` domain.
  Clock controls use a `0..1` domain; `ClockValue` is the single place that maps
  a normalized position to a `7:00`-`5:00` clock face.
- `change_logs` is append-only. Pedals are never deleted, only marked replaced.
