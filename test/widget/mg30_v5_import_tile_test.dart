import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/devices/nux_mg30_v5/presentation/mg30_v5_import_file_tile.dart';

import '../support/mg30_v5_patch_fixture.dart';
import '../support/repositories.dart';

/// Importing a QuickTone export from the screen the user reaches it from.
///
/// What it has to get right is the reporting: the count comes from what was
/// written to the library, and a file that is not an MG-30 export is refused in
/// words rather than counted as a success.
void main() {
  const profile = NuxMg30V5Profile();
  late AppDatabase database;
  late int unitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await midiDeviceLinkRepository(
      database,
    ).createLinkedGear(profile);
  });

  tearDown(() => database.close());

  Future<void> pumpTile(WidgetTester tester, Uint8List? bytes) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Mg30V5ImportFileTile(
              unitId: unitId,
              chooser: () async => bytes,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
  }

  testWidgets('reports what reached the library, and the library holds it', (
    tester,
  ) async {
    await pumpTile(
      tester,
      mg30V5PatchFile([
        mg30V5PatchRecord(slot: 0),
        mg30V5PatchRecord(slot: 1, sceneNames: const ['CT-DriveJCM']),
      ]),
    );

    expect(find.text('Imported 2 patch(es).'), findsOneWidget);
    // In the order the slots were read, which is the order they are on the unit.
    final patches = await database.patchDao.patchesOf(unitId);
    expect(patches.map((patch) => patch.name), [
      'CT-RectoBeast',
      'CT-DriveJCM',
    ]);
  });

  testWidgets('refuses a file that is not an MG-30 export', (tester) async {
    await pumpTile(tester, Uint8List(64));

    expect(find.textContaining('not a whole number'), findsOneWidget);
    expect(await database.patchDao.patchesOf(unitId), isEmpty);
  });

  testWidgets('backing out of the picker changes nothing', (tester) async {
    await pumpTile(tester, null);

    expect(find.text('Imported 0 patch(es).'), findsNothing);
    expect(await database.patchDao.patchesOf(unitId), isEmpty);
  });
}
