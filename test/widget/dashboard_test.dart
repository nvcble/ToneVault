import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/dashboard/widgets/stat_card.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';

/// The home tab: the collection counted up, and the card leading to it. Every
/// stream is a plain value, so no database is involved.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(int id, PedalStatus status) => Pedal(
    id: id,
    name: 'Pedal $id',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: status,
    createdAt: moment,
    updatedAt: moment,
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    Stream<List<Pedal>>? pedals,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith(
            (ref) => pedals ?? Stream<List<Pedal>>.value(const []),
          ),
          recentHistoryProvider.overrideWith(
            (ref) => Stream<List<PedalChange>>.value(const []),
          ),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('counts the collection, and says what the numbers leave out', (
    tester,
  ) async {
    await pumpHome(
      tester,
      pedals: Stream.value([
        pedal(1, PedalStatus.active),
        pedal(2, PedalStatus.active),
        pedal(3, PedalStatus.active),
        pedal(4, PedalStatus.storage),
        pedal(5, PedalStatus.sold),
      ]),
    );

    expect(find.text('Your collection'), findsOne);
    // Four owned, three of them plugged in, and the sold one left out.
    expect(find.widgetWithText(StatCard, '4'), findsOne);
    expect(find.text('3 in use'), findsOne);
  });

  testWidgets('an empty collection is honest about being empty', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.widgetWithText(StatCard, '0'), findsOne);
    expect(find.text('None yet'), findsOne);
  });

  testWidgets('the pedals card opens the pedals tab', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.widgetWithText(StatCard, 'Pedals'));
    await tester.pumpAndSettle();

    expect(find.text('No pedals yet'), findsOne);
  });

  testWidgets('gear it could not count is admitted, not counted as none', (
    tester,
  ) async {
    await pumpHome(
      tester,
      pedals: Stream.error(const AppFailure('Could not load your pedals.')),
    );

    expect(find.text('Could not count your gear'), findsOne);
    expect(find.text('Could not load your pedals.'), findsOne);
    // A zero here would read as an empty collection, which is a different thing.
    expect(find.byType(StatCard), findsNothing);
  });
}
