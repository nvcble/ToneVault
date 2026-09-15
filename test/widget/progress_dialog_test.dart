import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/shared/widgets/progress_dialog.dart';

import '../support/themed_app.dart';

void main() {
  late Completer<String> job;
  late void Function(int completed, int total) report;
  Object? thrown;
  String? result;

  /// A screen with one button that runs [job] behind the dialog.
  ///
  /// The completer is created here, inside the test body, and deliberately not
  /// in a `setUp`: that runs outside the fake-async zone the test body runs in,
  /// so completing it would schedule the job's continuation in the root zone
  /// where `pump` never flushes it - and the job would look like it never ended.
  Future<void> pumpAndStart(WidgetTester tester) async {
    job = Completer<String>();
    thrown = null;
    result = null;

    await tester.pumpWidget(
      themedApp(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              try {
                result = await runWithProgressDialog<String>(
                  context,
                  title: 'Capturing Presets',
                  label: (progress) => progress.total == 0
                      ? 'Starting...'
                      : 'Reading preset ${progress.completed} of ${progress.total}...',
                  job: (reportProgress) {
                    report = reportProgress;
                    return job.future;
                  },
                );
              } catch (error) {
                thrown = error;
              }
            },
            child: const Text('Start'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Start'));
    await tester.pump();
  }

  testWidgets('shows the job title, its progress and why not to leave', (tester) async {
    await pumpAndStart(tester);

    expect(find.text('Capturing Presets'), findsOneWidget);
    expect(find.text('Starting...'), findsOneWidget);
    expect(find.text(ProgressDialog.warning), findsOneWidget);
    // Indeterminate until the job says how much work there is, rather than an
    // empty bar that reads as "nothing has happened".
    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      isNull,
    );

    report(32, 128);
    await tester.pump();

    expect(find.text('Reading preset 32 of 128...'), findsOneWidget);
    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      0.25,
    );

    job.complete('done');
    await tester.pumpAndSettle();

    expect(find.text('Capturing Presets'), findsNothing);
    expect(result, 'done');
  });

  testWidgets('cannot be dismissed while the job is still running', (tester) async {
    await pumpAndStart(tester);
    // Determinate before any pumpAndSettle: an indeterminate progress bar
    // animates forever, so the tree never settles while one is on screen.
    report(1, 2);

    // Tapping outside a dialog normally closes it; a half-finished run of reads
    // is exactly what the user must not be able to walk away from by accident.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Capturing Presets'), findsOneWidget);

    job.complete('done');
    await tester.pumpAndSettle();

    expect(find.text('Capturing Presets'), findsNothing);
  });

  testWidgets('closes and rethrows when the job fails', (tester) async {
    await pumpAndStart(tester);
    report(1, 2);

    job.completeError(StateError('no device'));
    await tester.pumpAndSettle();

    expect(find.text('Capturing Presets'), findsNothing);
    expect(thrown, isStateError);
    expect(result, isNull);
  });
}
