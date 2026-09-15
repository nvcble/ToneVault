import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// How far through a long job [ProgressDialog] is reporting.
class JobProgress {
  const JobProgress({this.completed = 0, this.total = 0});

  final int completed;
  final int total;

  /// Null until the job says how much work there is, which shows an
  /// indeterminate bar rather than a misleading empty one.
  double? get fraction => total == 0 ? null : completed / total;
}

/// A modal progress dialog for a job the user must not interrupt.
///
/// Cannot be dismissed - no barrier tap, no back gesture - because the jobs
/// this is for talk to hardware one step at a time and leave half their work
/// done if they are abandoned partway.
class ProgressDialog extends StatelessWidget {
  const ProgressDialog({
    required this.title,
    required this.progress,
    required this.label,
    super.key,
  });

  final String title;
  final ValueListenable<JobProgress> progress;

  /// What to say about the current step, e.g. "Reading preset 12 of 128".
  final String Function(JobProgress progress) label;

  /// Why leaving matters, in the same words wherever this dialog is used.
  static const String warning =
      'Keep ToneVault open and leave your device connected until this '
      'finishes. Closing the app or unplugging the cable will interrupt it.';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(title),
        content: ValueListenableBuilder<JobProgress>(
          valueListenable: progress,
          builder: (context, value, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: value.fraction),
              const SizedBox(height: AppSpacing.md),
              Text(label(value)),
              const SizedBox(height: AppSpacing.md),
              Text(warning, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Runs [job] behind a [ProgressDialog], closing it however [job] ends.
///
/// [job] is handed a `report` callback to call as it goes. Returns whatever
/// [job] returned, or rethrows what it threw, so a caller handles the outcome
/// exactly as it would without a dialog in the way.
Future<T> runWithProgressDialog<T>(
  BuildContext context, {
  required String title,
  required String Function(JobProgress progress) label,
  required Future<T> Function(void Function(int completed, int total) report) job,
}) async {
  final progress = ValueNotifier(const JobProgress());
  // Captured up front: the dialog is closed in a `finally`, by which point
  // [context] may be gone and cannot be asked for its navigator.
  final navigator = Navigator.of(context);
  final closed = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProgressDialog(title: title, progress: progress, label: label),
  );

  try {
    return await job(
      (completed, total) => progress.value = JobProgress(completed: completed, total: total),
    );
  } finally {
    navigator.pop();
    // The dialog is still on screen for the length of its exit animation, and
    // its ValueListenableBuilder unsubscribes as it goes - disposing before
    // then throws "used after being disposed" mid-transition.
    await closed;
    progress.dispose();
  }
}
