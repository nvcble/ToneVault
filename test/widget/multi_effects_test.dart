import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/patches/providers/patch_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/pedals/screens/pedal_detail_screen.dart';
import 'package:tone_vault/features/replacements/providers/replacement_providers.dart';

/// What a multi-effects unit shows where an ordinary pedal shows its
/// configurations, which its category alone decides.
void main() {
  Pedal pedal({
    required int id,
    required String name,
    PedalCategory category = PedalCategory.multiEffects,
    int? hostPedalId,
  }) => Pedal(
    id: id,
    name: name,
    type: PedalType.digital,
    category: category,
    status: PedalStatus.active,
    hostPedalId: hostPedalId,
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  final unit = pedal(id: 5, name: 'Valeton GP-200');

  final inside = pedal(
    id: 6,
    name: 'Tube Screamer',
    category: PedalCategory.overdrive,
    hostPedalId: unit.id,
  );

  /// A configuration of the unit itself, which nothing should offer: a unit's
  /// sounds are patches, and a patch's are scenes.
  final configuration = Configuration(
    id: 9,
    pedalId: unit.id,
    name: 'Chorus scene',
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  /// A sound of the unit, which is what its Patch tab opens on.
  final patch = Patch(
    id: 12,
    pedalId: unit.id,
    name: 'Worship Clean',
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  /// Opens the unit's own screen with one pedal inside it.
  Future<void> pumpUnit(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalProvider(unit.id).overrideWith((ref) => Stream.value(unit)),
          componentPedalListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([inside])),
          patchListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([patch])),
          configurationListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([configuration])),
          pedalHistoryProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value(const [])),
          pedalSwapsProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(home: PedalDetailScreen(pedalId: unit.id)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a unit is offered a patch where a pedal has configurations', (
    tester,
  ) async {
    await pumpUnit(tester);

    expect(find.widgetWithText(Tab, 'Patch'), findsOne);
    expect(find.widgetWithText(Tab, 'Configurations'), findsNothing);
    expect(find.widgetWithText(Tab, 'Controls'), findsNothing);
    expect(find.widgetWithText(Tab, 'Overview'), findsOne);
    expect(find.widgetWithText(Tab, 'History'), findsOne);
  });

  testWidgets('the patch tab opens on the unit\'s patches', (tester) async {
    await pumpUnit(tester);
    await tester.tap(find.widgetWithText(Tab, 'Patch'));
    await tester.pumpAndSettle();

    expect(find.text('Worship Clean'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Add patch'), findsOne);

    // The unit's own configurations are not its scenes, so they are not here.
    expect(find.text('Chorus scene'), findsNothing);
  });

  testWidgets('and nothing else: its pedals are managed in a scene', (
    tester,
  ) async {
    await pumpUnit(tester);
    await tester.tap(find.widgetWithText(Tab, 'Patch'));
    await tester.pumpAndSettle();

    // No switch over to the unit's pedals, because a pedal is only of use once a
    // scene says it is on.
    expect(find.byType(SegmentedButton<bool>), findsNothing);
    expect(find.text('Tube Screamer'), findsNothing);
  });
}
