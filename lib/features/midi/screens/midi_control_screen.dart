import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../core/midi/midi_parameter_names.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/orientation_lock.dart';
import '../data/midi_connection_snapshot.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/midi_module_menu.dart';
import '../widgets/midi_scene_buttons.dart';
import '../widgets/patch_number_carousel.dart';

/// The scene switched to on first load and after every patch change - see
/// `MidiSceneButtons`.
const _defaultScene = 1;

/// Patch selection and scenes for one device: the page a player lands on and
/// then plays from.
///
/// Held upright ([OrientationLock]) and never scrolled: twelve patch slots
/// take whatever height is left over and the three scenes keep the foot of the
/// page, so everything a player reaches for mid-song is on the one screen.
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
    if (_selectedDefaultScene ||
        snapshot.state != MidiConnectionState.connected) {
      return;
    }
    final profile = MidiDeviceRegistry.findById(widget.profileId);
    if (profile == null) {
      return;
    }
    _selectedDefaultScene = true;
    _sendScene(profile, _defaultScene);
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
    final currentPatch = ref.watch(
      currentPatchNumberProvider(widget.profileId),
    );

    return OrientationLock(
      orientations: const [DeviceOrientation.portraitUp],
      child: Scaffold(
        appBar: AppBar(
          title: Text('${profile.displayName} control'),
          actions: [MidiModuleMenu(profileId: widget.profileId)],
        ),
        body: SafeArea(
          child: Padding(
            // Tight vertically: the height all goes to the grid and the
            // scenes, not to margins.
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!connected) const Text('Not connected.'),
                // The grid sizes its rows to the height it is handed, so it
                // fills what is left rather than overflowing or scrolling.
                Expanded(child: _patchGrid(profile, currentPatch)),
                const SizedBox(height: AppSpacing.sm),
                MidiSceneButtons(
                  selectedScene: ref.watch(
                    currentSceneNumberProvider(widget.profileId),
                  ),
                  onSelect: connected
                      ? (scene) => _sendScene(profile, scene)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _patchGrid(MidiDeviceProfile profile, int currentPatch) {
    return PatchNumberCarousel(
      columns: 3,
      rows: 4,
      selected: currentPatch,
      loaded: ref.watch(currentLoadedPatchNumberProvider(widget.profileId)),
      patchNames: ref.watch(patchNamesByNumberProvider(widget.profileId)),
      onSelected: (number) =>
          ref
                  .read(currentPatchNumberProvider(widget.profileId).notifier)
                  .state =
              number,
      onLoad: (number) => _load(profile, number),
    );
  }

  /// Sends one named parameter, reporting failure to the user rather than to
  /// the caller. True when it went out, which is what the controls that keep a
  /// highlight wait for before moving it.
  Future<bool> _send(
    MidiDeviceProfile profile,
    String parameterName,
    int value,
  ) async {
    try {
      final parameters = await ref.read(
        effectiveParametersProvider(widget.profileId).future,
      );
      await ref
          .read(midiParameterSenderProvider)
          .send(
            profile: profile,
            effectiveParameters: parameters,
            parameterName: parameterName,
            value: value,
          );
      return true;
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
      return false;
    }
  }

  Future<void> _sendScene(MidiDeviceProfile profile, int scene) async {
    if (await _send(profile, MidiParameterNames.scene, scene - 1)) {
      ref.read(currentSceneNumberProvider(widget.profileId).notifier).state =
          scene;
    }
  }

  Future<void> _load(MidiDeviceProfile profile, int patchNumber) async {
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
            experimentalEnabled: ref.read(
              experimentalProgramChangeEnabledProvider,
            ),
          );
      ref.read(currentPatchNumberProvider(widget.profileId).notifier).state =
          patchNumber;
      ref
              .read(currentLoadedPatchNumberProvider(widget.profileId).notifier)
              .state =
          patchNumber;
      // A patch change resets the scene the device has active, so the app
      // follows it back rather than showing one that no longer matches what
      // loaded.
      if (mounted) {
        await _sendScene(profile, _defaultScene);
      }
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    }
  }
}
