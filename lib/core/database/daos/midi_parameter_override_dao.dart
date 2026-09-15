import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_parameter_overrides_table.dart';

part 'midi_parameter_override_dao.g.dart';

/// Typed queries over `midi_parameter_overrides`.
///
/// Validation (the parameter name has to be one the device profile actually
/// ships, the CC number has to be in range) belongs to
/// `MidiParameterMappingRepository`; this class only reads and writes rows.
@DriftAccessor(tables: [MidiParameterOverrides])
class MidiParameterOverrideDao extends DatabaseAccessor<AppDatabase>
    with _$MidiParameterOverrideDaoMixin {
  MidiParameterOverrideDao(super.attachedDatabase);

  Stream<List<MidiParameterOverride>> watchOverrides(String deviceProfileId) {
    return (select(
      midiParameterOverrides,
    )..where((row) => row.deviceProfileId.equals(deviceProfileId))).watch();
  }

  Future<MidiParameterOverride?> findOverride({
    required String deviceProfileId,
    required String parameterName,
  }) {
    return (select(midiParameterOverrides)..where(
          (row) =>
              row.deviceProfileId.equals(deviceProfileId) &
              row.parameterName.equals(parameterName),
        ))
        .getSingleOrNull();
  }

  /// Stores [ccNumber] for [parameterName], replacing whatever was there
  /// before.
  Future<void> upsertOverride({
    required String deviceProfileId,
    required String parameterName,
    required int ccNumber,
    required DateTime updatedAt,
  }) {
    return into(midiParameterOverrides).insert(
      MidiParameterOverridesCompanion.insert(
        deviceProfileId: deviceProfileId,
        parameterName: parameterName,
        ccNumber: ccNumber,
        updatedAt: updatedAt,
      ),
      onConflict: DoUpdate(
        (_) => MidiParameterOverridesCompanion(
          ccNumber: Value(ccNumber),
          updatedAt: Value(updatedAt),
        ),
        target: [
          midiParameterOverrides.deviceProfileId,
          midiParameterOverrides.parameterName,
        ],
      ),
    );
  }

  /// Returns whether a row existed to remove - resetting one parameter to the
  /// device profile's default.
  Future<bool> deleteOverride({
    required String deviceProfileId,
    required String parameterName,
  }) async {
    final deletedRows =
        await (delete(midiParameterOverrides)..where(
              (row) =>
                  row.deviceProfileId.equals(deviceProfileId) &
                  row.parameterName.equals(parameterName),
            ))
            .go();
    return deletedRows > 0;
  }

  /// Resets every parameter of one device profile to its defaults.
  Future<int> deleteAllOverrides(String deviceProfileId) {
    return (delete(
      midiParameterOverrides,
    )..where((row) => row.deviceProfileId.equals(deviceProfileId))).go();
  }
}
