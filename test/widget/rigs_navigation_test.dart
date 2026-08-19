import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';

/// Getting around the rigs tab: the list, one rig, and the forms either side of
/// it. Every stream is a plain value, so no database is involved.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  final worship = Pedalboard(
    id: 4,
    name: 'Hybrid Worship Rig',
    description: 'MG-30 into the desk',
    createdAt: moment,
    updatedAt: moment,
  );

  /// Opens the app on the rigs tab with [pedalboards] in the list.
  Future<void> pumpRigsTab(
    WidgetTester tester, {
    List<Pedalboard> pedalboards = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalboardListProvider.overrideWith(
            (ref) => Stream.value(pedalboards),
          ),
          pedalboardProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(worship)),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rigs'));
    await tester.pumpAndSettle();
  }

  testWidgets('says what a rig is when there are none', (tester) async {
    await pumpRigsTab(tester);

    expect(find.text('No rigs yet'), findsOne);
    expect(find.textContaining('ordered signal chain'), findsOne);
  });

  testWidgets('a card opens that rig, and its edit form', (tester) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    expect(find.text('MG-30 into the desk'), findsOne);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Built 2026-08-19'), findsOne);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit rig'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOne);
    // The rig routes are nested under the list, so the tabs stay put.
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('the add button opens an empty form, not rig "new"', (
    tester,
  ) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // '/rigs/new' has to win over '/rigs/:rigId', or this lands on a rig screen
    // for a rig that cannot exist.
    expect(find.text('Add rig'), findsExactly(2)); // title and button
    expect(find.text('That rig no longer exists'), findsNothing);
  });

  testWidgets('a rig that is gone says so rather than showing a blank', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalboardListProvider.overrideWith((ref) => Stream.value([worship])),
          // Deleted on another screen while this one was open.
          pedalboardProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(null)),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rigs'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();

    expect(find.text('That rig no longer exists'), findsOne);
    // Nothing to edit or delete, so neither action is offered.
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('deleting asks first, and says what it will not touch', (
    tester,
  ) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete rig?'), findsOne);
    expect(
      find.textContaining('The pedals themselves are not touched'),
      findsOne,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Cancelled, so the rig is still open.
    expect(find.textContaining('Built 2026-08-19'), findsOne);
  });
}
