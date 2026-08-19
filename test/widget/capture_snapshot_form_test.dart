import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedalboard_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/snapshots/widgets/capture_snapshot_form.dart';

/// What the capture form hands back: a named snapshot, and one configuration per
/// pedal that was actually set to one.
///
/// The saving itself is rig_snapshot_capture_test.dart's job in test/database.
void main() {
  const pedalboardId = 4;
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(int id, String name) {
    return Pedal(
      id: id,
      name: name,
      type: PedalType.analog,
      category: PedalCategory.overdrive,
      status: PedalStatus.active,
      createdAt: moment,
      updatedAt: moment,
    );
  }

  Configuration configuration(int id, int pedalId, String name) {
    return Configuration(
      id: id,
      pedalId: pedalId,
      name: name,
      createdAt: moment,
      updatedAt: moment,
    );
  }

  ChainSlot slot(Pedal pedal, int position) {
    return (
      slot: PedalboardSlot(
        id: 10 + position,
        pedalboardId: pedalboardId,
        pedalId: pedal.id,
        position: position,
      ),
      pedal: pedal,
    );
  }

  final wah = pedal(1, 'Vox Wah');
  final drive = pedal(2, 'Caline PureSky');

  final chain = [slot(wah, 0), slot(drive, 1)];

  SnapshotCapture? captured;

  setUp(() => captured = null);

  /// The form over a two pedal rig: the wah has nothing to record, the drive has
  /// two configurations to choose between.
  Future<void> pumpForm(WidgetTester tester, {bool isSaving = false}) async {
    // A row per pedal makes the form taller than the default 800x600 surface. A
    // tall window keeps every field tappable without scrolling first.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configurationListProvider(
            wah.id,
          ).overrideWith((ref) => Stream.value(const [])),
          configurationListProvider(drive.id).overrideWith(
            (ref) => Stream.value([
              configuration(20, drive.id, 'Worship Lead'),
              configuration(21, drive.id, 'Clean Boost'),
            ]),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CaptureSnapshotForm(
              chain: chain,
              isSaving: isSaving,
              onSubmit: (capture) => captured = capture,
            ),
          ),
        ),
      ),
    );
    // A saving form holds a spinner, which animates forever and so never
    // settles; one frame is enough to see it.
    if (isSaving) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  /// Opens the dropdown at [index] in the chain and picks [choice] from it.
  Future<void> choose(WidgetTester tester, int index, String choice) async {
    await tester.tap(find.byType(DropdownButtonFormField<int?>).at(index));
    await tester.pumpAndSettle();
    // The menu is above the closed field, so the last match is the menu's.
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  testWidgets('asks about each pedal in signal order', (tester) async {
    await pumpForm(tester);

    expect(find.text('1. Vox Wah'), findsOne);
    expect(find.text('2. Caline PureSky'), findsOne);
    // Every pedal starts unanswered rather than on some other day's reading.
    expect(find.text('Not recorded'), findsExactly(2));
  });

  testWidgets('records only the pedals that were answered', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Easter 2026');
    await choose(tester, 1, 'Worship Lead');
    await tester.tap(find.widgetWithText(FilledButton, 'Take snapshot'));
    await tester.pumpAndSettle();

    expect(captured?.draft.name, 'Easter 2026');
    // The wah was left alone, so it is absent rather than present with nothing.
    expect(captured?.configurationChoices, {drive.id: 20});
  });

  testWidgets('notes come along, and blank notes do not', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Friday');
    await tester.tap(find.widgetWithText(FilledButton, 'Take snapshot'));
    await tester.pumpAndSettle();

    expect(captured?.draft.normalized().notes, isNull);
    expect(captured?.configurationChoices, isEmpty);
  });

  testWidgets('going back to "Not recorded" drops that pedal', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Easter 2026');
    await choose(tester, 1, 'Clean Boost');
    await choose(tester, 1, 'Not recorded');
    await tester.tap(find.widgetWithText(FilledButton, 'Take snapshot'));
    await tester.pumpAndSettle();

    expect(captured?.configurationChoices, isEmpty);
  });

  testWidgets('a snapshot has to be named before it is taken', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Take snapshot'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a name for this snapshot.'), findsOne);
    expect(captured, isNull);
  });

  testWidgets('a pedal with no configurations says so and cannot be set', (
    tester,
  ) async {
    await pumpForm(tester);

    expect(find.text('This pedal has no configurations to record'), findsOne);
    final field = tester.widget<DropdownButtonFormField<int?>>(
      find.byType(DropdownButtonFormField<int?>).first,
    );
    expect(field.onChanged, isNull);
  });

  testWidgets('a save in flight cannot be asked for twice', (tester) async {
    await pumpForm(tester, isSaving: true);

    await tester.enterText(find.byType(TextFormField).first, 'Easter 2026');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOne);
    expect(captured, isNull);
  });
}
