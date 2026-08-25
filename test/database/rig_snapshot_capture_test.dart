import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedalboards/data/signal_endpoint_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/snapshots/data/snapshot_draft.dart';
import '../support/repositories.dart';

/// Taking a snapshot of a rig: what gets copied, in what order, and what a stale
/// screen is not allowed to record.
void main() {
  late AppDatabase database;
  late int rigId;
  final captured = DateTime.utc(2026, 4, 5, 9, 30);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(Object message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> addPedal(String name) async {
    final pedalId = await pedalRepository(database).createPedal(
      PedalDraft(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    await signalChainRepository(database).addBlock(
      pedalboardId: rigId,
      blockType: SignalBlockType.overdrive,
      pedalId: pedalId,
    );
    return pedalId;
  }

  Future<int> addKnob(int pedalId, String name) {
    return controlRepository(database).createControl(
      pedalId,
      ControlDraft(
        name: name,
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
      ),
    );
  }

  Future<int> addConfiguration(
    int pedalId, {
    required String name,
    Map<int, double> values = const {},
  }) {
    return configurationRepository(database).createConfiguration(
      pedalId,
      ConfigurationDraft(name: name, values: values),
    );
  }

  Future<int> capture({
    String name = 'Easter 2026',
    String? notes,
    Map<int, int> choices = const {},
    int? onRig,
  }) {
    return rigSnapshotRepository(
      database,
      clock: () => captured,
    ).captureSnapshot(
      onRig ?? rigId,
      SnapshotDraft(name: name, notes: notes),
      configurationChoices: choices,
    );
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
  });

  tearDown(() => database.close());

  test('records the rig as it stands, with the date it was played', () async {
    await addPedal('Vox Wah');
    await addPedal('Caline PureSky');

    final snapshotId = await capture(notes: '  Second service  ');

    final snapshot = (await database.rigSnapshotDao.findSnapshot(snapshotId))!;
    expect(snapshot.name, 'Easter 2026');
    expect(snapshot.notes, 'Second service');
    expect(snapshot.capturedAt, captured);
    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;
    expect(
      [for (final entry in entries) entry.pedal.name],
      ['Vox Wah', 'Caline PureSky'],
    );
    expect([for (final entry in entries) entry.entry.position], [0, 1]);
  });

  test('copies the readings of the configuration each pedal was on', () async {
    final pedalId = await addPedal('Caline PureSky');
    final volumeId = await addKnob(pedalId, 'Volume');
    final toneId = await addKnob(pedalId, 'Tone');
    final configurationId = await addConfiguration(
      pedalId,
      name: 'Worship Lead',
      values: {volumeId: 0.75, toneId: 0.5},
    );

    final snapshotId = await capture(choices: {pedalId: configurationId});

    final entry =
        (await database.rigSnapshotDao.watchEntries(snapshotId).first).single;
    expect(entry.entry.configurationName, 'Worship Lead');
    expect(
      {for (final value in entry.values) value.controlName: value.value},
      {'Volume': 0.75, 'Tone': 0.5},
    );
  });

  test('a later re-tweak cannot rewrite what was recorded', () async {
    final pedalId = await addPedal('Caline PureSky');
    final volumeId = await addKnob(pedalId, 'Volume');
    final configurationId = await addConfiguration(
      pedalId,
      name: 'Worship Lead',
      values: {volumeId: 0.75},
    );
    final snapshotId = await capture(choices: {pedalId: configurationId});

    // The whole point of copying rather than referencing: turning the knob up
    // next week does not change what was played at Easter.
    await configurationValueRepository(database).setValue(
      configurationId: configurationId,
      controlId: volumeId,
      value: 0.9,
    );

    final entry =
        (await database.rigSnapshotDao.watchEntries(snapshotId).first).single;
    expect(entry.values.single.value, 0.75);
  });

  test('a renamed configuration keeps the name it had that day', () async {
    final pedalId = await addPedal('Caline PureSky');
    final configurationId = await addConfiguration(pedalId, name: 'Lead');
    final snapshotId = await capture(choices: {pedalId: configurationId});

    await configurationRepository(database).updateConfiguration(
      configurationId,
      const ConfigurationDraft(name: 'Worship Lead'),
    );

    final entry =
        (await database.rigSnapshotDao.watchEntries(snapshotId).first).single;
    expect(entry.entry.configurationName, 'Lead');
  });

  test('a pedal left out of the choices is captured with nothing on', () async {
    final wahId = await addPedal('Vox Wah');
    await addKnob(wahId, 'Sweep');

    final snapshotId = await capture();

    // A wah has no preset worth recording, and it was still on the board.
    final entry =
        (await database.rigSnapshotDao.watchEntries(snapshotId).first).single;
    expect(entry.entry.configurationName, isNull);
    expect(entry.values, isEmpty);
  });

  test(
    'records the chain in the order signal runs, not the order it sits',
    () async {
      await addPedal('Vox Wah');
      await addPedal('Caline PureSky');
      await addPedal('Flashback');
      final blocks = await database.signalChainDao.blocksOf(rigId);
      // The wah is patched into after the drive rather than before it, so it is no
      // longer first in line even though it is still the first row of the chain.
      await signalRoutingRepository(
        database,
      ).connect(sourceBlockId: blocks[1].id, targetBlockId: blocks[0].id);

      final snapshotId = await capture();

      // A snapshot copied off the rows would read the guitar into the wah, which is
      // a rig nobody played.
      final entries = await database.rigSnapshotDao
          .watchEntries(snapshotId)
          .first;
      expect(
        [for (final entry in entries) entry.pedal.name],
        ['Caline PureSky', 'Flashback', 'Vox Wah'],
      );
      expect([for (final entry in entries) entry.entry.position], [0, 1, 2]);
    },
  );

  test('records a pedal that was switched off as switched off', () async {
    await addPedal('Vox Wah');
    await addPedal('Caline PureSky');
    final blocks = await database.signalChainDao.blocksOf(rigId);
    await signalChainRepository(
      database,
    ).setEnabled(blockId: blocks.first.id, isEnabled: false);

    final snapshotId = await capture();

    // Kept rather than left out: the wah was on the board with its footswitch up,
    // which is part of how the rig was set that day.
    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;
    expect(
      {for (final entry in entries) entry.pedal.name: entry.entry.isEnabled},
      {'Vox Wah': false, 'Caline PureSky': true},
    );
  });

  test('records where the rig reached, in the words the chain read', () async {
    await addPedal('Caline PureSky');
    final outputId = await signalChainRepository(
      database,
    ).addBlock(pedalboardId: rigId, blockType: SignalBlockType.output);
    await signalEndpointRepository(database).describe(
      blockId: outputId,
      draft: const SignalEndpointDraft(
        destination: SignalDestination.foh,
        gear: 'Behringer X32',
      ),
    );

    final snapshotId = await capture();

    // Copied as text: the desk can be swapped for an amplifier tomorrow without
    // rewriting where this rig went.
    final snapshot = (await database.rigSnapshotDao.findSnapshot(snapshotId))!;
    expect(snapshot.endpointSummary, 'To Front of house · Behringer X32');
    // And the block itself is not an entry: it held no pedal.
    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;
    expect(entries.single.pedal.name, 'Caline PureSky');
  });

  test('a rig that never said where it goes records nothing about it', () async {
    await addPedal('Caline PureSky');

    final snapshotId = await capture();

    // Null rather than a guessed amplifier, which is most rigs and no kind of gap.
    expect(
      (await database.rigSnapshotDao.findSnapshot(snapshotId))!.endpointSummary,
      isNull,
    );
  });

  test('refuses a snapshot with no name', () async {
    await addPedal('Vox Wah');

    await expectLater(
      capture(name: '   '),
      failsWith('Enter a name for this snapshot.'),
    );
    expect(await database.rigSnapshotDao.watchSnapshots(rigId).first, isEmpty);
  });

  test('refuses to record an empty rig', () async {
    // A snapshot of nothing answers no question later on.
    await expectLater(
      capture(),
      failsWith(
        'There is nothing on Hybrid Worship Rig to record yet. Add some pedals '
        'to the rig first.',
      ),
    );
  });

  test('refuses a configuration that is not on its pedal', () async {
    final driveId = await addPedal('Caline PureSky');
    final delayId = await addPedal('Flashback');
    final belongsToDelay = await addConfiguration(delayId, name: 'Slapback');

    await expectLater(
      capture(choices: {driveId: belongsToDelay}),
      failsWith(contains('no longer on its pedal')),
    );
    // Nothing half-written: the refusal comes before the snapshot row.
    expect(await database.rigSnapshotDao.watchSnapshots(rigId).first, isEmpty);
  });

  test('refuses a pedal that has come off the rig', () async {
    final pedalId = await addPedal('Caline PureSky');
    final configurationId = await addConfiguration(pedalId, name: 'Lead');
    await addPedal('Vox Wah');
    final blocks = await database.signalChainDao.blocksOf(rigId);
    await signalChainRepository(
      database,
    ).removeBlock(blocks.firstWhere((block) => block.pedalId == pedalId).id);

    await expectLater(
      capture(choices: {pedalId: configurationId}),
      failsWith(contains('no longer on this rig')),
    );
  });

  test('says so when the rig is already gone', () async {
    await expectLater(
      capture(onRig: 404),
      failsWith('That rig no longer exists.'),
    );
  });
}
