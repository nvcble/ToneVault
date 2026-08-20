import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/history/widgets/change_tile.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';

/// The rest of the home tab: what changed lately, and the two buttons that get
/// something into an empty collection.
void main() {
  PedalChange change(int id) => (
    entry: ChangeLog(
      id: id,
      pedalId: 7,
      configurationName: 'Worship Lead',
      controlName: 'Volume',
      changeType: ChangeType.controlValueChanged,
      oldValue: 0.25,
      newValue: 0.75,
      createdAt: DateTime(2026, 8, 19, 14, 5),
    ),
    pedalName: 'Caline PureSky',
    control: null,
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    Stream<List<PedalChange>>? changes,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith(
            (ref) => Stream<List<Pedal>>.value(const []),
          ),
          pedalboardListProvider.overrideWith(
            (ref) => Stream<List<Pedalboard>>.value(const []),
          ),
          recentHistoryProvider.overrideWith(
            (ref) => changes ?? Stream<List<PedalChange>>.value(const []),
          ),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a taste of the timeline rather than all of it', (
    tester,
  ) async {
    await pumpHome(
      tester,
      changes: Stream.value([for (var id = 1; id <= 6; id++) change(id)]),
    );

    expect(find.text('Lately'), findsOne);
    expect(find.byType(ChangeTile), findsExactly(3));
    // Named, since the home screen mixes every pedal together.
    expect(find.textContaining('Caline PureSky'), findsAtLeast(1));
  });

  testWidgets('leads on to the whole timeline', (tester) async {
    await pumpHome(
      tester,
      changes: Stream.value([for (var id = 1; id <= 6; id++) change(id)]),
    );

    final seeAll = find.widgetWithText(TextButton, 'See all history');
    // Below the fold on a short window, as it would be under a full timeline.
    // The scroll has to be pumped before the tap, or the tap still aims at where
    // the button used to be.
    await tester.ensureVisible(seeAll);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    // The History tab holds nothing back, which is the point of going there.
    expect(find.byType(ChangeTile), findsExactly(6));
  });

  testWidgets('an empty timeline reads as an invitation, not a fault', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.textContaining('Nothing has changed yet'), findsOne);
    expect(find.byType(ChangeTile), findsNothing);
    // Nowhere to go yet, so the way through is not offered.
    expect(find.text('See all history'), findsNothing);
  });

  testWidgets('a timeline it could not load says so', (tester) async {
    await pumpHome(
      tester,
      changes: Stream.error(const AppFailure('Could not load the history.')),
    );

    expect(find.text('Could not load what changed lately'), findsOne);
    expect(find.text('Could not load the history.'), findsOne);
  });

  testWidgets('adding a pedal starts from the home tab', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Add a pedal'));
    await tester.pumpAndSettle();

    // The form's own title, rather than its save button, which sits below the
    // fold on a window this short.
    expect(find.widgetWithText(AppBar, 'Add pedal'), findsOne);
  });

  testWidgets('building a rig starts from the home tab', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Build a rig'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Add rig'), findsOne);
  });
}
