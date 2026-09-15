import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/features/midi/data/live_control_navigation.dart';

Patch _patch(int id, String name) => Patch(
  id: id,
  pedalId: 1,
  name: name,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

final _patches = [
  (patch: _patch(1, 'Worship Lead'), programNumber: 1),
  (patch: _patch(2, 'Ballad'), programNumber: 2),
  (patch: _patch(3, 'Solo'), programNumber: 3),
];

void main() {
  test('starts at the first patch when nothing is current', () {
    final next = nextLiveControlPatch(patches: _patches, current: null, direction: 1);

    expect(next!.patch.name, 'Worship Lead');
  });

  test('steps forward from the current patch', () {
    final next = nextLiveControlPatch(patches: _patches, current: _patches[0], direction: 1);

    expect(next!.patch.name, 'Ballad');
  });

  test('steps backward from the current patch', () {
    final next = nextLiveControlPatch(patches: _patches, current: _patches[2], direction: -1);

    expect(next!.patch.name, 'Ballad');
  });

  test('clamps at the last patch rather than wrapping', () {
    final next = nextLiveControlPatch(patches: _patches, current: _patches[2], direction: 1);

    expect(next!.patch.name, 'Solo');
  });

  test('clamps at the first patch rather than wrapping', () {
    final next = nextLiveControlPatch(patches: _patches, current: _patches[0], direction: -1);

    expect(next!.patch.name, 'Worship Lead');
  });

  test('starts from the first patch when the current one is no longer numbered', () {
    final goneMissing = (patch: _patch(99, 'Deleted'), programNumber: 99);
    final next = nextLiveControlPatch(patches: _patches, current: goneMissing, direction: 1);

    expect(next!.patch.name, 'Worship Lead');
  });

  test('is null when there are no numbered patches at all', () {
    final next = nextLiveControlPatch(patches: const [], current: null, direction: 1);

    expect(next, isNull);
  });
}
