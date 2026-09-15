import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_patch_selection.dart';
import '../../../core/midi/patch_selection_defaults.dart';
import 'midi_patch_recent_repository.dart';

/// Loads a patch by number, using Bank Select and Program Change - the
/// mechanism the MIDI module brief marks needing hardware verification.
///
/// [experimentalEnabled] is required on every call rather than checked once
/// up front: nothing here trusts a caller to have already asked the user,
/// including a caller written later that forgets to check the toggle itself.
class PatchControlController {
  const PatchControlController(this._engine, this._recents);

  final MidiEngine _engine;
  final MidiPatchRecentRepository _recents;

  /// [patchId] is ToneVault's own `Patch` row id, only for recording "Recently
  /// Used" - the MIDI messages sent only ever depend on [patchNumber]. Left
  /// out when the caller has no such row, such as the plain Patch +/- control.
  Future<void> loadPatch({
    required MidiDeviceProfile profile,
    required int patchNumber,
    required PatchSelectionOverride? override,
    required bool experimentalEnabled,
    int? patchId,
  }) async {
    if (!experimentalEnabled) {
      throw const AppFailure(
        'Enable experimental Program Change before loading a patch.',
      );
    }

    final defaults = profile.patchSelectionDefaults;
    if (defaults == null) {
      throw AppFailure('${profile.displayName} has no known way to select a patch yet.');
    }

    final messages = buildPatchSelectionMessages(
      defaults: defaults,
      override: override,
      channel: profile.defaultChannel,
      patchNumber: patchNumber,
    );

    await guardFailure(() => _engine.sendAll(messages), 'Could not load that patch.');

    if (patchId != null) {
      await _recents.recordUsed(patchId);
    }
  }
}
