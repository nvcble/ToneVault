import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/rig_snapshot_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/snapshots/providers/snapshot_providers.dart';
import 'package:tone_vault/features/snapshots/widgets/snapshot_chain_view.dart';
import 'package:tone_vault/features/snapshots/widgets/snapshot_entry_tile.dart';

/// Reading a snapshot back: the chain as it stood, and every knob in its own
/// notation.
///
/// What gets copied at capture is rig_snapshot_capture_test.dart's job in
/// test/database; here the question is how the copies read.
void main() {
  const snapshotId = 1;
  final moment = DateTime.utc(2026, 4, 5, 9, 30);
  var nextValueId = 100;

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

  RigSnapshotValue reading(
    int entryId,
    String controlName,
    ControlType type,
    double value, {
    String? unit,
    List<String> options = const [],
    int displayOrder = 0,
  }) {
    return RigSnapshotValue(
      id: nextValueId++,
      entryId: entryId,
      controlName: controlName,
      controlType: type,
      value: value,
      unit: unit,
      options: encodeControlOptions(options),
      displayOrder: displayOrder,
    );
  }

  SnapshotEntry entry(
    int id,
    Pedal pedal,
    int position, {
    String? configurationName,
    List<RigSnapshotValue> values = const [],
  }) {
    return (
      entry: RigSnapshotEntry(
        id: id,
        snapshotId: snapshotId,
        pedalId: pedal.id,
        position: position,
        configurationName: configurationName,
      ),
      pedal: pedal,
      values: values,
    );
  }

  final wah = pedal(1, 'Vox Wah');
  final drive = pedal(2, 'Caline PureSky');

  /// A wah with nothing worth recording, then a drive with three readings.
  final entries = [
    entry(10, wah, 0),
    entry(
      11,
      drive,
      1,
      configurationName: 'Worship Lead',
      values: [
        reading(11, 'Gain', ControlType.clock, 0.7),
        reading(11, 'Level', ControlType.percentage, 40, displayOrder: 1),
        reading(
          11,
          'Voice',
          ControlType.selection,
          1,
          options: const ['Vintage', 'Modern'],
          displayOrder: 2,
        ),
      ],
    ),
  ];

  Future<void> pumpChain(
    WidgetTester tester,
    Stream<List<SnapshotEntry>> entries,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          snapshotEntriesProvider(snapshotId).overrideWith((ref) => entries),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SnapshotChainView(snapshotId: snapshotId)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reads the rig out in the order signal ran through it', (
    tester,
  ) async {
    await pumpChain(tester, Stream.value(entries));

    expect(
      tester
          .widgetList<SnapshotEntryTile>(find.byType(SnapshotEntryTile))
          .map((tile) => tile.entry.pedal.name),
      ['Vox Wah', 'Caline PureSky'],
    );
    expect(find.text('1'), findsOne);
    expect(find.text('2'), findsOne);
  });

  testWidgets('every reading is shown in its own notation', (tester) async {
    await pumpChain(tester, Stream.value(entries));

    expect(find.text('Worship Lead'), findsOne);
    // A knob reads as a clock position, a digital control as a number, and a
    // switch as the position it was on.
    expect(find.text('2:00'), findsOne);
    expect(find.text('40%'), findsOne);
    expect(find.text('Modern'), findsOne);
  });

  testWidgets('a pedal captured with nothing dialled in says so', (
    tester,
  ) async {
    await pumpChain(tester, Stream.value(entries));

    // The wah was on the board and that is all the snapshot claims.
    expect(find.text('Settings not recorded'), findsOne);
  });

  testWidgets('an empty snapshot says there is nothing to read', (
    tester,
  ) async {
    await pumpChain(tester, Stream.value(const []));

    expect(find.text('This snapshot has no pedals in it'), findsOne);
  });

  testWidgets('keeps a failure readable', (tester) async {
    await pumpChain(
      tester,
      Stream<List<SnapshotEntry>>.error(Exception('disk')),
    );

    expect(find.text('Could not read this snapshot'), findsOne);
    expect(find.textContaining('disk'), findsNothing);
  });
}
