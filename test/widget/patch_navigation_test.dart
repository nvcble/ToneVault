import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
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

  /// A control of the pedal inside the unit, which is what a scene sets.
  final drive = PedalControl(
    id: 41,
    pedalId: screamer.id,
    name: 'Drive',
    controlType: ControlType.clock,
    minValue: 0,
    maxValue: 1,
    displayOrder: 0,
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
  /// [scenePedals] is what the scene under test uses, and [sceneValues] where it
  /// puts their controls; everything else is the same one unit with one patch and
  /// one scene in it.
  Future<void> openPatchTab(
    WidgetTester tester, {
    List<Pedal> scenePedals = const [],
    Map<int, double> sceneValues = const {},
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
          // The controls a scene can set follow the pedals in it, so the one
          // pedal that has a control brings it along.
          sceneControlsProvider(scene.id).overrideWith(
            (ref) => Stream.value([
              for (final pedal in scenePedals)
                (owner: pedal, controls: <PedalControl>[drive]),
            ]),
          ),
          sceneValuesProvider(
            scene.id,
          ).overrideWith((ref) => Stream.value(sceneValues)),
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

  /// Opens the one scene of the one patch, on the settings it holds.
  Future<void> openScene(WidgetTester tester) async {
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();
  }

  /// Switches an open scene over to the pedals it uses.
  ///
  /// 'Pedals' is a bottom navigation destination too, so the segment has to be
  /// picked out of the switch rather than by its text alone.
  Future<void> openScenePedals(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<bool>),
        matching: find.text('Pedals'),
      ),
    );
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

  testWidgets('a scene with no pedals in it has nothing to set', (
    tester,
  ) async {
    await openPatchTab(tester);
    await openScene(tester);

    // Empty rather than guessed at: putting the unit's pedals into every new
    // scene would claim sounds the user never chose.
    expect(find.text('Nothing to set yet'), findsOne);
    expect(find.textContaining('under Pedals'), findsOne);
  });

  testWidgets('a scene opens on where its controls sit', (tester) async {
    await openPatchTab(
      tester,
      scenePedals: [screamer],
      sceneValues: {drive.id: 0.5},
    );
    await openScene(tester);

    // Under the pedal it is on, because a scene sets the controls of several.
    expect(find.text('Tube Screamer'), findsOne);
    expect(find.text('Drive'), findsOne);
    expect(find.text('12:00'), findsOne);
  });

  testWidgets('a control the scene never set reads as unset', (tester) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await openScene(tester);

    // Not as its default: a scene that does not say where a knob goes has not
    // been finished, and saying 'Not set' is how the user sees what is left.
    expect(find.text('Not set'), findsOne);
    expect(find.text('12:00'), findsNothing);
  });

  testWidgets('a control opens the editor for this scene\'s position', (
    tester,
  ) async {
    await openPatchTab(
      tester,
      scenePedals: [screamer],
      sceneValues: {drive.id: 0.5},
    );
    await openScene(tester);

    await tester.tap(find.text('Drive'));
    await tester.pumpAndSettle();

    // The same sheet a configuration uses, with the write pointed at the scene.
    expect(find.widgetWithText(FilledButton, 'Save'), findsOne);
    expect(find.text('Why the change?'), findsOne);
    // Clear is offered only where there is something stored to clear.
    expect(find.widgetWithText(TextButton, 'Clear'), findsOne);
  });

  testWidgets('a scene says which pedals it has none of', (tester) async {
    await openPatchTab(tester);
    await openScene(tester);
    await openScenePedals(tester);

    expect(find.text('No pedals in this scene'), findsOne);
  });

  testWidgets('a scene lists the pedals it uses', (tester) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await openScene(tester);
    await openScenePedals(tester);

    expect(find.text('Tube Screamer'), findsOne);
    expect(find.text('Ibanez'), findsOne);
  });

  testWidgets('the picker offers the unit\'s pedals the scene lacks', (
    tester,
  ) async {
    await openPatchTab(tester);
    await openScene(tester);
    await openScenePedals(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Add pedal to scene'));
    await tester.pumpAndSettle();

    expect(find.text('Add a pedal to this scene'), findsOne);
    expect(find.text('Tube Screamer'), findsOne);
  });

  testWidgets('the picker also names a pedal into the scene', (tester) async {
    await openPatchTab(tester);
    await openScene(tester);
    await openScenePedals(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Add pedal to scene'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New pedal'));
    await tester.pumpAndSettle();

    // '/scenes/:sceneId/pedals/new' is nested under the scene, so it has to win
    // over the scene's own segments rather than land on "no longer exists".
    expect(find.widgetWithText(FilledButton, 'Add pedal'), findsOne);
    expect(find.text('That scene no longer exists'), findsNothing);
    // Name and category alone: it is a block of the unit, whose brand, purchase
    // and photo were entered once on the unit itself.
    expect(find.widgetWithText(TextFormField, 'Name'), findsOne);
    expect(find.text('Category'), findsOne);
    expect(find.text('Brand'), findsNothing);
  });

  testWidgets('a scene offers another one like it', (tester) async {
    await openPatchTab(tester);
    await tester.tap(find.text('Worship Clean'));
    await tester.pumpAndSettle();

    // Offered on the row rather than behind the scene, because a chorus is
    // written from the verse beside it. Not tapped here: the copy is a write, and
    // it is `scene_duplicate_test.dart` that holds it to what it copies.
    expect(
      find.descendant(
        of: find.byType(NamedTile),
        matching: find.byTooltip('Duplicate'),
      ),
      findsOne,
    );
  });

  testWidgets('and offers nothing once the scene uses them all', (
    tester,
  ) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await openScene(tester);
    await openScenePedals(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Add pedal to scene'));
    await tester.pumpAndSettle();

    // Adding a pedal twice is refused by the repository, so offering it again
    // would only be an invitation to be refused.
    expect(find.text('Every pedal is already in this scene'), findsOne);
  });

  testWidgets('taking a pedal out of a scene asks first', (tester) async {
    await openPatchTab(tester, scenePedals: [screamer]);
    await openScene(tester);
    await openScenePedals(tester);

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();

    // The positions the scene held for it go with it, which is worth a question.
    expect(find.text('Take out of this scene?'), findsOne);
    expect(find.textContaining('stays in the unit'), findsOne);
  });
}
