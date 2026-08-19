import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/controls/providers/control_providers.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/replacements/providers/replacement_providers.dart';

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

  final control = PedalControl(
    id: 3,
    pedalId: pedal.id,
    name: 'Volume',
    controlType: ControlType.clock,
    minValue: 0,
    maxValue: 1,
    displayOrder: 0,
  );

  final configuration = Configuration(
    id: 11,
    pedalId: pedal.id,
    name: 'Worship Lead',
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  final PedalChange change = (
    entry: ChangeLog(
      id: 1,
      pedalId: pedal.id,
      controlName: control.name,
      changeType: ChangeType.controlAdded,
      createdAt: DateTime(2026, 8, 19, 9),
    ),
    pedalName: pedal.name,
    control: control,
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
          // The detail screen lists the pedal's controls, so the controls come
          // from here rather than from a real database.
          controlListProvider(
            pedal.id,
          ).overrideWith((ref) => Stream.value([control])),
          controlProvider(
            control.id,
          ).overrideWith((ref) => Stream.value(control)),
          // As do its configurations and the positions they hold.
          configurationListProvider(
            pedal.id,
          ).overrideWith((ref) => Stream.value([configuration])),
          configurationProvider(
            configuration.id,
          ).overrideWith((ref) => Stream.value(configuration)),
          configurationValuesProvider(
            configuration.id,
          ).overrideWith((ref) => Stream.value({control.id: 0.5})),
          // And its history, which the detail screen shows on its own tab.
          pedalHistoryProvider(
            pedal.id,
          ).overrideWith((ref) => Stream.value([change])),
          // This pedal has never been swapped, which is what the overview and
          // the Replace action both ask about.
          pedalSwapsProvider(
            pedal.id,
          ).overrideWith((ref) => Stream.value(const [])),
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

  testWidgets('the controls tab lists the pedal\'s controls and edits one', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Controls'));
    await tester.pumpAndSettle();

    expect(find.text('Volume'), findsOne);
    expect(find.text('Purchased'), findsNothing);

    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();

    // The control routes are nested under the pedal, so editing a control is
    // reached without leaving the pedals branch.
    expect(find.text('Edit control'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOne);
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('the controls tab opens an empty form for a new control', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Controls'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add control'));
    await tester.pumpAndSettle();

    expect(find.text('Add control'), findsExactly(2)); // title and button
    expect(find.text('That control no longer exists'), findsNothing);
    expect(find.text('Type'), findsOne);
  });

  testWidgets('the configurations tab opens one and lists its settings', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurations'));
    await tester.pumpAndSettle();

    expect(find.text('Worship Lead'), findsOne);

    await tester.tap(find.text('Worship Lead'));
    await tester.pumpAndSettle();

    // The configuration routes are nested under the pedal too, so its settings
    // are reached without leaving the pedals branch.
    expect(find.text('Volume'), findsOne);
    expect(find.text('12:00'), findsOne);
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('the configurations tab opens an empty form for a new one', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurations'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add configuration'));
    await tester.pumpAndSettle();

    // '/configurations/new' has to win over '/configurations/:configurationId'.
    expect(find.text('Add configuration'), findsExactly(2)); // title and button
    expect(find.text('That configuration no longer exists'), findsNothing);
  });

  testWidgets('the history tab reads out what happened to this pedal', (
    tester,
  ) async {
    await pumpPedalsTab(tester);

    await tester.tap(find.text('Caline PureSky'));
    await tester.pumpAndSettle();

    // 'History' is also a bottom navigation destination, so the tab has to be
    // picked out of the tab bar rather than by its text alone.
    await tester.tap(find.widgetWithText(Tab, 'History'));
    await tester.pumpAndSettle();

    expect(find.text('Volume added'), findsOne);
    expect(find.text('Nothing logged yet'), findsNothing);
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
