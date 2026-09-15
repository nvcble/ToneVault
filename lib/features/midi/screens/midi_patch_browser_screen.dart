import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../data/midi_patch_recent_repository.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/midi_patch_browser_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/current_patch_card.dart';
import '../widgets/midi_patch_browser_tile.dart';

/// Direct patch selection: search, favorites, recents, and the full list -
/// see Part 2 of the MIDI module brief. One tap sends the patch change and
/// returns to whichever screen opened this one.
class MidiPatchBrowserScreen extends ConsumerWidget {
  const MidiPatchBrowserScreen({required this.profileId, super.key});

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
      appBar: AppBar(title: const Text('Select Patch')),
      body: pedalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this device\'s gear',
          message: failureMessage(error),
        ),
        data: (pedal) => pedal == null
            ? const EmptyState(
                icon: Icons.link_off,
                title: 'Not gear yet',
                message: 'Add this device as gear from its Patches screen first.',
              )
            : _Browser(profileId: profileId, profile: profile, unitId: pedal.id),
      ),
    );
  }
}

class _Browser extends ConsumerStatefulWidget {
  const _Browser({required this.profileId, required this.profile, required this.unitId});

  final String profileId;
  final MidiDeviceProfile profile;
  final int unitId;

  @override
  ConsumerState<_Browser> createState() => _BrowserState();
}

class _BrowserState extends ConsumerState<_Browser> {
  final _searchController = TextEditingController();
  String _query = '';
  int? _selectingPatchId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patchesAsync = ref.watch(numberedPatchesProvider(widget.unitId));

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
            title: 'No numbered patches yet',
            message: 'Give at least one patch a program number on the Patches screen.',
          );
        }

        final favorites = ref.watch(favoritePatchIdsProvider).valueOrNull ?? const {};
        final recentRows = ref.watch(patchRecentsProvider).valueOrNull ?? const [];
        final currentNumber = ref.watch(currentPatchNumberProvider(widget.profileId));
        final current = patches.where((p) => p.programNumber == currentNumber).firstOrNull;

        final query = _query.trim().toLowerCase();
        final filtered = query.isEmpty
            ? patches
            : [
                for (final patch in patches)
                  if (patch.patch.name.toLowerCase().contains(query) ||
                      patch.programNumber.toString().contains(query))
                    patch,
              ];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  CurrentPatchCard(current: current),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search patches...',
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.isNotEmpty
                  ? _list(filtered, favorites)
                  : ListView(
                      children: [
                        if (favorites.isNotEmpty)
                          ..._section(
                            '★ Favorites',
                            patches.where((p) => favorites.contains(p.patch.id)).toList(),
                            favorites,
                          ),
                        if (recentRows.isNotEmpty)
                          ..._section(
                            'Recently Used',
                            recentNumberedPatches(patches, recents: recentRows),
                            favorites,
                          ),
                        const SectionLabel('All Patches'),
                        ...patches.map((patch) => _tile(patch, favorites)),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _list(List<NumberedPatch> patches, Set<int> favorites) {
    return patches.isEmpty
        ? const EmptyState(icon: Icons.search_off, title: 'No patches match')
        : ListView(children: patches.map((patch) => _tile(patch, favorites)).toList());
  }

  List<Widget> _section(String title, List<NumberedPatch> patches, Set<int> favorites) {
    return [SectionLabel(title), ...patches.map((patch) => _tile(patch, favorites))];
  }

  Widget _tile(NumberedPatch patch, Set<int> favorites) {
    return MidiPatchBrowserTile(
      patch: patch,
      isFavorite: favorites.contains(patch.patch.id),
      isSelecting: _selectingPatchId == patch.patch.id,
      onTap: () => _select(patch),
      onToggleFavorite: () => ref
          .read(midiPatchFavoriteRepositoryProvider)
          .setFavorite(patchId: patch.patch.id, isFavorite: !favorites.contains(patch.patch.id)),
    );
  }

  Future<void> _select(NumberedPatch patch) async {
    final connected =
        ref.read(midiConnectionProvider(widget.profileId)).state == MidiConnectionState.connected;
    if (!connected) {
      showFailureSnackBar(context, const AppFailure('MG-30 is not connected.'));
      return;
    }

    setState(() => _selectingPatchId = patch.patch.id);
    try {
      final override = await ref.read(patchSelectionOverrideProvider(widget.profileId).future);
      await ref
          .read(patchControlControllerProvider)
          .loadPatch(
            profile: widget.profile,
            patchNumber: patch.programNumber,
            patchId: patch.patch.id,
            override: override,
            experimentalEnabled: true,
          );
      ref.read(currentPatchNumberProvider(widget.profileId).notifier).state = patch.programNumber;
      if (mounted) await Navigator.of(context).maybePop();
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _selectingPatchId = null);
    }
  }
}
