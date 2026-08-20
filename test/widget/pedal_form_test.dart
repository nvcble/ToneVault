import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/widgets/pedal_form.dart';

void main() {
  PedalDraft? submitted;

  setUp(() => submitted = null);

  Future<void> pumpForm(WidgetTester tester, {PedalDraft? initialDraft}) async {
    // The form is taller than the default 800x600 test surface. A tall window
    // keeps every field on screen, so taps do not depend on scroll position.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PedalForm(
            submitLabel: 'Add pedal',
            initialDraft: initialDraft,
            onSubmit: (draft) => submitted = draft,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pick<T extends Enum>(WidgetTester tester, String option) async {
    await tester.tap(find.byType(DropdownButtonFormField<T>));
    await tester.pumpAndSettle();
    // The closed field shows the chosen text too, so the menu entry is the last
    // match while the overlay is open.
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Add pedal'));
    await tester.pumpAndSettle();
  }

  testWidgets('hands back a draft built from the entered fields', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Mooer Yellow Comp',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Brand'),
      'Mooer',
    );
    await pick<PedalType>(tester, 'Analog');
    await pick<PedalCategory>(tester, 'Compressor');
    await submit(tester);

    expect(submitted?.name, 'Mooer Yellow Comp');
    expect(submitted?.brand, 'Mooer');
    expect(submitted?.type, PedalType.analog);
    expect(submitted?.category, PedalCategory.compressor);
    expect(submitted?.status, PedalStatus.active);
    expect(submitted?.purchaseDate, isNull);
  });

  testWidgets('reports a missing name instead of submitting', (tester) async {
    await pumpForm(tester);

    await pick<PedalType>(tester, 'Analog');
    await pick<PedalCategory>(tester, 'Compressor');
    await submit(tester);

    expect(find.text('Enter a pedal name.'), findsOne);
    expect(submitted, isNull);
  });

  testWidgets('asks for the type and category rather than guessing them', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Valeton EP1',
    );
    await submit(tester);

    // Not "analog or digital": multi-effects is a type too.
    expect(find.text('Pick how this pedal makes its sound.'), findsOne);
    expect(find.text('Pick what this pedal does.'), findsOne);
    expect(submitted, isNull);
  });

  testWidgets('starts an edit from the existing values', (tester) async {
    await pumpForm(
      tester,
      initialDraft: PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
        brand: 'Caline',
        status: PedalStatus.backup,
        purchaseDate: DateTime.utc(2024, 1, 2),
        notes: 'Always on.',
      ),
    );

    expect(find.text('Caline PureSky'), findsOne);
    expect(find.text('Caline'), findsOne);
    expect(find.text('Overdrive'), findsOne);
    expect(find.text('Backup'), findsOne);
    expect(find.text('2024-01-02'), findsOne);
    expect(find.text('Always on.'), findsOne);

    // Submitting an untouched form gives back what it was handed.
    await submit(tester);
    expect(submitted?.name, 'Caline PureSky');
    expect(submitted?.status, PedalStatus.backup);
    expect(submitted?.purchaseDate, DateTime.utc(2024, 1, 2));
  });
}
