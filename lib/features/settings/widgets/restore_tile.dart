import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../backup/data/backup_document.dart';
import '../../backup/data/backup_summary.dart';
import '../../backup/providers/backup_providers.dart';

/// Reads a backup file and, once the user agrees, replaces the vault with it.
///
/// The file is read and described before the question is asked, so the user is
/// agreeing to a particular backup - taken on a day, holding so much - rather
/// than to the idea of restoring one.
class RestoreTile extends ConsumerStatefulWidget {
  const RestoreTile({super.key});

  @override
  ConsumerState<RestoreTile> createState() => _RestoreTileState();
}

class _RestoreTileState extends ConsumerState<RestoreTile> {
  bool _isWorking = false;

  Future<void> _restore() async {
    try {
      final file = await ref.read(backupChooserProvider)();
      // Backed out of the picker: not a failure, and nothing to say about it.
      if (file == null || !mounted) {
        return;
      }

      final repository = ref.read(backupRepositoryProvider);
      final backup = repository.readBackup(file);

      if (!await _confirm(backup) || !mounted) {
        return;
      }

      // Only now is there anything to wait for. The picker and the question are
      // the user's own time, and a spinner behind a modal says nothing.
      setState(() => _isWorking = true);
      await repository.restoreVault(backup);
      if (mounted) {
        _report(describeRestored(backup.rows));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted && _isWorking) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<bool> _confirm(VaultBackup backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace everything?'),
        content: Text(
          '${describeBackup(backup)}\n\n'
          'Everything in ToneVault now is replaced by what that file holds. '
          'Anything you have added since it was taken goes with it, and this '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Replace everything'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restore_page_outlined),
      title: const Text('Restore from a backup'),
      subtitle: const Text(
        'Replace everything in ToneVault with what is in a backup file.',
      ),
      trailing: _isWorking
          ? const SizedBox.square(
              dimension: AppSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _isWorking ? null : _restore,
    );
  }
}
