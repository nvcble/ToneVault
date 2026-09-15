import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_device_link_dao.dart';
import '../../../core/enums/control_type.dart';
import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/pedal_type.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../controls/data/control_draft.dart';
import '../../controls/data/control_repository.dart';
import '../../pedals/data/pedal_draft.dart';
import '../../pedals/data/pedal_repository.dart';

/// Turns a device profile into an owned unit: one pedal for the device
/// itself, one child pedal per block, and one control per block parameter -
/// all through the same `PedalRepository`/`ControlRepository` any hand-logged
/// unit goes through, so a linked MG-30 reads on every existing pedal screen
/// exactly like one entered by hand.
///
/// Only [MidiDeviceProfile.blockDefinitions] is read, never anything
/// NUX-specific: a second device profile is seeded the same way as long as it
/// fills that in.
///
/// Global parameters like Scene and Pedal are deliberately not seeded as
/// controls - they are live control-surface actions, not something dialled in
/// and saved into a patch.
class MidiDeviceLinkRepository {
  const MidiDeviceLinkRepository(this._dao, this._pedals, this._controls);

  final MidiDeviceLinkDao _dao;
  final PedalRepository _pedals;
  final ControlRepository _controls;

  /// The pedal linked to [deviceProfileId], or null when none is.
  Stream<Pedal?> watchLinkedPedal(String deviceProfileId) {
    return _dao.watchLink(deviceProfileId).asyncExpand((link) {
      if (link == null) {
        return Stream<Pedal?>.value(null);
      }
      return _pedals.watchPedal(link.pedalId);
    });
  }

  /// Creates the unit, its blocks and their controls, links them to
  /// [profile], and returns the unit's pedal id.
  ///
  /// Refuses to run twice: a second call would create a second copy of the
  /// same gear rather than finding the first.
  Future<int> createLinkedGear(MidiDeviceProfile profile) async {
    final existing = await _dao.findLink(profile.id);
    if (existing != null) {
      throw AppFailure('${profile.displayName} is already linked to a pedal.');
    }

    final unitId = await _pedals.createPedal(
      PedalDraft(
        name: profile.displayName,
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );

    for (final block in profile.blockDefinitions) {
      final blockId = await _pedals.createPedal(
        PedalDraft(
          name: block.label,
          type: PedalType.digital,
          category: PedalCategory.other,
        ).insideUnit(unitId),
      );

      // A block with only one possible model - Noise Gate, on the MG-30 -
      // has nothing to select, and a control whose maximum cannot exceed its
      // minimum is refused by the same validation a hand-entered one goes
      // through.
      if (block.modelCount > 1) {
        await _controls.createControl(
          blockId,
          ControlDraft(
            name: block.modelParameterName,
            type: ControlType.numeric,
            minValue: 1,
            maxValue: block.modelCount.toDouble(),
            step: 1,
          ),
        );
      }

      for (final knobName in block.knobParameterNames) {
        final definition = profile.parameterDefinitions.firstWhere(
          (candidate) => candidate.name == knobName,
        );
        final isPercentage = definition.min == 0 && definition.max == 100;
        await _controls.createControl(
          blockId,
          ControlDraft(
            name: knobName,
            type: isPercentage ? ControlType.percentage : ControlType.numeric,
            minValue: definition.min,
            maxValue: definition.max,
            step: isPercentage ? null : 1,
          ),
        );
      }
    }

    await _dao.insertLink(
      MidiDeviceLinksCompanion.insert(
        pedalId: unitId,
        deviceProfileId: profile.id,
        linkedAt: DateTime.now(),
      ),
    );

    return unitId;
  }
}
