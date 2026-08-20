import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedalboard_dao.dart';
import 'package:tone_vault/core/database/daos/rig_snapshot_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/snapshots/providers/snapshot_providers.dart';
import '../support/app_tabs.dart';

/// Getting to a snapshot and back out of it: the rig's list, the snapshot
/// itself, and renaming or removing one. Every stream is a plain value, so no
/// database is involved.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  final worship = Pedalboard(
    id: 4,
    name: 'Hybrid Worship Rig',
    description: 'MG-30 into the desk',
    createdAt: moment,
    updatedAt: moment,
  );

  final drive = Pedal(
    id: 7,
    name: 'Caline PureSky',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: PedalStatus.active,
    createdAt: moment,
    updatedAt: moment,
  );

  // A local time, since a snapshot reads back on the user's own clock.
  final easter = RigSnapshot(
    id: 1,
    pedalboardId: worship.id,
    name: 'Easter 2026',
    notes: 'Second service, quieter mix',
    capturedAt: DateTime(2026, 4, 5, 9, 30),
  );

  final captured = <SnapshotEntry>[
    (
      entry: RigSnapshotEntry(
        id: 10,
        snapshotId: easter.id,
        pedalId: drive.id,
        position: 0,
        configurationName: 'Worship Lead',
      ),
      pedal: drive,
      values: [
        RigSnapshotValue(
          id: 100,
          entryId: 10,
          controlName: 'Gain',
          controlType: ControlType.clock,
          value: 0.7,
          displayOrder: 0,
        ),
      ],
    ),
  ];

  final chain = <ChainSlot>[
    (
      slot: PedalboardSlot(
        id: 20,
        pedalboardId: worship.id,
        pedalId: drive.id,
        position: 0,
      ),
      pedal: drive,
    ),
  ];

  /// Opens the snapshots tab of the one rig, with [easter] already taken.
  Future<void> pumpSnapshotsTab(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalboardListProvider.overrideWith((ref) => Stream.value([worship])),
          // The app opens on the home tab, which counts the pedals too.
          pedalListProvider.overrideWith((ref) => Stream.value(<Pedal>[drive])),
          pedalboardProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(worship)),
          rigChainProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value(chain)),
          rigSnapshotsProvider(
            worship.id,
          ).overrideWith((ref) => Stream.value([easter])),
          rigSnapshotProvider(
            easter.id,
          ).overrideWith((ref) => Stream.value(easter)),
          snapshotEntriesProvider(
            easter.id,
          ).overrideWith((ref) => Stream.value(captured)),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    await openTab(tester, 'Rigs');
    await tester.tap(find.text('Hybrid Worship Rig'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Snapshots'));
    await tester.pumpAndSettle();
  }

  testWidgets('a snapshot opens on what the rig was set to', (tester) async {
    await pumpSnapshotsTab(tester);

    await tester.tap(find.text('Easter 2026'));
    await tester.pumpAndSettle();

    expect(find.text('Taken 2026-04-05 09:30'), findsOne);
    expect(find.text('Second service, quieter mix'), findsOne);
    // The pedal, the configuration it was on, and where its knob sat.
    expect(find.text('Caline PureSky'), findsOne);
    expect(find.text('Worship Lead'), findsOne);
    expect(find.text('2:00'), findsOne);
    // Nested under the rigs tab, so the tabs stay put.
    expect(find.byType(NavigationBar), findsOne);
  });

  testWidgets('renaming opens on what the snapshot already says', (
    tester,
  ) async {
    await pumpSnapshotsTab(tester);
    await tester.tap(find.text('Easter 2026'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit snapshot'), findsOne);
    expect(find.widgetWithText(TextFormField, 'Easter 2026'), findsOne);
    expect(
      find.widgetWithText(TextFormField, 'Second service, quieter mix'),
      findsOne,
    );
    // What was played is not up for editing, and the screen says so.
    expect(find.textContaining('stay as they were recorded'), findsOne);
  });

  testWidgets('deleting asks first, and says what it will not touch', (
    tester,
  ) async {
    await pumpSnapshotsTab(tester);
    await tester.tap(find.text('Easter 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete snapshot?'), findsOne);
    // Named, so it is clear which day is about to go.
    expect(find.textContaining('how the rig stood for Easter 2026'), findsOne);
    expect(
      find.textContaining('The rig and its pedals are untouched'),
      findsOne,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Cancelled, so the snapshot is still there to be renamed.
    expect(find.text('Edit snapshot'), findsOne);
  });
}
