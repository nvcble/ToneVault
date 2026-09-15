import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_patch_selection_settings_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/patch_selection_defaults.dart';

/// A device profile's patch-selection strategy with any user override
/// already applied.
class PatchSelectionRepository {
  const PatchSelectionRepository(this._dao);

  final MidiPatchSelectionSettingsDao _dao;

  /// The override for [deviceProfileId], or null when nothing has been
  /// changed from the device profile's own candidate.
  Stream<PatchSelectionOverride?> watchOverride(String deviceProfileId) {
    return _dao.watchSettings(deviceProfileId).map(_toDomain);
  }

  /// Writes whichever of [usesBankSelect], [bankSelectMsb] and
  /// [bankSelectLsb] are non-null, alongside whatever was already stored for
  /// the others.
  Future<void> setOverride({
    required MidiDeviceProfile profile,
    bool? usesBankSelect,
    int? bankSelectMsb,
    int? bankSelectLsb,
    bool clearBankSelectMsb = false,
    bool clearBankSelectLsb = false,
  }) async {
    for (final value in [bankSelectMsb, bankSelectLsb]) {
      if (value != null && (value < 0 || value > 127)) {
        throw const AppFailure('A Bank Select value has to be between 0 and 127.');
      }
    }

    final existing = await _dao.findSettings(profile.id);
    final defaults = profile.patchSelectionDefaults;

    await guardFailure(
      () => _dao.upsertSettings(
        deviceProfileId: profile.id,
        usesBankSelect: usesBankSelect ?? existing?.usesBankSelect ?? defaults?.usesBankSelect,
        bankSelectMsb: clearBankSelectMsb
            ? null
            : bankSelectMsb ?? existing?.bankSelectMsb ?? defaults?.bankSelectMsb,
        bankSelectLsb: clearBankSelectLsb
            ? null
            : bankSelectLsb ?? existing?.bankSelectLsb ?? defaults?.bankSelectLsb,
        updatedAt: DateTime.now(),
      ),
      'Could not save the patch-selection strategy.',
    );
  }

  /// Resets the whole strategy back to the device profile's own candidate.
  Future<void> resetOverride(String deviceProfileId) {
    return guardFailure(
      () => _dao.deleteSettings(deviceProfileId),
      'Could not reset the patch-selection strategy.',
    );
  }

  PatchSelectionOverride? _toDomain(MidiPatchSelectionSetting? row) {
    if (row == null) {
      return null;
    }
    return PatchSelectionOverride(
      usesBankSelect: row.usesBankSelect,
      bankSelectMsb: row.bankSelectMsb,
      bankSelectLsb: row.bankSelectLsb,
    );
  }
}
