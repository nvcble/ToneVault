import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'curriculum_assets.dart';
import 'curriculum_importer.dart';

/// Puts the curriculum the app ships with into the Academy.
///
/// Runs at every launch rather than once, because "once" has nowhere to be recorded
/// that survives what has to survive: a phone restored from a backup written before
/// the Academy existed comes back with no courses in it, and an app updated to a
/// version that teaches something new has courses the old one never had. Both are
/// launches where there is seeding to do.
///
/// A course already stored under its slug is brought up to what the file says rather
/// than skipped. Skipping was the older behaviour and it meant a lesson, module or
/// exercise added to a shipped file only ever reached a phone that had never run the
/// app - an update that teaches something new inside an existing course would never
/// be seen, which is not something a user can be expected to work out or to fix by
/// hand.
///
/// That is safe because the writer matches by slug and writes in place: the
/// lesson rows a player's practice and progress hang off keep their ids. What the
/// file no longer teaches is removed, which is the point - the shipped courses are
/// the app's to define, and an import the user makes themselves is what adds to them.
class CurriculumSeeder {
  CurriculumSeeder(
    this._importer, {
    AssetBundle? bundle,
    this.assets = curriculumAssets,
  }) : _bundle = bundle ?? rootBundle;

  final CurriculumImporter _importer;

  /// Injectable so a test can hand over a curriculum without one having to be a
  /// declared asset of the app under test.
  final AssetBundle _bundle;

  /// The files to read, which are [curriculumAssets] everywhere but in a test.
  final List<String> assets;

  /// Returns how many courses were written, added and refreshed together, which is
  /// every shipped course on every launch.
  ///
  /// A file that will not read stops the seeding and says so. It is not caught here:
  /// the only way one of these can be wrong is that it shipped wrong, which is a
  /// thing to see in a test rather than to survive quietly with half an Academy.
  /// Each file is its own transaction, so what has already been written stands.
  Future<int> seed() async {
    var written = 0;
    for (final asset in assets) {
      final result = await _importer.importFile(
        await _bundle.loadString(asset),
        onConflict: CurriculumConflict.update,
      );
      written += result.added + result.updated;
    }
    return written;
  }
}
