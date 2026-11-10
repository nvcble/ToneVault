import 'package:drift/drift.dart';

/// `hotone_ampero_mini_favorites`, the Ampero Mini patch slots the user has
/// starred - see that table for why it is keyed by slot rather than by a
/// synced patch row.
///
/// Purely additive: one new table, no ALTER and no DROP. Character for
/// character what `createAll` writes on a new install, checked against a fresh
/// database by migration_test.dart.
Future<void> upgradeThroughV27(GeneratedDatabase database, int from) async {
  if (from < 27) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "hotone_ampero_mini_favorites" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"device_profile_id" TEXT NOT NULL, '
      '"patch_number" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      'UNIQUE ("device_profile_id", "patch_number"))',
    );
  }
}
