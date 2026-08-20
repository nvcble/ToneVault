import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/replacements/providers/replacement_providers.dart';
import 'package:tone_vault/features/replacements/widgets/replace_pedal_sheet.dart';
import '../support/repositories.dart';
import '../support/themed_app.dart';

/// The replace flow: what the sheet offers, and what the swap leaves behind. The
/// write is the real one, over an in-memory database.
void main() {
  late AppDatabase database;

  Future<Pedal> addPedal(
    String name, {
    PedalStatus status = PedalStatus.active,
  }) async {
    final id = await pedalRepository(database).createPedal(
      PedalDraft(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
        status: status,
      ),
    );
    return (await database.pedalDao.findPedal(id))!;
  }

  Future<void> pumpSheet(
    WidgetTester tester,
    Pedal pedal,
    List<Pedal> inventory,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The inventory as a plain stream: a live drift stream cancelled when
          // the tree comes down leaves a timer pending, which the widget test
          // binding rejects. The rows are the ones actually in the database, so
          // the write still has real pedals to point at.
          pedalListProvider.overrideWith((ref) => Stream.value(inventory)),
          replacementRepositoryProvider.overrideWithValue(
            replacementRepository(database),
          ),
        ],
        // The app's own theme: its full-width FilledButton is what a row of
        // sheet actions has to cope with.
        child: themedApp(ReplacePedalSheet(pedal: pedal)),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => database = AppDatabase(NativeDatabase.memory()));

  tearDown(() => database.close());

  testWidgets('offers only the pedals that could take over', (tester) async {
    final pureSky = await addPedal('Caline PureSky');
    final mg30 = await addPedal('NUX MG-30');
    final sold = await addPedal('Sold Wah', status: PedalStatus.sold);
    await pumpSheet(tester, pureSky, [pureSky, mg30, sold]);

    await tester.tap(find.text('Replaced by'));
    await tester.pumpAndSettle();

    expect(find.text('NUX MG-30'), findsOne);
    expect(find.text('Sold Wah'), findsNothing);
    // The pedal being replaced is named in the title, and nowhere in the list.
    expect(find.text('Caline PureSky'), findsNothing);
  });

  testWidgets('asks for a choice before replacing anything', (tester) async {
    final pureSky = await addPedal('Caline PureSky');
    final mg30 = await addPedal('NUX MG-30');
    await pumpSheet(tester, pureSky, [pureSky, mg30]);

    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await tester.pumpAndSettle();

    expect(find.text('Choose the pedal that took over.'), findsOne);
    expect(
      (await database.pedalDao.findPedal(pureSky.id))!.status,
      PedalStatus.active,
    );
  });

  testWidgets('records the swap and retires the pedal it replaced', (
    tester,
  ) async {
    final pureSky = await addPedal('Caline PureSky');
    final mg30 = await addPedal('NUX MG-30');
    await pumpSheet(tester, pureSky, [pureSky, mg30]);

    await tester.tap(find.text('Replaced by'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NUX MG-30').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Why the change?'),
      'wanted the amp models',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await tester.pumpAndSettle();

    // The sheet closes only once the swap is written.
    expect(find.byType(ReplacePedalSheet), findsNothing);

    final swap = await database.pedalReplacementDao.findReplacementOf(
      pureSky.id,
    );
    expect(swap?.newPedalId, mg30.id);
    expect(swap?.reason, 'wanted the amp models');

    // Retired, not removed, and the swap is on its timeline.
    expect(
      (await database.pedalDao.findPedal(pureSky.id))!.status,
      PedalStatus.replaced,
    );
    final history = await database.changeLogDao.entriesOf(pureSky.id);
    expect(
      history.map((entry) => entry.changeType),
      contains(ChangeType.pedalReplaced),
    );
  });

  testWidgets('says what to do when nothing could take over', (tester) async {
    final pureSky = await addPedal('Caline PureSky');
    await pumpSheet(tester, pureSky, [pureSky]);

    expect(
      find.textContaining('Add the pedal that took over to your inventory'),
      findsOne,
    );
    expect(find.text('Replaced by'), findsNothing);
    // Nothing to pick means nothing to save, rather than a refusal after the
    // fact.
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Replace'),
    );
    expect(button.onPressed, isNull);
  });
}
