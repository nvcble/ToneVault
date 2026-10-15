import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/midi/midi_connection_state.dart';
import '../../../../core/midi/midi_device_profile.dart';
import '../../../../core/midi/midi_device_registry.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/failure_snack_bar.dart';
import '../../../../shared/widgets/orientation_lock.dart';
import '../../../../shared/widgets/paged_grid.dart';
import '../../providers/midi_connection_controller.dart';
import '../data/ampero_mini_patch_layout.dart';
import '../data/ampero_mini_refusals.dart';
import '../providers/hotone_ampero_mini_data_providers.dart';
import '../providers/hotone_ampero_mini_patch_selection_providers.dart';
import '../widgets/ampero_mini_bank_select_sheet.dart';
import '../widgets/ampero_mini_diagnostics_menu.dart';
import '../widgets/ampero_mini_patch_grid_tile.dart';
import '../widgets/ampero_mini_patch_search_sheet.dart';
import '../widgets/ampero_mini_read_limitation_notice.dart';
import '../widgets/ampero_mini_selection_summary.dart';

/// The Ampero Mini's own patch browser - a paged grid of the pedal's 198
/// patches, where a single tap pre-selects and a double tap activates.
///
/// Laid out like `MidiControlScreen`, the MG-30's own landing page: held
/// upright, never scrolled, with twelve big slots a page taking whatever
/// height is left over. It has no scene row, because this pedal has no scenes
/// at all - see `hotoneAmperoMiniCapabilities`.
///
/// The layout is all the two pages share. Built independently of
/// `MidiPatchBrowserScreen`/`MidiPatchesScreen`, which assume a device already
/// linked as gear, and of anything NUX: the paging is the generic [PagedGrid]
/// and the patch numbering is this pedal's own.
class HotoneAmperoMiniPatchListScreen extends ConsumerStatefulWidget {
  const HotoneAmperoMiniPatchListScreen({super.key});

  static const deviceProfileId = 'hotone_ampero_mini';

  /// Slots a page - [PagedGrid]'s own three by four, named here only so the
  /// grid can open on the page holding the pre-selected patch.
  static const _perPage = 12;

  @override
  ConsumerState<HotoneAmperoMiniPatchListScreen> createState() =>
      _HotoneAmperoMiniPatchListScreenState();
}

class _HotoneAmperoMiniPatchListScreenState
    extends ConsumerState<HotoneAmperoMiniPatchListScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = MidiDeviceRegistry.findById(
      HotoneAmperoMiniPatchListScreen.deviceProfileId,
    );
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final connected =
        ref.watch(midiConnectionProvider(profile.id)).state ==
        MidiConnectionState.connected;
    final patchesAsync = ref.watch(hotoneAmperoMiniPatchesProvider);
    final byNumber = <int, HotoneAmperoMiniPatch>{
      for (final row
          in patchesAsync.valueOrNull ?? const <HotoneAmperoMiniPatch>[])
        row.patchNumber: row,
    };

    final preSelected = ref.watch(
      hotoneAmperoMiniPreSelectedPatchNumberProvider,
    );
    // What this app last sent is the only fact available about the device: the
    // pedal has no confirmed way to report the patch it loaded, so nothing
    // here may override the user's own choice.
    final sent = ref.watch(hotoneAmperoMiniActivePatchNumberProvider);

    return OrientationLock(
      orientations: const [DeviceOrientation.portraitUp],
      child: Scaffold(
        appBar: AppBar(
          title: Text(profile.displayName),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Find a patch',
              onPressed: () => _search(byNumber),
            ),
            AmperoMiniDiagnosticsMenu(profileId: profile.id),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // One short line, as on the MG-30's page: a sentence long
                // enough to wrap costs two rows of patch slots on a small
                // phone. What a double tap does while disconnected says the
                // rest, in a snack bar, at the moment it matters.
                if (!connected) const Text('Not connected.'),
                AmperoMiniSelectionSummary(
                  preSelectedNumber: preSelected,
                  sentNumber: sent,
                ),
                const SizedBox(height: AppSpacing.sm),
                const AmperoMiniReadLimitationNotice(),
                const SizedBox(height: AppSpacing.sm),
                // The grid shares out the height nothing else has claimed, so
                // the page holds twelve slots however tall the phone is and
                // never scrolls.
                Expanded(
                  child: PagedGrid(
                    itemCount: amperoMiniPatchCount,
                    padding: EdgeInsets.zero,
                    // Opens where the selection is, as the MG-30's grid does.
                    selectedPage:
                        preSelected ~/ HotoneAmperoMiniPatchListScreen._perPage,
                    itemBuilder: (context, number) => AmperoMiniPatchGridTile(
                      patchNumber: number,
                      name: byNumber[number]?.name,
                      preSelected: number == preSelected,
                      active: number == sent,
                      onTap: () => _preSelect(number),
                      onDoubleTap: _doubleTapAction(number, connected, profile),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Searching only pre-selects: the grid then opens on the page holding that
  /// patch, and activating it is still the user's own double tap.
  Future<void> _search(Map<int, HotoneAmperoMiniPatch> byNumber) async {
    final number = await AmperoMiniPatchSearchSheet.show(
      context,
      names: {
        for (final row in byNumber.values)
          if (row.name != null) row.patchNumber: row.name!,
      },
    );
    if (number != null) {
      _preSelect(number);
    }
  }

  void _preSelect(int number) =>
      ref.read(hotoneAmperoMiniPreSelectedPatchNumberProvider.notifier).state =
          number;

  /// A user patch is activated; a factory patch instead opens the experimental
  /// Bank Select attempts, since no confirmed way to select one exists. Both
  /// need a connection first.
  VoidCallback _doubleTapAction(
    int number,
    bool connected,
    MidiDeviceProfile profile,
  ) => switch ((connected, amperoMiniIsSelectableOverMidi(number))) {
    (false, _) => () => showFailureSnackBar(
      context,
      amperoMiniNotConnectedFailure,
    ),
    (true, false) => () => AmperoMiniBankSelectSheet.show(
      context,
      profile: profile,
      patchNumber: number,
    ),
    (true, true) => () => _activate(number),
  };

  Future<void> _activate(int number) async {
    final profile = MidiDeviceRegistry.findById(
      HotoneAmperoMiniPatchListScreen.deviceProfileId,
    )!;
    try {
      await ref
          .read(hotoneAmperoMiniMidiServiceProvider)
          .selectPatch(profile: profile, patchNumber: number);
      ref.read(hotoneAmperoMiniActivePatchNumberProvider.notifier).state =
          number;
      ref.read(hotoneAmperoMiniPreSelectedPatchNumberProvider.notifier).state =
          number;
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    }
  }
}
