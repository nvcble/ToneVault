import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/signal_block_draft.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_block_form.dart';

/// What the block form hands back, and what it will not hand back at all.
///
/// The saving itself is signal_chain_test.dart's job in test/database.
void main() {
  SignalBlockDraft? submitted;

  setUp(() => submitted = null);

  Future<void> pumpForm(
    WidgetTester tester, {
    SignalBlockDraft initialDraft = const SignalBlockDraft(
      blockType: SignalBlockType.overdrive,
    ),
    bool isSaving = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignalBlockForm(
            initialDraft: initialDraft,
            isSaving: isSaving,
            onSubmit: (draft) => submitted = draft,
          ),
        ),
      ),
    );
    // A saving form holds a spinner, which animates forever and so never
    // settles; one frame is enough to see it.
    if (isSaving) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens on what the block already says', (tester) async {
    await pumpForm(
      tester,
      initialDraft: const SignalBlockDraft(
        blockType: SignalBlockType.delay,
        label: 'Slapback',
        notes: 'Dotted eighths',
        isEnabled: false,
      ),
    );

    expect(find.text('Delay'), findsOne);
    expect(find.text('Slapback'), findsOne);
    expect(find.text('Dotted eighths'), findsOne);
    expect(find.text('Bypassed, but still on the board'), findsOne);
  });

  testWidgets('the pedal in the block is not asked for here', (tester) async {
    await pumpForm(tester);

    // It has a picker of its own on the block's menu, and so does the position:
    // one is chosen from the inventory, the other is dragged.
    expect(find.text('Pedal'), findsNothing);
    expect(find.text('Position'), findsNothing);
  });

  testWidgets('hands back the type, the label and the notes', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.byType(DropdownButtonFormField<SignalBlockType>));
    await tester.pumpAndSettle();
    // Every block type is offered, so the menu scrolls; the last match is the
    // menu's rather than the closed field's.
    await tester.ensureVisible(find.text('Delay').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delay').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Slapback');
    await tester.enterText(find.byType(TextFormField).last, 'Dotted eighths');
    await save(tester);

    expect(submitted?.blockType, SignalBlockType.delay);
    expect(submitted?.label, 'Slapback');
    expect(submitted?.notes, 'Dotted eighths');
  });

  testWidgets('bypassing says the block stays on the board', (tester) async {
    await pumpForm(tester);

    expect(find.text('Passing signal'), findsOne);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Bypassed, but still on the board'), findsOne);

    await save(tester);
    expect(submitted?.isEnabled, isFalse);
  });

  testWidgets('a label longer than the column allows is refused', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'a' * 81);
    await save(tester);

    expect(find.text('Use at most 80 characters.'), findsOne);
    expect(submitted, isNull);
  });

  testWidgets('a save in flight cannot be asked for twice', (tester) async {
    await pumpForm(tester, isSaving: true);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOne);
    expect(submitted, isNull);
  });
}
