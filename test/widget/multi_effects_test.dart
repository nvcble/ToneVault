import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/pedals/screens/pedal_detail_screen.dart';
import 'package:tone_vault/features/replacements/providers/replacement_providers.dart';

/// What a multi-effects unit shows where an ordinary pedal shows its
/// configurations, which is the one thing the mode decides.
void main() {
  Pedal pedal({
    required int id,
    required String name,
    PedalType type = PedalType.multiEffects,
    MultiEffectsMode? mode,
    int? hostPedalId,
  }) => Pedal(
    id: id,
    name: name,
    type: type,
    category: PedalCategory.multiEffects,
    status: PedalStatus.active,
    multiEffectsMode: mode,
    hostPedalId: hostPedalId,
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  final unit = pedal(id: 5, name: 'Valeton GP-200');

  final stomp = pedal(
    id: 6,
    name: 'Tube Screamer',
    type: PedalType.digital,
    hostPedalId: unit.id,
  );

  final scene = Configuration(
    id: 9,
    pedalId: unit.id,
    name: 'Chorus scene',
    createdAt: DateTime.utc(2026, 8, 19),
    updatedAt: DateTime.utc(2026, 8, 19),
  );

  /// Opens the unit's own screen with [mode] set and one pedal inside it.
  Future<void> pumpUnit(WidgetTester tester, {MultiEffectsMode? mode}) async {
    final shown = pedal(id: unit.id, name: unit.name, mode: mode);

    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalProvider(unit.id).overrideWith((ref) => Stream.value(shown)),
          componentPedalListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([stomp])),
          configurationListProvider(
            unit.id,
          ).overrideWith((ref) => Stream.value([scene])),
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

  testWidgets('a unit in stomp mode lists its stomps', (tester) async {
    await pumpUnit(tester, mode: MultiEffectsMode.stomp);
    await tester.tap(find.widgetWithText(Tab, 'Stomps'));
    await tester.pumpAndSettle();

    // Every stomp is one pedal, so it reads as one: the same card the inventory
    // list uses.
    expect(find.text('Tube Screamer'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Add stomp'), findsOne);

    // A stomp mode unit has no scenes, so its own configurations are not offered.
    expect(find.text('Chorus scene'), findsNothing);
    expect(find.text('Scenes'), findsNothing);
  });

  testWidgets('a unit in scene mode offers the patch and its scenes', (
    tester,
  ) async {
    await pumpUnit(tester, mode: MultiEffectsMode.scene);
    await tester.tap(find.widgetWithText(Tab, 'Patch'));
    await tester.pumpAndSettle();

    // The pedals on the patch come first, because a scene has nothing to set
    // until they exist.
    expect(find.text('Tube Screamer'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Add pedal'), findsOne);
    expect(find.text('Chorus scene'), findsNothing);

    await tester.tap(find.text('Scenes'));
    await tester.pumpAndSettle();

    expect(find.text('Chorus scene'), findsOne);
    expect(find.text('Tube Screamer'), findsNothing);
  });

  testWidgets('a unit with no mode yet asks for one', (tester) async {
    await pumpUnit(tester);
    await tester.tap(find.widgetWithText(Tab, 'Configurations'));
    await tester.pumpAndSettle();

    // Nothing is guessed on the unit's behalf: the mode decides what belongs
    // here, so it is asked for rather than assumed.
    expect(find.text('Say how this unit is used'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Pick a mode'), findsOne);
    expect(find.text('Tube Screamer'), findsNothing);
  });
}
