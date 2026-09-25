import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_parameter_override_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_parameter_definition.dart';
import '../../../core/midi/midi_parameter_override.dart' as domain;
import '../../../core/midi/midi_parameter_resolution.dart';

/// A device profile's parameters with any user remapping already applied.
///
/// The one place that turns a `MidiParameterOverride` database row into the
/// domain type `applyParameterOverrides` reads - nothing else needs to know
/// the override lives in Drift at all.
class MidiParameterMappingRepository {
  const MidiParameterMappingRepository(this._dao);

  final MidiParameterOverrideDao _dao;

  /// [profile]'s parameters, with any stored override's CC number in place of
  /// the default. Pushes a new list whenever an override changes.
  Stream<List<MidiParameterDefinition>> watchEffectiveParameters(
    MidiDeviceProfile profile,
  ) {
    return _dao
        .watchOverrides(profile.id)
        .map(
          (rows) => applyParameterOverrides(
            profile.parameterDefinitions,
            _toDomain(rows),
          ),
        );
  }

  /// The stored override for one parameter, or null when it uses the
  /// device profile's default.
  Stream<MidiParameterOverride?> watchOverride({
    required String deviceProfileId,
    required String parameterName,
  }) {
    return _dao
        .watchOverrides(deviceProfileId)
        .map(
          (rows) => rows
              .where((row) => row.parameterName == parameterName)
              .firstOrNull,
        );
  }

  /// The names of every parameter of [deviceProfileId] that has been
  /// remapped away from its default, for a mapping screen to mark.
  Stream<Set<String>> watchOverriddenNames(String deviceProfileId) {
    return _dao
        .watchOverrides(deviceProfileId)
        .map((rows) => rows.map((row) => row.parameterName).toSet());
  }

  /// Remaps [parameterName] to [ccNumber].
  ///
  /// Refuses a name the device profile does not ship - a user can redirect an
  /// existing function, not invent one - and a CC number outside the 7-bit
  /// range every MIDI data byte is limited to.
  Future<void> setOverride({
    required MidiDeviceProfile profile,
    required String parameterName,
    required int ccNumber,
  }) async {
    final knownName = profile.parameterDefinitions.any(
      (definition) => definition.name == parameterName,
    );
    if (!knownName) {
      throw AppFailure(
        '"$parameterName" is not a parameter of ${profile.displayName}.',
      );
    }
    if (ccNumber < 0 || ccNumber > 127) {
      throw const AppFailure('A MIDI CC number has to be between 0 and 127.');
    }

    await guardFailure(
      () => _dao.upsertOverride(
        deviceProfileId: profile.id,
        parameterName: parameterName,
        ccNumber: ccNumber,
        updatedAt: DateTime.now(),
      ),
      'Could not save that CC mapping.',
    );
  }

  /// Resets [parameterName] back to the device profile's own default.
  Future<void> resetOverride({
    required String deviceProfileId,
    required String parameterName,
  }) {
    return guardFailure(
      () => _dao.deleteOverride(
        deviceProfileId: deviceProfileId,
        parameterName: parameterName,
      ),
      'Could not reset that mapping.',
    );
  }

  /// Resets every parameter of [deviceProfileId] to its defaults.
  Future<void> resetAllOverrides(String deviceProfileId) {
    return guardFailure(
      () => _dao.deleteAllOverrides(deviceProfileId),
      'Could not reset the mappings.',
    );
  }

  List<domain.MidiParameterOverride> _toDomain(
    List<MidiParameterOverride> rows,
  ) => [
    for (final row in rows)
      domain.MidiParameterOverride(
        parameterName: row.parameterName,
        ccNumber: row.ccNumber,
      ),
  ];
}
