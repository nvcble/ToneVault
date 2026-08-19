import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/configurations/widgets/configuration_form.dart';

/// Naming a configuration. Where the knobs go is set on the configuration's own
/// screen, so this form has two fields and nothing else.
void main() {
  ConfigurationDraft? submitted;

  Future<void> pumpForm(
    WidgetTester tester, {
    ConfigurationDraft? initialDraft,
    bool isSaving = false,
  }) async {
    submitted = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfigurationForm(
            submitLabel: initialDraft == null
                ? 'Add configuration'
                : 'Save changes',
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

  Future<void> enter(WidgetTester tester, String label, String text) async {
    await tester.enterText(find.widgetWithText(TextFormField, label), text);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('hands back a trimmed name and notes', (tester) async {
    await pumpForm(tester);

    await enter(tester, 'Name', '  Worship Lead  ');
    await enter(tester, 'Notes', 'Bridge only');
    await submit(tester);

    expect(submitted?.name, 'Worship Lead');
    expect(submitted?.notes, 'Bridge only');
  });

  testWidgets('treats blank notes as not written', (tester) async {
    await pumpForm(tester);

    await enter(tester, 'Name', 'Clean Boost');
    await enter(tester, 'Notes', '   ');
    await submit(tester);

    expect(submitted?.notes, isNull);
  });

  testWidgets('reports a missing name instead of submitting', (tester) async {
    await pumpForm(tester);

    await submit(tester);

    expect(find.text('Enter a configuration name.'), findsOne);
    expect(submitted, isNull);
  });

  testWidgets('says where a new configuration starts out', (tester) async {
    await pumpForm(tester);

    // Nothing here sets a knob, so the form has to say what will happen.
    expect(find.textContaining('default position'), findsOne);
  });

  testWidgets('opens an existing configuration on its own details', (
    tester,
  ) async {
    await pumpForm(
      tester,
      initialDraft: const ConfigurationDraft(
        name: 'Worship Lead',
        notes: 'Verses',
      ),
    );

    expect(find.text('Worship Lead'), findsOne);
    expect(find.text('Verses'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOne);
    // Renaming does not move any knob, so the note about defaults is out of
    // place here.
    expect(find.textContaining('default position'), findsNothing);
  });

  testWidgets('cannot be submitted twice while a save is in flight', (
    tester,
  ) async {
    await pumpForm(
      tester,
      initialDraft: const ConfigurationDraft(name: 'Worship Lead'),
      isSaving: true,
    );

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOne);
  });
}
