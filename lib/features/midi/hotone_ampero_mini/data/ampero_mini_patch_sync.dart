import 'dart:typed_data';

import 'ampero_mini_patch_layout.dart';
import 'ampero_mini_patch_reader.dart';
import 'hotone_ampero_mini_patch_repository.dart';

/// How a sync ended. [saved] slots are stored even when [failure] is set.
class AmperoMiniSyncOutcome {
  const AmperoMiniSyncOutcome({required this.saved, this.failure});
  final int saved;
  final AmperoMiniReadFailure? failure;
}

/// Reads patch names, user then factory, one slot at a time and stores each as soon as
/// it is read. Stops at the first failure or when [shouldStop] returns true -
/// it never skips a slot and carries on. Names come only from the pedal.
Future<AmperoMiniSyncOutcome> syncAmperoMiniPatchNames({
  required AmperoMiniPatchReader reader,
  required HotoneAmperoMiniPatchRepository repository,
  void Function(int done)? onProgress,
  bool Function()? shouldStop,
  int count = amperoMiniPatchCount,
}) async {
  var saved = 0;
  for (var index = 0; index < count; index++) {
    if (shouldStop?.call() ?? false) break;
    try {
      final read = await reader.readName(index);
      await repository.saveSynced(
        patchNumber: index,
        name: read.name,
        rawSysEx: Uint8List.fromList(read.raw),
      );
      saved++;
      onProgress?.call(saved);
    } on AmperoMiniReadFailure catch (failure) {
      return AmperoMiniSyncOutcome(saved: saved, failure: failure);
    }
  }
  return AmperoMiniSyncOutcome(saved: saved);
}
