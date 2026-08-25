import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/features/backup/data/backup_upgrades.dart';

/// Reading a backup an older version of the app wrote: what is filled in, what is
/// worked out, and what is left empty because the file never said.
void main() {
  /// A file from before v11, when a chain was slots holding pedals and nothing
  /// else. The categories are chosen for what they become: one named the same, one
  /// named differently, and one with no block of its own.
  Map<String, dynamic> atV10() => {
    'pedals': [
      {'id': 1, 'name': 'PureSky', 'category': 'overdrive'},
      {'id': 2, 'name': 'NS-2', 'category': 'noiseGate'},
      {'id': 3, 'name': 'Line Selector', 'category': 'other'},
    ],
    'slots': [
      {'id': 7, 'pedalboardId': 1, 'pedalId': 2, 'position': 0},
      {'id': 8, 'pedalboardId': 1, 'pedalId': 1, 'position': 1},
      {'id': 9, 'pedalboardId': 1, 'pedalId': 3, 'position': 2},
    ],
  };

  List<Map<String, dynamic>> blocksOf(Map<String, dynamic> tables) {
    return (tables['signalBlocks'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  test('a current file is handed back untouched', () async {
    final tables = {'pedals': const <dynamic>[]};

    expect(
      upgradeBackupTables(tables, from: currentSchemaVersion),
      same(tables),
    );
  });

  test('a table a version never had arrives empty', () async {
    // Rows invented for it would be gear the user never entered.
    final tables = upgradeBackupTables({
      'pedals': const <dynamic>[],
    }, from: oldestReadableSchemaVersion);

    expect(tables['patches'], isEmpty);
    expect(tables['scenes'], isEmpty);
    expect(tables['scenePedals'], isEmpty);
    expect(tables['sceneValues'], isEmpty);
  });

  test('what the file already holds is left alone', () async {
    final tables = upgradeBackupTables({
      'pedals': const <dynamic>[],
      'patches': [
        {'id': 1},
      ],
      'scenes': const <dynamic>[],
      'scenePedals': const <dynamic>[],
      'sceneValues': const <dynamic>[],
    }, from: oldestReadableSchemaVersion);

    expect(tables['patches'], hasLength(1));
  });

  group('a chain of slots read as blocks', () {
    test('each slot becomes the block it always was', () async {
      final tables = upgradeBackupTables(atV10(), from: 10);

      // Ids kept, so anything in the file pointing at a slot still finds it.
      expect([for (final block in blocksOf(tables)) block['id']], [7, 8, 9]);
      expect(
        [for (final block in blocksOf(tables)) block['position']],
        [0, 1, 2],
      );
      expect(
        [for (final block in blocksOf(tables)) block['pedalId']],
        [2, 1, 3],
      );
      expect(tables['slots'], isNull);
    });

    test('the type comes off the pedal the slot held', () async {
      final tables = upgradeBackupTables(atV10(), from: 10);

      expect(
        [for (final block in blocksOf(tables)) block['blockType']],
        ['gate', 'overdrive', 'custom'],
      );
    });

    test('every block is enabled, since nothing recorded a bypass', () async {
      final tables = upgradeBackupTables(atV10(), from: 10);

      expect(
        blocksOf(tables).every((block) => block['isEnabled'] == true),
        isTrue,
      );
    });

    test('there are no cables, so the chain runs straight through', () async {
      // Which is what every rig in an older file did.
      expect(
        upgradeBackupTables(atV10(), from: 10)['signalConnections'],
        isEmpty,
      );
    });

    test('a slot pointing at a pedal the file lost has no type', () async {
      final tables = atV10();
      (tables['pedals'] as List<dynamic>).removeWhere(
        (pedal) => (pedal as Map<String, dynamic>)['id'] == 1,
      );

      // Left for decodeVaultBackup to refuse as damaged: the restore would have
      // been refused by the foreign key anyway, and guessing a type would be
      // inventing one.
      final orphan = blocksOf(
        upgradeBackupTables(tables, from: 10),
      ).firstWhere((block) => block['pedalId'] == 1);
      expect(orphan['blockType'], isNull);
    });

    test('the oldest readable file is walked all the way forward', () async {
      // One branch per version, in order, so a file from the floor picks up both
      // the tables v9 added and the blocks v11 made.
      final tables = upgradeBackupTables(
        atV10(),
        from: oldestReadableSchemaVersion,
      );

      expect(tables['patches'], isEmpty);
      expect(blocksOf(tables), hasLength(3));
      expect(tables['signalConnections'], isEmpty);
      expect(tables['signalEndpoints'], isEmpty);
    });
  });

  test('a rig from before endpoints says nothing about its edges', () async {
    // Not a guitar and an amplifier filled in on the user's behalf: an older file
    // never recorded which amp or desk a rig ended at, and a guess would read as
    // something they had said.
    expect(upgradeBackupTables(atV10(), from: 11)['signalEndpoints'], isEmpty);
  });

  test('a snapshot from before bypass was recorded reads as switched on', () {
    final tables = upgradeBackupTables({
      ...atV10(),
      'snapshots': [
        {'id': 1, 'pedalboardId': 1, 'name': 'Easter 2026'},
      ],
      'snapshotEntries': [
        {'id': 5, 'snapshotId': 1, 'pedalId': 1, 'position': 0},
      ],
    }, from: 12);

    // The same value the migration gives a row already on a phone: a snapshot
    // recorded the pedals on the board, and nothing recorded a bypass. Without it
    // the row would not decode at all, the column being one a row must carry.
    final entries = (tables['snapshotEntries'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(entries.single['isEnabled'], isTrue);
    expect(entries.single['position'], 0);
    // The snapshot itself needs nothing filling in: where the rig reached is left
    // unsaid, and a nullable column reads a missing key as exactly that.
    final snapshots = (tables['snapshots'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(snapshots.single.containsKey('endpointSummary'), isFalse);
  });
}
