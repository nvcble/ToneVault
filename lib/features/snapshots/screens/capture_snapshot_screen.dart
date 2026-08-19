import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedalboards/providers/pedalboard_providers.dart';
import '../providers/snapshot_providers.dart';
import '../widgets/capture_snapshot_form.dart';

/// Records a rig as it stands right now.
///
/// The chain is read here rather than in the form so the form can be given a
/// plain list, and so an empty rig is answered before anything is asked of the
/// user.
class CaptureSnapshotScreen extends ConsumerStatefulWidget {
  const CaptureSnapshotScreen({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  ConsumerState<CaptureSnapshotScreen> createState() =>
      _CaptureSnapshotScreenState();
}

class _CaptureSnapshotScreenState extends ConsumerState<CaptureSnapshotScreen> {
  bool _isSaving = false;

  Future<void> _capture(SnapshotCapture capture) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(rigSnapshotRepositoryProvider)
          .captureSnapshot(
            widget.pedalboardId,
            capture.draft,
            configurationChoices: capture.configurationChoices,
          );
      if (mounted) {
        context.go(Routes.rigDetail(widget.pedalboardId));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take snapshot')),
      body: ref
          .watch(rigChainProvider(widget.pedalboardId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not read the rig',
              message: failureMessage(error),
            ),
            data: (chain) => chain.isEmpty
                ? const EmptyState(
                    icon: Icons.linear_scale,
                    title: 'Nothing on this rig to record',
                    message:
                        'Add the pedals you played, then a snapshot can say '
                        'where each of them was set.',
                  )
                : CaptureSnapshotForm(
                    chain: chain,
                    isSaving: _isSaving,
                    onSubmit: _capture,
                  ),
          ),
    );
  }
}
