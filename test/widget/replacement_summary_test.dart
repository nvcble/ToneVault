import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_replacement_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/replacements/providers/replacement_providers.dart';
import 'package:tone_vault/features/replacements/widgets/replacement_summary.dart';

/// How a pedal's own screen says it was replaced, or that it stood in for
/// something else.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(int id, String name) => Pedal(
    id: id,
    name: name,
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: PedalStatus.active,
    createdAt: moment,
    updatedAt: moment,
  );

  final pureSky = pedal(1, 'Caline PureSky');
  final mg30 = pedal(2, 'NUX MG-30');

  PedalSwap swap({String? reason}) => (
    replacement: PedalReplacement(
      id: 1,
      oldPedalId: pureSky.id,
      newPedalId: mg30.id,
      reason: reason,
      replacedAt: moment,
    ),
    outgoing: pureSky,
    incoming: mg30,
  );

  Future<void> pumpSummary(
    WidgetTester tester, {
    required int pedalId,
    required Stream<List<PedalSwap>> swaps,
    ValueChanged<int>? onOpenPedal,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pedalSwapsProvider(pedalId).overrideWith((ref) => swaps)],
        child: MaterialApp(
          home: Scaffold(
            body: ReplacementSummary(
              pedalId: pedalId,
              onOpenPedal: onOpenPedal,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('names what replaced this pedal, with the reason given', (
    tester,
  ) async {
    await pumpSummary(
      tester,
      pedalId: pureSky.id,
      swaps: Stream.value([swap(reason: 'wanted the amp models')]),
    );

    expect(find.text('Replaced by NUX MG-30'), findsOne);
    expect(find.text('2026-08-19 · wanted the amp models'), findsOne);
  });

  testWidgets('reads the same swap the other way round on the new pedal', (
    tester,
  ) async {
    await pumpSummary(tester, pedalId: mg30.id, swaps: Stream.value([swap()]));

    expect(find.text('Took over from Caline PureSky'), findsOne);
    // No reason was given, so the row says only when it happened.
    expect(find.text('2026-08-19'), findsOne);
  });

  testWidgets('shows nothing at all for a pedal never swapped', (tester) async {
    await pumpSummary(
      tester,
      pedalId: pureSky.id,
      swaps: Stream.value(const []),
    );

    // An ordinary pedal's overview is not padded out with an empty section.
    expect(find.byType(Card), findsNothing);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('opens the other pedal in the swap', (tester) async {
    int? opened;
    await pumpSummary(
      tester,
      pedalId: pureSky.id,
      swaps: Stream.value([swap()]),
      onOpenPedal: (pedalId) => opened = pedalId,
    );

    await tester.tap(find.text('Replaced by NUX MG-30'));
    await tester.pumpAndSettle();

    expect(opened, mg30.id);
  });

  testWidgets('says a swap could not be read rather than nothing', (
    tester,
  ) async {
    await pumpSummary(
      tester,
      pedalId: pureSky.id,
      swaps: Stream<List<PedalSwap>>.error(Exception('disk gone')),
    );

    expect(find.textContaining('Something went wrong'), findsOne);
    expect(find.textContaining('disk gone'), findsNothing);
  });
}
