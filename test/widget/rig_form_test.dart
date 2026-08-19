import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedalboards/widgets/rig_form.dart';

/// The rig fields on their own: what they hand back, and what they refuse to
/// submit.
void main() {
  PedalboardDraft? submitted;

  setUp(() => submitted = null);

  Future<void> pumpForm(
    WidgetTester tester, {
    PedalboardDraft? initialDraft,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RigForm(
            submitLabel: 'Add rig',
            initialDraft: initialDraft,
            onSubmit: (draft) => submitted = draft,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Add rig'));
    await tester.pumpAndSettle();
  }

  testWidgets('hands back a draft built from the entered fields', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Hybrid Worship Rig',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'MG-30 into the desk',
    );
    await submit(tester);

    expect(submitted?.name, 'Hybrid Worship Rig');
    expect(submitted?.description, 'MG-30 into the desk');
  });

  testWidgets('asks for a name rather than submitting an unnamed rig', (
    tester,
  ) async {
    await pumpForm(tester);

    await submit(tester);

    expect(find.text('Enter a rig name.'), findsOne);
    expect(submitted, isNull);
  });

  testWidgets('a description on its own is not a rig', (tester) async {
    await pumpForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'the one with the wah',
    );
    await submit(tester);

    expect(submitted, isNull);
  });

  testWidgets('starts an edit from the existing values', (tester) async {
    await pumpForm(
      tester,
      initialDraft: const PedalboardDraft(
        name: 'Home Practice',
        description: 'amp on the desk',
      ),
    );

    expect(find.text('Home Practice'), findsOne);
    expect(find.text('amp on the desk'), findsOne);
  });

  testWidgets('cannot be submitted twice while a save is in flight', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RigForm(
            submitLabel: 'Add rig',
            isSaving: true,
            onSubmit: (draft) => submitted = draft,
          ),
        ),
      ),
    );
    // A single frame, not pumpAndSettle: the spinner never stops turning.
    await tester.pump();

    // The label is replaced by a spinner, so the button is found by type.
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOne);
  });
}
