import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/pedals/screens/pedals_screen.dart';
import 'package:tone_vault/features/pedals/widgets/pedal_card.dart';

/// Narrowing the inventory: the search box, the two chips, and what the screen
/// says when nothing matches.
void main() {
  final moment = DateTime.utc(2026, 8, 19);

  Pedal pedal(
    int id,
    String name, {
    String? brand,
    PedalCategory category = PedalCategory.overdrive,
    PedalStatus status = PedalStatus.active,
  }) => Pedal(
    id: id,
    name: name,
    brand: brand,
    type: PedalType.analog,
    category: category,
    status: status,
    createdAt: moment,
    updatedAt: moment,
  );

  final pedals = [
    pedal(1, 'PureSky', brand: 'Caline'),
    pedal(2, 'Blues Driver', brand: 'Boss', status: PedalStatus.storage),
    pedal(3, 'DD-3', brand: 'Boss', category: PedalCategory.delay),
  ];

  Future<void> pumpPedals(
    WidgetTester tester, {
    List<Pedal> inventory = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith((ref) => Stream.value(inventory)),
        ],
        child: const MaterialApp(home: PedalsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens one of the two filter chips and picks [choice] from its menu.
  Future<void> chooseFrom(
    WidgetTester tester,
    String chip,
    String choice,
  ) async {
    await tester.tap(find.widgetWithText(FilterChip, chip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  testWidgets('an empty collection is not asked to be searched', (
    tester,
  ) async {
    await pumpPedals(tester);

    expect(find.text('No pedals yet'), findsOne);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('the whole collection is on screen, and counted', (tester) async {
    await pumpPedals(tester, inventory: pedals);

    expect(find.byType(PedalCard), findsExactly(3));
    expect(find.text('3 pedals'), findsOne);
  });

  testWidgets('typing narrows the list and says how much it is holding back', (
    tester,
  ) async {
    await pumpPedals(tester, inventory: pedals);

    await tester.enterText(find.byType(TextField), 'boss');
    await tester.pumpAndSettle();

    // Brand, not name: neither of these is called 'Boss'.
    expect(find.text('Blues Driver'), findsOne);
    expect(find.text('DD-3'), findsOne);
    expect(find.text('PureSky'), findsNothing);
    expect(find.text('2 of 3 pedals'), findsOne);
  });

  testWidgets('clearing the box puts the whole collection back', (
    tester,
  ) async {
    await pumpPedals(tester, inventory: pedals);

    await tester.enterText(find.byType(TextField), 'boss');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(find.byType(PedalCard), findsExactly(3));
    expect(find.text('3 pedals'), findsOne);
  });

  testWidgets('the category chip offers only the categories owned', (
    tester,
  ) async {
    await pumpPedals(tester, inventory: pedals);

    await tester.tap(find.widgetWithText(FilterChip, 'Category'));
    await tester.pumpAndSettle();

    expect(find.text('Overdrive'), findsOne);
    expect(find.text('Delay'), findsOne);
    // Owned by nobody here, so it is not in the way.
    expect(find.text('Reverb'), findsNothing);

    await tester.tap(find.text('Delay'));
    await tester.pumpAndSettle();

    expect(find.byType(PedalCard), findsOne);
    expect(find.text('DD-3'), findsOne);
    // The chip now reads as the choice it is making.
    expect(find.widgetWithText(FilterChip, 'Delay'), findsOne);
  });

  testWidgets('a status narrows the list, and any status widens it again', (
    tester,
  ) async {
    await pumpPedals(tester, inventory: pedals);

    await chooseFrom(tester, 'Status', 'In storage');

    expect(find.byType(PedalCard), findsOne);
    expect(find.text('Blues Driver'), findsOne);

    await chooseFrom(tester, 'In storage', 'Any status');

    expect(find.byType(PedalCard), findsExactly(3));
  });

  testWidgets('nothing matching says the collection is still intact', (
    tester,
  ) async {
    await pumpPedals(tester, inventory: pedals);

    await tester.enterText(find.byType(TextField), 'klon');
    await tester.pumpAndSettle();

    expect(find.byType(PedalCard), findsNothing);
    expect(find.text('No pedals match'), findsOne);
    expect(
      find.textContaining('All 3 of your pedals are still here'),
      findsOne,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Clear filters'));
    await tester.pumpAndSettle();

    expect(find.byType(PedalCard), findsExactly(3));
    // Cleared for real, not just ignored: the box is empty too.
    expect(find.text('klon'), findsNothing);
  });
}
