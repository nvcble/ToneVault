import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/segmented_switch.dart';
import '../../patches/providers/patch_providers.dart';
import '../data/midi_patch_sort.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/midi_patch_list_tile.dart';

/// The linked unit's patches - or, before one is linked, the way to add it.
class MidiPatchesScreen extends ConsumerWidget {
  const MidiPatchesScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final pedalAsync = ref.watch(linkedPedalProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Import from device',
            onPressed: () => context.push(Routes.midiPresetImport(profileId)),
          ),
        ],
      ),
      body: pedalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this device\'s gear',
          message: failureMessage(error),
        ),
        data: (pedal) => pedal == null
            ? _LinkGearPrompt(profile: profile)
            : _PatchList(
                profileId: profileId,
                profile: profile,
                unitId: pedal.id,
              ),
      ),
    );
  }
}

class _LinkGearPrompt extends ConsumerWidget {
  const _LinkGearPrompt({required this.profile});

  final MidiDeviceProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyState(
      icon: Icons.link_off,
      title: '${profile.displayName} is not gear yet',
      message:
          'Add it once, and its patches and scenes live alongside every '
          'other pedal you track.',
      action: FilledButton(
        onPressed: () async {
          try {
            await ref
                .read(midiDeviceLinkRepositoryProvider)
                .createLinkedGear(profile);
          } catch (error) {
            if (context.mounted) showFailureSnackBar(context, error);
          }
        },
        child: Text('Add ${profile.displayName} as gear'),
      ),
    );
  }
}

/// The patches themselves, in whichever order the user picked.
class _PatchList extends ConsumerStatefulWidget {
  const _PatchList({
    required this.profileId,
    required this.profile,
    required this.unitId,
  });

  final String profileId;
  final MidiDeviceProfile profile;
  final int unitId;

  @override
  ConsumerState<_PatchList> createState() => _PatchListState();
}

class _PatchListState extends ConsumerState<_PatchList> {
  MidiPatchSort _sort = MidiPatchSort.name;

  @override
  Widget build(BuildContext context) {
    final patchesAsync = ref.watch(patchListProvider(widget.unitId));

    return patchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load patches',
        message: failureMessage(error),
      ),
      data: (patches) {
        if (patches.isEmpty) {
          return const EmptyState(
            icon: Icons.list_alt,
            title: 'No patches yet',
            message: 'Add patches for this unit from the Pedals tab.',
          );
        }

        // Read once for the whole list rather than per row: sorting by number
        // needs every patch's number at the same time, not one at a time.
        final numbered =
            ref.watch(numberedPatchesProvider(widget.unitId)).valueOrNull ??
            const <NumberedPatch>[];
        final numbers = {
          for (final row in numbered) row.patch.id: row.programNumber,
        };
        final sorted = sortMidiPatches(patches, sort: _sort, numbers: numbers);

        final canLoad =
            ref.watch(midiConnectionProvider(widget.profileId)).state ==
                MidiConnectionState.connected &&
            ref.watch(experimentalProgramChangeEnabledProvider);

        return SegmentedSwitch(
          firstLabel: MidiPatchSort.name.label,
          secondLabel: MidiPatchSort.programNumber.label,
          showingSecond: _sort == MidiPatchSort.programNumber,
          onChanged: (byNumber) => setState(
            () => _sort = byNumber
                ? MidiPatchSort.programNumber
                : MidiPatchSort.name,
          ),
          child: ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) =>
                _tile(sorted[index], numbers, canLoad),
          ),
        );
      },
    );
  }

  Widget _tile(Patch patch, Map<int, int> numbers, bool canLoad) {
    final programNumber = numbers[patch.id];
    return MidiPatchListTile(
      name: patch.name,
      programNumber: programNumber,
      onTap: () =>
          context.push(Routes.midiPatchScenes(widget.profileId, patch.id)),
      onNumberChanged: (number) => _setNumber(patch.id, number),
      onLoad: canLoad && programNumber != null
          ? () => _load(patch.id, programNumber)
          : null,
    );
  }

  Future<void> _setNumber(int patchId, int number) async {
    try {
      await ref
          .read(midiPatchProgramRepositoryProvider)
          .setNumber(patchId: patchId, programNumber: number);
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    }
  }

  Future<void> _load(int patchId, int programNumber) async {
    try {
      final override = await ref.read(
        patchSelectionOverrideProvider(widget.profileId).future,
      );
      await ref
          .read(patchControlControllerProvider)
          .loadPatch(
            profile: widget.profile,
            patchNumber: programNumber,
            patchId: patchId,
            override: override,
            experimentalEnabled: true,
          );
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    }
  }
}
