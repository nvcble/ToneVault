import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../snapshots/widgets/rig_snapshots_view.dart';
import '../providers/pedalboard_providers.dart';
import '../providers/rig_editor.dart';
import '../widgets/rig_options_menu.dart';
import '../widgets/rig_overview.dart';
import '../widgets/signal_chain_view.dart';

/// One rig: what it is, what is on it, and how it stood on days gone by.
///
/// The chain gets a tab to itself rather than sharing the screen with the
/// description and dates. It is the part of a rig that is worked on, and it needs
/// the whole height to be dragged around in - on a tablet, the whole width.
class RigScreen extends ConsumerWidget {
  const RigScreen({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedalboardValue = ref.watch(pedalboardProvider(pedalboardId));
    final pedalboard = pedalboardValue.valueOrNull;
    // Already watched by the chain tab, so this costs no second query. Only the
    // length is wanted here: whether there is anything to clear.
    final chain = ref.watch(signalChainProvider(pedalboardId)).valueOrNull;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(pedalboard?.name ?? 'Rig'),
          actions: pedalboard == null
              ? null
              : [
                  RigOptionsMenu(
                    blockCount: chain?.length ?? 0,
                    onSelected: (option) =>
                        _act(context, ref, pedalboard, option),
                  ),
                ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Signal Chain'),
              Tab(text: 'Snapshots'),
            ],
          ),
        ),
        body: pedalboardValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this rig',
            message: failureMessage(error),
          ),
          data: (pedalboard) => pedalboard == null
              ? const EmptyState(
                  icon: Icons.help_outline,
                  title: 'That rig no longer exists',
                  message: 'It may have been deleted on another screen.',
                )
              : TabBarView(
                  children: [
                    RigOverview(pedalboard: pedalboard),
                    SignalChainView(pedalboardId: pedalboardId),
                    RigSnapshotsView(pedalboardId: pedalboardId),
                  ],
                ),
        ),
      ),
    );
  }

  /// Carries out what the options menu was asked for.
  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    Pedalboard pedalboard,
    RigOption option,
  ) async {
    switch (option) {
      case RigOption.edit:
        context.go(Routes.rigEdit(pedalboardId));
      case RigOption.saveSnapshot:
        // The snapshot screens already ask what every pedal was set to, so this
        // is a way in rather than a second way of taking one.
        context.go(Routes.snapshotNew(pedalboardId));
      case RigOption.clearChain:
        await _confirmClear(context, ref, pedalboard.name);
      case RigOption.delete:
        await _confirmDelete(context, ref, pedalboard.name);
    }
  }

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Clear chain?',
      message:
          'Every block comes off $name, along with how they were wired. The '
          'pedals themselves are not touched, and there is no undo.',
      confirmLabel: 'Clear',
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(signalChainRepositoryProvider).clearChain(pedalboardId);
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Delete rig?',
      message:
          '$name goes, along with the order of the pedals on it. The pedals '
          'themselves are not touched.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(rigEditorProvider).delete(pedalboardId);
      if (context.mounted) {
        context.go(Routes.rigs);
      }
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  /// Asks before something that cannot be tapped again to undo.
  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            // Dialogs are Navigator routes rather than go_router pages, so they
            // are dismissed through the Navigator.
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
