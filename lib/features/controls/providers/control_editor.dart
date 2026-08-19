import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/control_draft.dart';
import '../data/control_repository.dart';
import 'control_providers.dart';

/// The write side of the controls feature, for screens to call.
///
/// Keeps the repository out of the widgets and gives every screen one place to
/// call, so `onPressed` stays a method reference.
class ControlEditor {
  const ControlEditor(this._repository);

  final ControlRepository _repository;

  Future<void> save(
    ControlDraft draft, {
    required int pedalId,
    int? controlId,
  }) async {
    if (controlId == null) {
      await _repository.createControl(pedalId, draft);
    } else {
      await _repository.updateControl(controlId, draft);
    }
  }

  Future<void> delete(int controlId) => _repository.deleteControl(controlId);

  Future<void> reorder(int pedalId, List<int> controlIdsInOrder) =>
      _repository.reorderControls(pedalId, controlIdsInOrder);
}

final Provider<ControlEditor> controlEditorProvider = Provider<ControlEditor>(
  (ref) => ControlEditor(ref.watch(controlRepositoryProvider)),
);
