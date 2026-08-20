import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../backup/providers/backup_providers.dart';

/// Writes the whole vault to a file and hands it to the share sheet.
///
/// Where it ends up is the user's business - Drive, email, a cable to a laptop -
/// so there is nothing to report on success beyond the sheet appearing. The
/// sheet is its own answer.
class BackupTile extends ConsumerStatefulWidget {
  const BackupTile({super.key});

  @override
  ConsumerState<BackupTile> createState() => _BackupTileState();
}

class _BackupTileState extends ConsumerState<BackupTile> {
  bool _isWorking = false;

  Future<void> _backUp() async {
    setState(() => _isWorking = true);

    try {
      final export = await ref.read(backupRepositoryProvider).exportVault();
      await ref.read(backupSenderProvider)(
        export.contents,
        fileName: export.fileName,
      );
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.backup_outlined),
      title: const Text('Back up everything'),
      subtitle: const Text(
        'Save your pedals, settings, history, rigs and snapshots to a file you '
        'keep.',
      ),
      trailing: _isWorking
          ? const SizedBox.square(
              dimension: AppSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _isWorking ? null : _backUp,
    );
  }
}
