import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pedal_draft.dart';
import '../data/pedal_repository.dart';
import 'pedal_providers.dart';

/// Write actions behind the pedal screens.
///
/// Screens call these and then only decide what to show and where to go, so
/// deciding between an insert and an update never lands in a widget.
class PedalEditor {
  const PedalEditor(this._repository);

  final PedalRepository _repository;

  /// Creates a pedal when [pedalId] is null, otherwise updates that one.
  ///
  /// Throws [AppFailure] on invalid input or a failed write; the caller shows
  /// its message.
  Future<void> save(PedalDraft draft, {int? pedalId}) async {
    if (pedalId == null) {
      await _repository.createPedal(draft);
    } else {
      await _repository.updatePedal(pedalId, draft);
    }
  }

  Future<void> delete(int pedalId) => _repository.deletePedal(pedalId);
}

final Provider<PedalEditor> pedalEditorProvider = Provider<PedalEditor>(
  (ref) => PedalEditor(ref.watch(pedalRepositoryProvider)),
);
