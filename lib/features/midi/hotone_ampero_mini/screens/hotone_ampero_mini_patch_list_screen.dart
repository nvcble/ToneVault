import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/midi/midi_connection_state.dart';
import '../../../../core/midi/midi_device_profile.dart';
import '../../../../core/midi/midi_device_registry.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/failure_snack_bar.dart';
import '../../../../shared/widgets/paged_grid.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../providers/midi_connection_controller.dart';
import '../data/ampero_mini_patch_layout.dart';
import '../data/ampero_mini_refusals.dart';
import '../providers/hotone_ampero_mini_data_providers.dart';
import '../providers/hotone_ampero_mini_patch_selection_providers.dart';
import '../widgets/ampero_mini_bank_select_sheet.dart';
import '../widgets/ampero_mini_current_selection_card.dart';
import '../widgets/ampero_mini_diagnostics_menu.dart';
import '../widgets/ampero_mini_patch_grid_tile.dart';
import '../widgets/ampero_mini_read_limitation_notice.dart';

/// The Ampero Mini's own patch browser - a paged grid of the pedal's 198
/// patches, where a single tap pre-selects and a double tap activates.
///
/// Built independently of `MidiPatchBrowserScreen`/`MidiPatchesScreen`: those
/// assume a device already linked as gear, which this device's patch data does
/// not depend on. The paging itself is the generic [PagedGrid].
class HotoneAmperoMiniPatchListScreen extends ConsumerStatefulWidget {
  const HotoneAmperoMiniPatchListScreen({super.key});

  static const deviceProfileId = 'hotone_ampero_mini';

  @override
  ConsumerState<HotoneAmperoMiniPatchListScreen> createState() =>
      _HotoneAmperoMiniPatchListScreenState();
}

class _HotoneAmperoMiniPatchListScreenState
    extends ConsumerState<HotoneAmperoMiniPatchListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final numbers = [
      for (var n = 0; n < amperoMiniPatchCount; n++)
        if (_matches(n, byNumber[n]?.name)) n,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.displayName),
        actions: [AmperoMiniDiagnosticsMenu(profileId: profile.id)],
      ),
      body: ListView(
        children: [
          if (!connected)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Text(
                'Not connected. Patch activation is disabled until it is.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AmperoMiniCurrentSelectionCard(
              preSelectedNumber: preSelected,
              sentNumber: sent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by number or label',
                isDense: true,
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          const SectionLabel('Patches'),
          const AmperoMiniReadLimitationNotice(),
          const SizedBox(height: AppSpacing.sm),
          if (numbers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: EmptyState(
                icon: Icons.search_off,
                title: 'No patch matches that',
              ),
            )
          else
            PagedGrid(
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                final number = numbers[index];
                return AmperoMiniPatchGridTile(
                  patchNumber: number,
                  name: byNumber[number]?.name,
                  preSelected: number == preSelected,
                  active: number == sent,
                  onTap: () => _preSelect(number),
                  onDoubleTap: _doubleTapAction(number, connected, profile),
                );
              },
            ),
        ],
      ),
    );
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

  bool _matches(int number, String? name) {
    if (_query.isEmpty) {
      return true;
    }
    // The pedal's own label ("P02-1"), the raw index ("003"), or a name read
    // off the device - the pedal shows the first, a capture shows the second.
    return amperoMiniPatchLabel(number).toLowerCase().contains(_query) ||
        number.toString().padLeft(3, '0').contains(_query) ||
        (name != null && name.toLowerCase().contains(_query));
  }

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
