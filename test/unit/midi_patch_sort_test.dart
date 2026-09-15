import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/features/midi/data/midi_patch_sort.dart';

Patch _patch(int id, String name) => Patch(
  id: id,
  pedalId: 1,
  name: name,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  final patches = [_patch(1, 'Zeta'), _patch(2, 'alpha'), _patch(3, 'Mid')];

  test('A-Z sorts by name regardless of case', () {
    final sorted = sortMidiPatches(patches, sort: MidiPatchSort.name, numbers: const {});

    expect(sorted.map((p) => p.name), ['alpha', 'Mid', 'Zeta']);
  });

  test('0-127 sorts by program number, starting at 0', () {
    final sorted = sortMidiPatches(
      patches,
      sort: MidiPatchSort.programNumber,
      numbers: const {1: 0, 2: 127, 3: 7},
    );

    expect(sorted.map((p) => p.name), ['Zeta', 'Mid', 'alpha']);
  });

  test('a patch with no number yet sorts after every numbered one', () {
    // It holds no slot on the device, so there is nowhere in 0-127 for it.
    final sorted = sortMidiPatches(
      patches,
      sort: MidiPatchSort.programNumber,
      numbers: const {1: 5},
    );

    // Zeta holds slot 5; the two with no slot follow it, in name order.
    expect(sorted.map((p) => p.name), ['Zeta', 'alpha', 'Mid']);
  });

  test('patches sharing a number fall back to the name, never to row order', () {
    final sorted = sortMidiPatches(
      patches,
      sort: MidiPatchSort.programNumber,
      numbers: const {1: 3, 2: 3, 3: 3},
    );

    expect(sorted.map((p) => p.name), ['alpha', 'Mid', 'Zeta']);
  });

  test('leaves the caller\'s list untouched', () {
    sortMidiPatches(patches, sort: MidiPatchSort.name, numbers: const {});

    expect(patches.map((p) => p.name), ['Zeta', 'alpha', 'Mid']);
  });

  test('labels say what each order means', () {
    expect(MidiPatchSort.name.label, 'A-Z');
    expect(MidiPatchSort.programNumber.label, '0-127');
  });
}
