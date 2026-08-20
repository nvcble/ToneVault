import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/backup/data/backup_document.dart';
import 'package:tone_vault/features/backup/providers/backup_providers.dart';
import 'package:tone_vault/features/settings/screens/settings_screen.dart';
import '../support/repositories.dart';
import '../support/vault_fixture.dart';

/// Backing up and restoring from the settings screen: what the share sheet is
/// handed, and what the user is asked before their gear is replaced.
void main() {
  late AppDatabase database;

  /// A backup of the filled vault, as if it had been taken this morning.
  late String file;

  /// The file the picker returns, and what the share sheet was handed.
  String? chosen;
  ({String contents, String fileName})? sent;
  Object? shareFails;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await fillVault(database);
    chosen = null;
    sent = null;
    shareFails = null;

    // A local time, so the date the dialog reads out is the same everywhere.
    file = (await backupRepository(
      database,
      clock: () => DateTime(2026, 8, 20, 7, 15),
    ).exportVault()).contents;
  });

  tearDown(() => database.close());

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          backupSenderProvider.overrideWithValue((
            String contents, {
            required String fileName,
          }) async {
            if (shareFails != null) {
              throw shareFails!;
            }
            sent = (contents: contents, fileName: fileName);
          }),
          backupChooserProvider.overrideWithValue(() async => chosen),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Gear bought after the backup was taken, so a restore has something to undo.
  Future<void> addFlashback() => database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Flashback',
          type: PedalType.digital,
          category: PedalCategory.delay,
          createdAt: DateTime.utc(2026, 8, 20),
          updatedAt: DateTime.utc(2026, 8, 20),
        ),
      );

  Future<List<String>> pedalNames() async {
    final rows = await database.backupDao.readEverything();
    return [for (final pedal in rows.pedals) pedal.name];
  }

  Future<void> tapRestore(WidgetTester tester) async {
    await tester.tap(find.text('Restore from a backup'));
    await tester.pumpAndSettle();
  }

  testWidgets('backing up hands the whole vault over, named', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Back up everything'));
    await tester.pumpAndSettle();

    expect(
      sent?.fileName,
      matches(RegExp(r'^tonevault-backup-\d{4}-\d{2}-\d{2}\.json$')),
    );
    // Everything, not just the pedals: this is the file they will restore from.
    final backup = decodeVaultBackup(sent!.contents);
    expect(backup.rows.pedals, hasLength(2));
    expect(backup.rows.snapshotValues, hasLength(1));
  });

  testWidgets('a share sheet that will not open says so', (tester) async {
    shareFails = const AppFailure('Could not pass the backup on to be saved.');
    await pumpSettings(tester);

    await tester.tap(find.text('Back up everything'));
    await tester.pumpAndSettle();

    expect(find.text('Could not pass the backup on to be saved.'), findsOne);
    // The tile is ready to be tried again rather than stuck spinning.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('restoring names the backup, and takes Cancel for an answer', (
    tester,
  ) async {
    chosen = file;
    await addFlashback();
    await pumpSettings(tester);

    await tapRestore(tester);

    expect(find.text('Replace everything?'), findsOne);
    // The particular file, so the user is agreeing to a known day of gear.
    expect(
      find.textContaining(
        'Taken 2026-08-20 07:15, with 2 pedals, 1 rig and 1 snapshot in it.',
      ),
      findsOne,
    );
    expect(find.textContaining('cannot be undone'), findsOne);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(await pedalNames(), contains('Flashback'));
  });

  testWidgets('agreeing replaces the vault and says what came back', (
    tester,
  ) async {
    chosen = file;
    await addFlashback();
    await pumpSettings(tester);
    await tapRestore(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Replace everything'));
    await tester.pumpAndSettle();

    expect(find.text('Restored 2 pedals, 1 rig and 1 snapshot.'), findsOne);
    // Replaced, not merged: the pedal bought since is gone with the rest.
    expect(await pedalNames(), ['Caline PureSky', 'Boss SD-1']);
  });

  testWidgets('backing out of the picker changes nothing and says nothing', (
    tester,
  ) async {
    await database
        .update(database.pedalboards)
        .write(const PedalboardsCompanion(name: Value('Fly Rig')));
    await pumpSettings(tester);

    // chosen stays null: the user closed the picker without choosing a file.
    await tapRestore(tester);

    expect(find.text('Replace everything?'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    final rows = await database.backupDao.readEverything();
    expect(rows.pedalboards.single.name, 'Fly Rig');
  });

  testWidgets('a file that is not a backup is refused without asking', (
    tester,
  ) async {
    chosen = 'a holiday photo';
    await pumpSettings(tester);

    await tapRestore(tester);

    expect(find.text('That file is not a ToneVault backup.'), findsOne);
    // Nothing worth confirming, so the question is never put.
    expect(find.text('Replace everything?'), findsNothing);
  });
}
