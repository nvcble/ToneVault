import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/preset_import_service.dart';

/// What one import run did: how many patches arrived, replaced or were left
/// alone, and which ones failed and why.
class PresetImportSummaryView extends StatelessWidget {
  const PresetImportSummaryView({
    required this.summary,
    required this.onDone,
    super.key,
  });

  final PresetImportSummary summary;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Imported ${summary.imported}, overwritten ${summary.overwritten}, '
              'skipped ${summary.skipped}.',
            ),
            if (summary.failures.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('${summary.failures.length} could not be imported:'),
              for (final failure in summary.failures)
                Text('Patch ${failure.programNumber}: ${failure.message}'),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onDone, child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
