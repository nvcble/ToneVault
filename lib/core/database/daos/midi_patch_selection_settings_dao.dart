import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_patch_selection_settings_table.dart';

part 'midi_patch_selection_settings_dao.g.dart';

/// Typed queries over `midi_patch_selection_settings`.
///
/// Validation belongs to `PatchSelectionRepository`; this class only reads
/// and writes the one row a device profile can have.
@DriftAccessor(tables: [MidiPatchSelectionSettings])
class MidiPatchSelectionSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$MidiPatchSelectionSettingsDaoMixin {
  MidiPatchSelectionSettingsDao(super.attachedDatabase);

  Stream<MidiPatchSelectionSetting?> watchSettings(String deviceProfileId) {
    return (select(midiPatchSelectionSettings)
          ..where((row) => row.deviceProfileId.equals(deviceProfileId)))
        .watchSingleOrNull();
  }

  Future<MidiPatchSelectionSetting?> findSettings(String deviceProfileId) {
    return (select(midiPatchSelectionSettings)
          ..where((row) => row.deviceProfileId.equals(deviceProfileId)))
        .getSingleOrNull();
  }

  /// Stores [changes] for [deviceProfileId], replacing whatever was there
  /// before - always the whole row, since the fields form one strategy
  /// rather than independent settings.
  Future<void> upsertSettings({
    required String deviceProfileId,
    required bool? usesBankSelect,
    required int? bankSelectMsb,
    required int? bankSelectLsb,
    required DateTime updatedAt,
  }) {
    return into(midiPatchSelectionSettings).insert(
      MidiPatchSelectionSettingsCompanion.insert(
        deviceProfileId: deviceProfileId,
        usesBankSelect: Value(usesBankSelect),
        bankSelectMsb: Value(bankSelectMsb),
        bankSelectLsb: Value(bankSelectLsb),
        updatedAt: updatedAt,
      ),
      onConflict: DoUpdate(
        (_) => MidiPatchSelectionSettingsCompanion(
          usesBankSelect: Value(usesBankSelect),
          bankSelectMsb: Value(bankSelectMsb),
          bankSelectLsb: Value(bankSelectLsb),
          updatedAt: Value(updatedAt),
        ),
        target: [midiPatchSelectionSettings.deviceProfileId],
      ),
    );
  }

  /// Returns whether a row existed to remove - resetting the whole strategy
  /// back to the device profile's own candidate.
  Future<bool> deleteSettings(String deviceProfileId) async {
    final deletedRows = await (delete(
      midiPatchSelectionSettings,
    )..where((row) => row.deviceProfileId.equals(deviceProfileId))).go();
    return deletedRows > 0;
  }
}
