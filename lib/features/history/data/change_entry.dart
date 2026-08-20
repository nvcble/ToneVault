import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/enums/change_type.dart';
import '../../../core/enums/pedal_status.dart';

/// One thing that happened, ready to be appended to the history.
///
/// The constructors take the rows involved rather than loose ids, so the names
/// stored alongside the foreign keys cannot drift out of step with them: there is
/// no way to log configuration 4 under the name of configuration 9.
///
/// Each constructor also decides which columns the event legitimately has. A
/// renamed configuration has no old and new number, and a knob that moved has no
/// old and new text; leaving that to the call site is how history rows end up
/// half-filled and unreadable.
class ChangeEntry {
  const ChangeEntry._({
    required this.pedalId,
    required this.changeType,
    this.configurationId,
    this.controlId,
    this.configurationName,
    this.controlName,
    this.controlPedalName,
    this.oldValue,
    this.newValue,
    this.oldText,
    this.newText,
    this.reason,
  });

  /// A control moved within a configuration.
  ///
  /// [oldValue] is null when the control had never been set, and [newValue] is
  /// null when the setting was cleared. Values are in the control's own domain,
  /// exactly as stored, so the reading is rendered later from the control.
  ///
  /// [controlPedal] is the pedal [control] is on, which is the configuration's
  /// own pedal in every case but one: a scene of a multi-effects unit sets the
  /// controls of the pedals on its patch. Only then is it worth naming, so that
  /// is the one case it is stored in.
  ChangeEntry.controlValueChanged({
    required Configuration configuration,
    required PedalControl control,
    required Pedal controlPedal,
    required double? oldValue,
    required double? newValue,
    String? reason,
  }) : this._(
         pedalId: configuration.pedalId,
         changeType: ChangeType.controlValueChanged,
         configurationId: configuration.id,
         controlId: control.id,
         configurationName: configuration.name,
         controlName: control.name,
         controlPedalName: controlPedal.id == configuration.pedalId
             ? null
             : controlPedal.name,
         oldValue: oldValue,
         newValue: newValue,
         reason: reason,
       );

  ChangeEntry.configurationCreated(Configuration configuration)
    : this._(
        pedalId: configuration.pedalId,
        changeType: ChangeType.configurationCreated,
        configurationId: configuration.id,
        configurationName: configuration.name,
      );

  /// [configuration] is the configuration as it is now, so its name is the new
  /// one and [previousName] is what it was called before.
  ChangeEntry.configurationRenamed({
    required Configuration configuration,
    required String previousName,
  }) : this._(
         pedalId: configuration.pedalId,
         changeType: ChangeType.configurationRenamed,
         configurationId: configuration.id,
         configurationName: configuration.name,
         oldText: previousName,
         newText: configuration.name,
       );

  /// Keeps the name and drops the id: the row is about to go, and the foreign
  /// key would be nulled out the moment it does.
  ChangeEntry.configurationDeleted(Configuration configuration)
    : this._(
        pedalId: configuration.pedalId,
        changeType: ChangeType.configurationDeleted,
        configurationName: configuration.name,
      );

  ChangeEntry.controlAdded(PedalControl control)
    : this._(
        pedalId: control.pedalId,
        changeType: ChangeType.controlAdded,
        controlId: control.id,
        controlName: control.name,
      );

  /// Keeps the name and drops the id, for the same reason as a deleted
  /// configuration.
  ChangeEntry.controlRemoved(PedalControl control)
    : this._(
        pedalId: control.pedalId,
        changeType: ChangeType.controlRemoved,
        controlName: control.name,
      );

  /// [pedal] carries the status it holds now.
  ChangeEntry.pedalStatusChanged({
    required Pedal pedal,
    required PedalStatus previousStatus,
    String? reason,
  }) : this._(
         pedalId: pedal.id,
         changeType: ChangeType.pedalStatusChanged,
         oldText: previousStatus.label,
         newText: pedal.status.label,
         reason: reason,
       );

  /// The entry is filed under [outgoing], the pedal leaving the rig, because
  /// that is the pedal whose story this ends. The one taking over is named in
  /// [newText] rather than referenced, so the entry still reads if it is later
  /// retired in turn.
  ChangeEntry.pedalReplaced({
    required Pedal outgoing,
    required Pedal incoming,
    String? reason,
  }) : this._(
         pedalId: outgoing.id,
         changeType: ChangeType.pedalReplaced,
         oldText: outgoing.name,
         newText: incoming.name,
         reason: reason,
       );

  final int pedalId;
  final ChangeType changeType;
  final int? configurationId;
  final int? controlId;
  final String? configurationName;
  final String? controlName;
  final String? controlPedalName;
  final double? oldValue;
  final double? newValue;
  final String? oldText;
  final String? newText;
  final String? reason;

  /// [createdAt] comes from the repository's clock rather than from here, so
  /// every entry written for one action shares a timestamp.
  ChangeLogsCompanion toCompanion(DateTime createdAt) {
    return ChangeLogsCompanion.insert(
      pedalId: pedalId,
      changeType: changeType,
      configurationId: Value(configurationId),
      controlId: Value(controlId),
      configurationName: Value(configurationName),
      controlName: Value(controlName),
      controlPedalName: Value(controlPedalName),
      oldValue: Value(oldValue),
      newValue: Value(newValue),
      oldText: Value(oldText),
      newText: Value(newText),
      reason: Value(reason),
      createdAt: createdAt,
    );
  }
}
