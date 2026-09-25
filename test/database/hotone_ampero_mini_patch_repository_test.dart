import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'saveSynced stores raw bytes even when a name could not be decoded',
    () async {
      final repository = hotoneAmperoMiniPatchRepository(database);

      await repository.saveSynced(
        patchNumber: 5,
        rawSysEx: Uint8List.fromList([0xF0, 0x21, 0x25, 0xF7]),
        clock: () => DateTime.utc(2026, 9, 16),
      );

      final patches = await repository.watchPatches().first;
      expect(patches.single.patchNumber, 5);
      expect(patches.single.name, isNull);
      expect(patches.single.rawSysEx, [0xF0, 0x21, 0x25, 0xF7]);
      expect(patches.single.lastSyncedAt, DateTime.utc(2026, 9, 16));
      expect(patches.single.syncState, 'synced');
      expect(patches.single.locallyModified, isFalse);
    },
  );

  test('a second sync of the same patch number replaces the first', () async {
    final repository = hotoneAmperoMiniPatchRepository(database);
    await repository.saveSynced(
      patchNumber: 5,
      rawSysEx: Uint8List.fromList([0x00]),
    );

    await repository.saveSynced(
      patchNumber: 5,
      name: 'Clean Worship',
      rawSysEx: Uint8List.fromList([0x01]),
    );

    final patches = await repository.watchPatches().first;
    expect(patches, hasLength(1));
    expect(patches.single.name, 'Clean Worship');
    expect(patches.single.rawSysEx, [0x01]);
  });

  test('two device profiles never see each other\'s patches', () async {
    final ampero = hotoneAmperoMiniPatchRepository(database);
    final other = hotoneAmperoMiniPatchRepository(
      database,
      deviceProfileId: 'some_other_device',
    );

    await ampero.saveSynced(
      patchNumber: 1,
      rawSysEx: Uint8List.fromList([0x00]),
    );

    expect(await ampero.watchPatches().first, hasLength(1));
    expect(await other.watchPatches().first, isEmpty);
  });

  test('findByPatchNumber is null until that slot has been synced', () async {
    final repository = hotoneAmperoMiniPatchRepository(database);

    expect(await repository.findByPatchNumber(9), isNull);
  });

  test(
    'setLocallyModified flips the flag without touching sync state',
    () async {
      final repository = hotoneAmperoMiniPatchRepository(database);
      await repository.saveSynced(
        patchNumber: 5,
        rawSysEx: Uint8List.fromList([0x00]),
      );

      await repository.setLocallyModified(5, true);

      final patch = await repository.findByPatchNumber(5);
      expect(patch!.locallyModified, isTrue);
      expect(patch.syncState, 'synced');
    },
  );
}
