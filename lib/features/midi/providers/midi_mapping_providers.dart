import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/midi_parameter_override_dao.dart';
import '../../../core/database/daos/midi_patch_selection_settings_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../core/midi/midi_parameter_definition.dart';
import '../../../core/midi/patch_selection_defaults.dart';
import '../data/midi_parameter_mapping_repository.dart';
import '../data/patch_selection_repository.dart';

final Provider<MidiParameterOverrideDao> midiParameterOverrideDaoProvider =
    Provider<MidiParameterOverrideDao>(
      (ref) => MidiParameterOverrideDao(ref.watch(appDatabaseProvider)),
    );

final Provider<MidiPatchSelectionSettingsDao>
midiPatchSelectionSettingsDaoProvider = Provider<MidiPatchSelectionSettingsDao>(
  (ref) => MidiPatchSelectionSettingsDao(ref.watch(appDatabaseProvider)),
);

final Provider<MidiParameterMappingRepository>
midiParameterMappingRepositoryProvider =
    Provider<MidiParameterMappingRepository>(
      (ref) => MidiParameterMappingRepository(
        ref.watch(midiParameterOverrideDaoProvider),
      ),
    );

final Provider<PatchSelectionRepository> patchSelectionRepositoryProvider =
    Provider<PatchSelectionRepository>(
      (ref) => PatchSelectionRepository(
        ref.watch(midiPatchSelectionSettingsDaoProvider),
      ),
    );

/// One device profile's parameters, with any user remapping already applied.
final StreamProviderFamily<List<MidiParameterDefinition>, String>
effectiveParametersProvider =
    StreamProvider.family<List<MidiParameterDefinition>, String>((
      ref,
      deviceProfileId,
    ) {
      final profile = MidiDeviceRegistry.findById(deviceProfileId);
      if (profile == null) {
        return const Stream<List<MidiParameterDefinition>>.empty();
      }
      return ref
          .watch(midiParameterMappingRepositoryProvider)
          .watchEffectiveParameters(profile);
    });

/// The names of one device profile's parameters that have been remapped away
/// from their defaults.
final StreamProviderFamily<Set<String>, String>
overriddenParameterNamesProvider = StreamProvider.family<Set<String>, String>(
  (ref, deviceProfileId) => ref
      .watch(midiParameterMappingRepositoryProvider)
      .watchOverriddenNames(deviceProfileId),
);

/// One device profile's patch-selection override, or null where it uses the
/// device profile's own candidate untouched.
final StreamProviderFamily<PatchSelectionOverride?, String>
patchSelectionOverrideProvider =
    StreamProvider.family<PatchSelectionOverride?, String>(
      (ref, deviceProfileId) => ref
          .watch(patchSelectionRepositoryProvider)
          .watchOverride(deviceProfileId),
    );
