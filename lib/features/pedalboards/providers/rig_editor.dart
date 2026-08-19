import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pedalboard_draft.dart';
import '../data/pedalboard_repository.dart';
import 'pedalboard_providers.dart';

/// Write actions behind the rig screens.
///
/// Screens call these and then only decide what to show and where to go, so
/// deciding between an insert and an update never lands in a widget.
class RigEditor {
  const RigEditor(this._repository);

  final PedalboardRepository _repository;

  /// Creates a rig when [pedalboardId] is null, otherwise updates that one.
  ///
  /// Throws [AppFailure] on invalid input or a failed write; the caller shows
  /// its message.
  Future<void> save(PedalboardDraft draft, {int? pedalboardId}) async {
    if (pedalboardId == null) {
      await _repository.createPedalboard(draft);
    } else {
      await _repository.updatePedalboard(pedalboardId, draft);
    }
  }

  Future<void> delete(int pedalboardId) =>
      _repository.deletePedalboard(pedalboardId);
}

final Provider<RigEditor> rigEditorProvider = Provider<RigEditor>(
  (ref) => RigEditor(ref.watch(pedalboardRepositoryProvider)),
);
