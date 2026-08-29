import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/curriculum_transfer_providers.dart';

/// Writes the whole curriculum to a file and hands it to the share sheet.
///
/// Where it goes is the user's business - a message to a student, a folder on a
/// laptop - so there is nothing to report on success beyond the sheet appearing. The
/// sheet is its own answer.
class CurriculumExportTile extends ConsumerStatefulWidget {
  const CurriculumExportTile({super.key});

  @override
  ConsumerState<CurriculumExportTile> createState() =>
      _CurriculumExportTileState();
}

class _CurriculumExportTileState extends ConsumerState<CurriculumExportTile> {
  bool _isWorking = false;

  Future<void> _export() async {
    setState(() => _isWorking = true);

    try {
      final export = await ref
          .read(curriculumExporterProvider)
          .exportEverything();
      await ref.read(curriculumSenderProvider)(
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
      leading: const Icon(Icons.upload_file_outlined),
      title: const Text('Export the curriculum'),
      subtitle: const Text(
        'Save every course and lesson to a file you can pass on.',
      ),
      trailing: _isWorking
          ? const SizedBox.square(
              dimension: AppSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _isWorking ? null : _export,
    );
  }
}
