import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedalboard_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/snapshots/providers/snapshot_providers.dart';
import 'package:tone_vault/features/snapshots/widgets/rig_snapshots_view.dart';
import 'package:tone_vault/features/snapshots/widgets/snapshot_card.dart';

/// A rig's snapshots as they read, and when taking one is offered at all.
void main() {
  const pedalboardId = 4;

  RigSnapshot snapshot(
    int id,
    String name,
    DateTime capturedAt, {
    String? notes,
  }) {
    return RigSnapshot(
      id: id,
      pedalboardId: pedalboardId,
      name: name,
      notes: notes,
      capturedAt: capturedAt,
    );
  }

  // Local times: the cards read a snapshot back on the user's own clock, so a
  // UTC moment here would print differently depending on where the test runs.
  final easter = snapshot(
    1,
    'Easter 2026',
    DateTime(2026, 4, 5, 9, 30),
    notes: 'Second service, quieter mix',
  );
  final friday = snapshot(2, 'Friday rehearsal', DateTime(2026, 8, 14, 19));

  final onePedal = <ChainSlot>[
    (
      slot: const PedalboardSlot(
        id: 10,
        pedalboardId: pedalboardId,
        pedalId: 1,
        position: 0,
      ),
      pedal: Pedal(
        id: 1,
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
        status: PedalStatus.active,
        createdAt: DateTime.utc(2026, 8, 19, 12),
        updatedAt: DateTime.utc(2026, 8, 19, 12),
      ),
    ),
  ];

  /// The snapshots tab over a rig holding [chain], with [snapshots] taken of it.
  Future<void> pumpSnapshots(
    WidgetTester tester, {
    Stream<List<RigSnapshot>>? snapshots,
    List<ChainSlot> chain = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rigSnapshotsProvider(
            pedalboardId,
          ).overrideWith((ref) => snapshots ?? Stream.value(const [])),
          rigChainProvider(
            pedalboardId,
          ).overrideWith((ref) => Stream.value(chain)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: RigSnapshotsView(pedalboardId: pedalboardId)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Whether "Take a snapshot" can be pressed.
  bool captureOffered(WidgetTester tester) {
    return tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Take a snapshot'),
            )
            .onPressed !=
        null;
  }

  testWidgets('says what a snapshot is for when none have been taken', (
    tester,
  ) async {
    await pumpSnapshots(tester, chain: onePedal);

    expect(find.text('No snapshots of this rig yet'), findsOne);
    expect(find.textContaining('the day you played it'), findsOne);
    expect(captureOffered(tester), isTrue);
  });

  testWidgets('an empty rig is asked for pedals rather than a snapshot', (
    tester,
  ) async {
    await pumpSnapshots(tester);

    expect(find.textContaining('Build the chain first'), findsOne);
    // The repository refuses an empty rig, so the button says so by being off
    // rather than by failing when pressed.
    expect(captureOffered(tester), isFalse);
  });

  testWidgets('lists snapshots newest first, with the time of day', (
    tester,
  ) async {
    await pumpSnapshots(
      tester,
      snapshots: Stream.value([friday, easter]),
      chain: onePedal,
    );

    expect(
      tester
          .widgetList<SnapshotCard>(find.byType(SnapshotCard))
          .map((card) => card.snapshot.name),
      ['Friday rehearsal', 'Easter 2026'],
    );
    // Two snapshots can share a name and a date, so the time is shown too.
    expect(find.textContaining('2026-08-14 19:00'), findsOne);
    expect(find.textContaining('Second service, quieter mix'), findsOne);
  });

  testWidgets('keeps a failure readable', (tester) async {
    await pumpSnapshots(
      tester,
      snapshots: Stream<List<RigSnapshot>>.error(Exception('disk')),
      chain: onePedal,
    );

    expect(find.text('Could not load the snapshots'), findsOne);
    expect(find.textContaining('disk'), findsNothing);
  });
}
