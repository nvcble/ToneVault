import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/widgets/control_form.dart';

/// Drives a [ControlForm] and captures what it submits.
///
/// The form takes its data as plain arguments and hands back a draft, so these
/// tests need no providers and no database at all.
class ControlFormHarness {
  ControlDraft? submitted;

  void reset() => submitted = null;

  Future<void> pumpForm(
    WidgetTester tester, {
    ControlDraft? initialDraft,
    bool isSaving = false,
  }) async {
    // The form is taller than the default 800x600 test surface. A tall window
    // keeps every field on screen, so taps do not depend on scroll position.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ControlForm(
            submitLabel: initialDraft == null ? 'Add control' : 'Save changes',
            initialDraft: initialDraft,
            isSaving: isSaving,
            onSubmit: (draft) => submitted = draft,
          ),
        ),
      ),
    );

    // A saving form spins forever, which pumpAndSettle would wait out.
    if (isSaving) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  Future<void> pickType(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButtonFormField<ControlType>));
    await tester.pumpAndSettle();
    // The closed field shows the chosen text too, so the menu entry is the last
    // match while the overlay is open.
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String label, String text) async {
    await tester.enterText(find.widgetWithText(TextFormField, label), text);
    await tester.pumpAndSettle();
  }

  /// Types into one row of the positions editor, found by its hint.
  Future<void> enterPosition(
    WidgetTester tester,
    int position,
    String text,
  ) async {
    await tester.enterText(
      find.ancestor(
        of: find.text('Position $position'),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  String? fieldText(WidgetTester tester, String label) {
    return tester
        .widget<TextFormField>(find.widgetWithText(TextFormField, label))
        .controller
        ?.text;
  }
}
