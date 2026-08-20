import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/patches/providers/patch_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/replacements/providers/replacement_providers.dart';
import 'package:tone_vault/shared/widgets/named_tile.dart';
import '../support/app_tabs.dart';
import '../support/home_streams.dart';

/// Reaching a unit's patches, its scenes, and the pedals one scene uses.
///
/// The whole app is pumped so the routes are the real ones: a patch is nested
/// under the unit and a scene under the patch, and getting either segment wrong
/// lands on a "no longer exists" screen rather than failing loudly.
void main() {
  final moment = DateTime.utc(2026, 8, 20);

  final unit = Pedal(
    id: 7,
    name: 'Valeton GP-200',
    type: PedalType.digital,
    category: PedalCategory.multiEffects,
    status: PedalStatus.active,
    createdAt: moment,
    updatedAt: moment,
  );

  final screamer = Pedal(
    id: 8,
    name: 'Tube Screamer',
    brand: 'Ibanez',
    type: PedalType.digital,
    category: PedalCategory.overdrive,
    status: PedalStatus.active,
    hostPedalId: unit.id,
    createdAt: moment,
    updatedAt: moment,
  );

  final patch = Patch(
    id: 21,
    pedalId: unit.id,
    name: 'Worship Clean',
    notes: 'Second service',
    createdAt: moment,
    updatedAt: moment,
  );

  final scene = Scene(
    id: 31,
    patchId: patch.id,
    name: 'Verse',
    createdAt: moment,
    updatedAt: moment,
  );

  /// Opens the app on the unit's Patch tab.
  ///
  /// [scenePedals] is what the scene under test uses; everything else is the
  /// same one unit with one patch and one scene in it.
  Future<void> openPatchTab(
    WidgetTester tester, {
    List<Pedal> scenePedals = const [],
  }) async {
    // A tall window keeps the whole tab on screen, so finders do not depend on
    // scroll position.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...homeStreamOverrides(pedals: [unit]),
          pedalProvider(unit.id).overrideWith((ref) => Stream.value(unit)),
          pedalProvider(
            screamer.id,
          ).overrideWith((ref) => Stream.value(screamer)),
          // The unit's own pedals, which is where a scene's come from.
          componentPedalListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([screamer])),
          patchListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([patch])),
          patchProvider(patch.id).overrideWith((ref) => Stream.value(patch)),
          sceneListProvider(
            patch.id,
          ).overrideWith((ref) => Stream.value([scene])),
          sceneProvider(scene.id).overrideWith((ref) => Stream.value(scene)),
          scenePedalListProvider(
            scene.id,
          ).overrideWith((ref) => Stream.value(scenePedals)),
          // Read by the overview and the Replace action on the way through.
          pedalSwapsProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value(const [])),
          pedalHistoryProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value(const [])),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    await openTab(tester, 'Pedals');
    await tester.tap(find.text('Valeton GP-200'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Patch'));
    await tester.pumpAndSettle();
  }

  testWidgets('the Patch tab opens on the unit\'s patches', (tester) async {
    await openPatchTab(tester);

    // Patches first: the pedals inside the unit are entered once and rarely
    // returned to, so they are the other half of the switch.
    expect(find.text('Worship Clean'), findsOne);
    expect(find.text('Second service'), findsOne);
    expect(find.text('Tube Screamer'), findsNothing);
  });

  testWidgets('the same tab shows the pedals inside the unit', (tester) async {
    await openPatchTab(tester);

    // 'Pedals' is a bottom navigation destination too, so the segment has to be
    // picked out of the switch rather than by its text alone.
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<bool>),
        matching: find.text('Pedals'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tube Screamer'), findsOne);
    expect(find.text('Worship Clean'), findsNothing);
  });

  testWidgets('a patch opens on the scenes inside it', (tester) async {
    await openPatchTab(tester);

    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();

    expect(find.text('Verse'), findsOne);
    // The patch routes are nested under the pedal, so a patch is reached
    // without leaving the pedals branch.
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('a new patch is added, not a patch called "new"', (tester) async {
    await openPatchTab(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Add patch'));
    await tester.pumpAndSettle();

    // '/patches/new' has to win over '/patches/:patchId'.
    expect(find.text('Add patch'), findsExactly(2)); // title and button
    expect(find.text('That patch no longer exists'), findsNothing);
  });

  testWidgets('a new scene is added under the patch it belongs to', (
    tester,
  ) async {
    await openPatchTab(tester);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add scene'));
    await tester.pumpAndSettle();

    expect(find.text('Add scene'), findsExactly(2)); // title and button
    expect(find.text('That scene no longer exists'), findsNothing);
  });

  testWidgets('renaming a scene opens on what it is already called', (
    tester,
  ) async {
    await openPatchTab(tester);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();

    // The patch's own Rename is in the app bar, so the scene's has to be taken
    // from the scene's row.
    await tester.tap(
      find.descendant(
        of: find.byType(NamedTile),
        matching: find.byIcon(Icons.edit_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit scene'), findsOne);
    expect(find.widgetWithText(TextFormField, 'Verse'), findsOne);
  });

  testWidgets('a scene says which pedals it has none of', (tester) async {
    await openPatchTab(tester);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();

    // Empty rather than guessed at: putting the unit's pedals into every new
    // scene would claim sounds the user never chose.
    expect(find.text('No pedals in this scene'), findsOne);
  });

  testWidgets('a scene lists the pedals it uses', (tester) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();

    expect(find.text('Tube Screamer'), findsOne);
    expect(find.text('Ibanez'), findsOne);
  });

  testWidgets('the picker offers the unit\'s pedals the scene lacks', (
    tester,
  ) async {
    await openPatchTab(tester);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add pedal to scene'));
    await tester.pumpAndSettle();

    expect(find.text('Add a pedal to this scene'), findsOne);
    expect(find.text('Tube Screamer'), findsOne);
  });

  testWidgets('and offers nothing once the scene uses them all', (
    tester,
  ) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add pedal to scene'));
    await tester.pumpAndSettle();

    // Adding a pedal twice is refused by the repository, so offering it again
    // would only be an invitation to be refused.
    expect(find.text('Every pedal is already in this scene'), findsOne);
  });

  testWidgets('taking a pedal out of a scene asks first', (tester) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();

    // The positions the scene held for it go with it, which is worth a question.
    expect(find.text('Take out of this scene?'), findsOne);
    expect(find.textContaining('stays in the unit'), findsOne);
  });
}
