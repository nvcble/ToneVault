import '../../../core/database/daos/midi_patch_program_number_dao.dart';

/// Which patch Previous ([direction] -1) or Next ([direction] 1) lands on.
///
/// Clamped rather than wrapping: stepping past the last patch during a set
/// staying there is a smaller surprise than looping back to the first one.
/// Null [current] - nothing loaded yet, or a program number not in [patches]
/// any more - starts from the first patch regardless of direction.
NumberedPatch? nextLiveControlPatch({
  required List<NumberedPatch> patches,
  required NumberedPatch? current,
  required int direction,
}) {
  if (patches.isEmpty) {
    return null;
  }

  final currentIndex = current == null ? -1 : patches.indexOf(current);
  final targetIndex = (currentIndex == -1 ? 0 : currentIndex + direction).clamp(
    0,
    patches.length - 1,
  );
  return patches[targetIndex];
}
