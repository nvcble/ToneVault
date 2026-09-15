import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../data/midi_connection_snapshot.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/midi_module_menu.dart';
import '../widgets/midi_scene_buttons.dart';
import '../widgets/patch_number_carousel.dart';

/// The scene switched to on first load and after every patch change - see
/// `MidiSceneButtons`.
const _defaultScene = 1;

/// Patch selection and Pro Scene switching for one device.
class MidiControlScreen extends ConsumerStatefulWidget {
  const MidiControlScreen({required this.profileId, super.key});

  final String profileId;

  @override
  ConsumerState<MidiControlScreen> createState() => _MidiControlScreenState();
}

class _MidiControlScreenState extends ConsumerState<MidiControlScreen> {
  bool _selectedDefaultScene = false;
  ProviderSubscription<MidiConnectionSnapshot>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    // `listenManual` rather than `ref.listen`: this has to run once for
    // whatever the connection already is when the page opens, not only for a
    // change after that, and only `listenManual`'s subscription exposes the
    // current value outside of build.
    _connectionSubscription = ref.listenManual(
      midiConnectionProvider(widget.profileId),
      (previous, next) => _selectDefaultSceneOnceConnected(next),
    );
    _selectDefaultSceneOnceConnected(_connectionSubscription!.read());
  }

  @override
  void dispose() {
    _connectionSubscription?.close();
    super.dispose();
  }

  void _selectDefaultSceneOnceConnected(MidiConnectionSnapshot snapshot) {
    if (_selectedDefaultScene || snapshot.state != MidiConnectionState.connected) {
      return;
    }
    final profile = MidiDeviceRegistry.findById(widget.profileId);
    if (profile == null) {
      return;
    }
    _selectedDefaultScene = true;
    _sendScene(context, profile, _defaultScene);
  }

  @override
  Widget build(BuildContext context) {
    final profile = MidiDeviceRegistry.findById(widget.profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final connected =
        ref.watch(midiConnectionProvider(widget.profileId)).state ==
        MidiConnectionState.connected;
    final currentPatch = ref.watch(currentPatchNumberProvider(widget.profileId));
    final currentScene = ref.watch(currentSceneNumberProvider(widget.profileId));
    // Names the grid can show alongside a slot's number, for whichever slots
    // this unit's owner has actually given a patch to.
    final unitId = ref.watch(linkedPedalProvider(widget.profileId)).valueOrNull?.id;
    final numbered = unitId == null
        ? const <NumberedPatch>[]
        : ref.watch(numberedPatchesProvider(unitId)).valueOrNull ?? const <NumberedPatch>[];
    final patchNames = {for (final row in numbered) row.programNumber: row.patch.name};

    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.displayName} control'),
        actions: [MidiModuleMenu(profileId: widget.profileId)],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Select Patch'),
              onPressed: () => context.push(Routes.midiPatchBrowser(widget.profileId)),
            ),
          ),
          const SectionLabel('Patch selection'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: PatchNumberCarousel(
              selected: currentPatch,
              patchNames: patchNames,
              onSelected: (number) =>
                  ref.read(currentPatchNumberProvider(widget.profileId).notifier).state = number,
              onLoad: (number) => _load(context, profile, number),
            ),
          ),
          const SectionLabel('Scenes'),
          if (!connected)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Not connected.'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: MidiSceneButtons(
              selectedScene: currentScene,
              onSelect: connected ? (scene) => _sendScene(context, profile, scene) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load(BuildContext context, MidiDeviceProfile profile, int patchNumber) async {
    // Program numbers run 0-127; stepping past either end does nothing rather
    // than sending a value the wire cannot carry.
    if (patchNumber < 0 || patchNumber > 127) {
      return;
    }
    try {
      final override = await ref.read(
        patchSelectionOverrideProvider(widget.profileId).future,
      );
      await ref
          .read(patchControlControllerProvider)
          .loadPatch(
            profile: profile,
            patchNumber: patchNumber,
            override: override,
            experimentalEnabled: ref.read(experimentalProgramChangeEnabledProvider),
          );
      ref.read(currentPatchNumberProvider(widget.profileId).notifier).state = patchNumber;
      // A patch change resets which scene is active on the device itself,
      // so the app follows it back to the same default rather than showing
      // a scene that no longer matches what actually loaded.
      if (context.mounted) await _sendScene(context, profile, _defaultScene);
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }

  Future<void> _sendScene(BuildContext context, MidiDeviceProfile profile, int scene) async {
    try {
      final parameters = await ref.read(
        effectiveParametersProvider(widget.profileId).future,
      );
      await ref
          .read(midiParameterSenderProvider)
          .send(
            profile: profile,
            effectiveParameters: parameters,
            parameterName: 'Scene',
            value: scene - 1,
          );
      ref.read(currentSceneNumberProvider(widget.profileId).notifier).state = scene;
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }
}
