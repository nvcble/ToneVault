import '../../../core/database/app_database.dart';

/// How the Patches list is ordered.
enum MidiPatchSort {
  /// By patch name - the order the database already returns them in, and the
  /// default, so turning the sort control on changes nothing until it is used.
  name('A-Z'),

  /// By the program number the patch loads as, 0 first: the order the slots sit
  /// in on the device itself.
  programNumber('0-127');

  const MidiPatchSort(this.label);

  /// What the switch above the list reads.
  final String label;
}

/// [patches] in [sort] order, with [numbers] mapping a patch id to the program
/// number it has been given.
///
/// A patch with no number yet sorts last under [MidiPatchSort.programNumber]:
/// it holds no slot on the device, so there is nowhere in the run of 0 to 127
/// for it to sit. Ties fall back to the name, so the order never depends on
/// which order rows happened to arrive in.
List<Patch> sortMidiPatches(
  List<Patch> patches, {
  required MidiPatchSort sort,
  required Map<int, int> numbers,
}) {
  int byName(Patch a, Patch b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

  final sorted = [...patches];
  if (sort == MidiPatchSort.name) {
    sorted.sort(byName);
    return sorted;
  }
  sorted.sort((a, b) {
    final left = numbers[a.id];
    final right = numbers[b.id];
    if (left == null || right == null) {
      return left == right ? byName(a, b) : (left == null ? 1 : -1);
    }
    return left == right ? byName(a, b) : left.compareTo(right);
  });
  return sorted;
}
