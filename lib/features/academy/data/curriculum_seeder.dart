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
/// It is safe to run every time because it keeps what is already stored. A course
/// found under its slug is left alone - not refreshed, not re-positioned - so a
/// player half-way through one loses nothing to having closed the app. Correcting a
/// course that has already shipped is therefore not this class's job; that is an
/// import, which the user makes and is told about.
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

  /// Returns how many courses were written, which is zero on all but the first
  /// launch after an install or an update that added some.
  ///
  /// A file that will not read stops the seeding and says so. It is not caught here:
  /// the only way one of these can be wrong is that it shipped wrong, which is a
  /// thing to see in a test rather than to survive quietly with half an Academy.
  /// Each file is its own transaction, so what has already been written stands.
  Future<int> seed() async {
    var added = 0;
    for (final asset in assets) {
      final result = await _importer.importFile(
        await _bundle.loadString(asset),
        onConflict: CurriculumConflict.keep,
      );
      added += result.added;
    }
    return added;
  }
}
