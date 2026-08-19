import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/values/control_options.dart';
import 'control_draft.dart';
import 'control_validator.dart';

/// Control definition operations for one pedal at a time.
///
/// Owns what the database cannot express on its own: validation, the display
/// order a new control lands on, and turning driver exceptions into
/// [AppFailure]s whose message can be shown to the user as-is.
class ControlRepository {
  const ControlRepository(this._dao);

  final PedalControlDao _dao;

  Stream<List<PedalControl>> watchControls(int pedalId) =>
      _dao.watchControls(pedalId);

  /// Adds [draft] to the end of the pedal's control list.
  Future<int> createControl(int pedalId, ControlDraft draft) async {
    final control = _validated(draft);
    await _ensureNameIsFree(pedalId, control.name);
    final displayOrder = await _dao.nextDisplayOrder(pedalId);

    return _guard(
      () => _dao.insertControl(
        PedalControlsCompanion.insert(
          pedalId: pedalId,
          name: control.name,
          controlType: control.type,
          minValue: control.minValue,
          maxValue: control.maxValue,
          step: Value(control.step),
          defaultValue: Value(control.defaultValue),
          unit: Value(control.unit),
          options: Value(encodeControlOptions(control.options)),
          displayOrder: displayOrder,
        ),
      ),
      'Could not save this control.',
    );
  }

  /// Display order is left alone: reordering is its own action.
  Future<void> updateControl(int controlId, ControlDraft draft) async {
    final control = _validated(draft);

    final existing = await _dao.findControl(controlId);
    if (existing == null) {
      throw const AppFailure('That control no longer exists.');
    }
    await _ensureNameIsFree(
      existing.pedalId,
      control.name,
      exceptControlId: controlId,
    );

    final matched = await _guard(
      () => _dao.updateControl(
        controlId,
        PedalControlsCompanion(
          name: Value(control.name),
          controlType: Value(control.type),
          minValue: Value(control.minValue),
          maxValue: Value(control.maxValue),
          step: Value(control.step),
          defaultValue: Value(control.defaultValue),
          unit: Value(control.unit),
          options: Value(encodeControlOptions(control.options)),
        ),
      ),
      'Could not update this control.',
    );

    if (!matched) {
      throw const AppFailure('That control no longer exists.');
    }
  }

  /// Nothing restricts this delete: `configuration_values` references controls
  /// with ON DELETE CASCADE, so removing a control also removes whatever each
  /// configuration had stored for it. The confirmation for that belongs to the
  /// UI, which is the only place that knows the user asked.
  Future<void> deleteControl(int controlId) async {
    final deleted = await _guard(
      () => _dao.deleteControl(controlId),
      'Could not remove this control.',
    );

    if (!deleted) {
      throw const AppFailure('That control no longer exists.');
    }
  }

  /// Renumbers a pedal's controls into the given order.
  ///
  /// [controlIdsInOrder] has to be exactly the pedal's current controls: a list
  /// built before someone added or removed one would silently renumber around
  /// the change.
  Future<void> reorderControls(int pedalId, List<int> controlIdsInOrder) async {
    final current = await _dao.controlsOf(pedalId);
    final expected = {for (final control in current) control.id};

    if (expected.length != controlIdsInOrder.length ||
        !expected.containsAll(controlIdsInOrder)) {
      throw const AppFailure(
        'This pedal\'s controls changed while you were reordering them. '
        'Reopen the pedal and try again.',
      );
    }

    await _guard(
      () => _dao.applyOrder(controlIdsInOrder),
      'Could not save the new order.',
    );
  }

  ControlDraft _validated(ControlDraft draft) {
    final normalized = draft.normalized();
    final problem = ControlValidator.draft(normalized);
    if (problem != null) {
      throw AppFailure(problem);
    }
    return normalized;
  }

  /// The `{pedalId, name}` unique key would catch a repeat, but only exactly:
  /// "Level" and "level" on one pedal are equally ambiguous to read back, and a
  /// checked name gives the user the name in the message.
  Future<void> _ensureNameIsFree(
    int pedalId,
    String name, {
    int? exceptControlId,
  }) async {
    final existing = await _dao.controlsOf(pedalId);
    final clash = existing.any(
      (control) =>
          control.id != exceptControlId &&
          control.name.toLowerCase() == name.toLowerCase(),
    );

    if (clash) {
      throw AppFailure('This pedal already has a control called "$name".');
    }
  }

  Future<T> _guard<T>(Future<T> Function() operation, String message) async {
    try {
      return await operation();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure(message, cause: error);
    }
  }
}
