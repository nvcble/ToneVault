import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/pedals/screens/pedals_screen.dart';

void main() {
  final timestamp = DateTime.utc(2026, 8, 19, 10);

  Pedal pedal({
    required int id,
    required String name,
    required PedalCategory category,
    String? brand,
    PedalType type = PedalType.analog,
    PedalStatus status = PedalStatus.active,
  }) {
    return Pedal(
      id: id,
      name: name,
      brand: brand,
      type: type,
      category: category,
      status: status,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  // The screen is given its list directly rather than a database: what the
  // repository stores and orders is covered by pedal_repository_test.dart.
  Future<void> pumpScreen(WidgetTester tester, List<Pedal> pedals) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith((ref) => Stream.value(pedals)),
        ],
        child: const MaterialApp(home: PedalsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('invites the user to add gear when the inventory is empty', (
    tester,
  ) async {
    await pumpScreen(tester, []);

    expect(find.text('No pedals yet'), findsOne);
    expect(find.byIcon(Icons.add), findsOne);
  });

  testWidgets('shows a card per pedal with its brand and category', (
    tester,
  ) async {
    await pumpScreen(tester, [
      pedal(
        id: 1,
        name: 'Caline PureSky',
        brand: 'Caline',
        category: PedalCategory.overdrive,
      ),
      pedal(
        id: 2,
        name: 'NUX MG-30',
        brand: 'NUX',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    ]);

    expect(find.text('Caline PureSky'), findsOne);
    expect(find.text('Caline · Overdrive'), findsOne);
    expect(find.text('NUX · Multi Effects'), findsOne);
    expect(find.text('Analog'), findsOne);
    expect(find.text('Digital'), findsOne);
  });

  testWidgets('spells out a status that is not active', (tester) async {
    await pumpScreen(tester, [
      pedal(
        id: 1,
        name: 'Rowin Noise Gate',
        category: PedalCategory.noiseGate,
        status: PedalStatus.storage,
      ),
      pedal(id: 2, name: 'Joyo American Sound', category: PedalCategory.ampSim),
    ]);

    expect(find.text('Noise Gate · In storage'), findsOne);
    // An active pedal is the ordinary case and says nothing about its status.
    expect(find.text('Amp Sim'), findsOne);
  });

  testWidgets('offers a retry when the inventory cannot be read', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith(
            (ref) => Stream<List<Pedal>>.error(Exception('disk gone')),
          ),
        ],
        child: const MaterialApp(home: PedalsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load your pedals'), findsOne);
    expect(find.text('Try again'), findsOne);
    // The raw exception text never reaches the screen.
    expect(find.textContaining('disk gone'), findsNothing);
  });
}
