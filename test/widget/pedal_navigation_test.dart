import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';

void main() {
  final pedal = Pedal(
    id: 7,
    name: 'Caline PureSky',
    brand: 'Caline',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: PedalStatus.active,
    purchaseDate: DateTime.utc(2024, 1, 2),
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  /// Opens the app on the pedals tab with one pedal in it.
  Future<void> pumpPedalsTab(WidgetTester tester) async {
    // A tall window keeps the whole form on screen, so finders do not depend on
    // scroll position.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith((ref) => Stream.value([pedal])),
          pedalProvider(pedal.id).overrideWith((ref) => Stream.value(pedal)),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedals'));
    await tester.pumpAndSettle();
  }

  testWidgets('a card opens that pedal, and its edit form', (tester) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();

    expect(find.text('Purchased'), findsOne);
    expect(find.text('2024-01-02'), findsOne);
    expect(find.text('Added'), findsOne);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit pedal'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOne);
  });

  testWidgets('the add button opens an empty form, not pedal "new"', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // '/pedals/new' has to win over '/pedals/:pedalId', or this lands on a
    // detail screen for a pedal that cannot exist.
    expect(find.text('Add pedal'), findsExactly(2)); // title and button
    expect(find.text('That pedal no longer exists'), findsNothing);
  });

  testWidgets('the navigation bar stays put on a detail screen', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();

    // Nesting the detail route inside the shell branch is what keeps the tabs
    // reachable without backing out first.
    expect(find.byType(NavigationBar), findsOne);
    expect(find.text('Rigs'), findsOne);
  });
}
