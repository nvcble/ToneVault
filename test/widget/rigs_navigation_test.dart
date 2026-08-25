import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedalboards/widgets/rig_options_menu.dart';
import 'package:tone_vault/features/snapshots/providers/snapshot_providers.dart';
import '../support/app_tabs.dart';
import '../support/chain_rows.dart';
import '../support/home_streams.dart';

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

  final drive = chainPedal(7, 'Caline PureSky');

  /// Enough of a chain for a snapshot to be worth taking.
  final chain = [chainBlock(10, pedalboardId: worship.id, pedal: drive)];

  /// Opens the app on the rigs tab with [pedalboards] in the list.
  Future<void> pumpRigsTab(
    WidgetTester tester, {
    List<Pedalboard> pedalboards = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The app opens on the home tab, which reads the pedals, the rigs and
          // the timeline before the rigs tab is ever tapped.
          ...homeStreamOverrides(
            pedals: [drive],
            rigs: pedalboards,
            blockCounts: {worship.id: chain.length},
          ),
          pedalboardProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(worship)),
          // The rig screen shows its chain, which would otherwise open the
          // database. What the chain looks like is signal_chain_view_test.dart's
          // job.
          signalChainProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(chain)),
          signalRoutingProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(ChainRouting.none)),
          rigSnapshotsProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(const <RigSnapshot>[])),
          // Reached once the capture screen asks where the pedal was set.
          configurationListProvider(
            drive.id,
          ).overrideWith((ref) => Stream.value(const <Configuration>[])),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    await openTab(tester, 'Rigs');
  }

  /// Opens the rig-level actions, which are behind one button rather than a row
  /// of icons.
  Future<void> openRigOptions(WidgetTester tester) async {
    await tester.tap(find.byType(RigOptionsMenu));
    await tester.pumpAndSettle();
  }

  testWidgets('says what a rig is when there are none', (tester) async {
    await pumpRigsTab(tester);

    expect(find.text('No rigs yet'), findsOne);
    expect(find.textContaining('block by block'), findsOne);
  });

  testWidgets('a card opens that rig, and its edit form', (tester) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    // What the user said about the rig, and how long its chain is.
    expect(find.text('MG-30 into the desk · 1 block'), findsOne);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Built 2026-08-19'), findsOne);

    await openRigOptions(tester);
    await tester.tap(find.text('Edit rig'));
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

  testWidgets('the snapshots tab leads to taking one', (tester) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Snapshots'));
    await tester.pumpAndSettle();

    expect(find.text('No snapshots of this rig yet'), findsOne);

    await tester.tap(find.widgetWithText(FilledButton, 'Take a snapshot'));
    await tester.pumpAndSettle();

    expect(find.text('Take snapshot'), findsExactly(2)); // title and button
    // The rig is asked about pedal by pedal, in signal order.
    expect(find.text('1. Caline PureSky'), findsOne);
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('a block on the chain leads to its own form', (tester) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Signal Chain'));
    await tester.pumpAndSettle();

    // Tapping a block offers what can be done with it, rather than doing one of
    // them.
    await tester.tap(find.text('Caline PureSky').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit block'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOne);
    // Nested under the rig, so the tabs stay put.
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('a rig that is gone says so rather than showing a blank', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...homeStreamOverrides(pedals: [drive], rigs: [worship]),
          // Deleted on another screen while this one was open.
          pedalboardProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(null)),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
    await openTab(tester, 'Rigs');

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();

    expect(find.text('That rig no longer exists'), findsOne);
    // Nothing left to act on, so the actions are not offered at all.
    expect(find.byType(RigOptionsMenu), findsNothing);
  });

  testWidgets('clearing the chain asks first, and says there is no undo', (
    tester,
  ) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await openRigOptions(tester);
    await tester.tap(find.text('Clear chain'));
    await tester.pumpAndSettle();

    expect(find.text('Clear chain?'), findsOne);
    expect(find.textContaining('no undo'), findsOne);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Cancelled, so the rig is still open as it was.
    expect(find.textContaining('Built 2026-08-19'), findsOne);
  });

  testWidgets('the options menu is another way to take a snapshot', (
    tester,
  ) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await openRigOptions(tester);
    await tester.tap(find.text('Save snapshot'));
    await tester.pumpAndSettle();

    // The same screen the snapshots tab leads to, rather than a second way of
    // capturing one.
    expect(find.text('1. Caline PureSky'), findsOne);
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('deleting asks first, and says what it will not touch', (
    tester,
  ) async {
    await pumpRigsTab(tester, pedalboards: [worship]);

    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await openRigOptions(tester);
    await tester.tap(find.text('Delete rig'));
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
