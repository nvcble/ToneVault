import '../../../core/database/migrations.dart';

/// The oldest backup file this app can still read.
///
/// Eight because that is where the export shipped: no released version of
/// ToneVault ever wrote a file saying less, so a file that claims to is not one
/// of ours. The floor is a fact about what went out, not a limit on what could be
/// converted.
const int oldestReadableSchemaVersion = 8;

/// Brings the tables of an older backup file up to the schema this app reads.
///
/// One branch per schema version, in ascending order, deliberately the same shape
/// as `buildMigrationStrategy`: a file is walked forward a version at a time
/// rather than special-cased per pair of versions, so the next schema adds one
/// branch here and leaves the rest alone.
///
/// A table that version never had arrives empty, which is the only honest
/// reading: rows invented for it would be gear the user never entered. A column
/// added later is the case to watch - it has to be filled in here with the same
/// value the migration gives a row that was already there, or the row will not
/// decode at all.
///
/// Only what the file is missing is filled in. A file that says it is current and
/// has a table missing is still a damaged file, and is refused as one.
Map<String, dynamic> upgradeBackupTables(
  Map<String, dynamic> tables, {
  required int from,
}) {
  if (from >= currentSchemaVersion) {
    return tables;
  }

  final upgraded = Map<String, dynamic>.of(tables);

  if (from < 9) {
    // v9 added the sounds of a multi-effects unit: its patches, their scenes, the
    // pedals in each scene and where those pedals' controls sit. A file from
    // before it has none of that, and there is nothing in it to work them out
    // from either.
    for (final table in const [
      'patches',
      'scenes',
      'scenePedals',
      'sceneValues',
    ]) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  if (from < 11) {
    // v11 turned each slot of a chain into a block of one, which needs a type
    // the file never carried. The same derivation the migration makes: every
    // slot held a pedal, so its type comes off that pedal's category, and it is
    // enabled because nothing recorded a bypass before this version.
    //
    // Ids are kept, exactly as the migration keeps them, so anything in the file
    // pointing at a slot still finds the block it became. Cables are new and a
    // chain without them runs straight through, which is what every rig in an
    // older file did.
    final slots = upgraded.remove('slots');
    if (slots is List) {
      upgraded['signalBlocks'] = [
        for (final slot in slots.whereType<Map<String, dynamic>>())
          {
            'id': slot['id'],
            'pedalboardId': slot['pedalboardId'],
            'pedalId': slot['pedalId'],
            'blockType': _blockTypes[_categoryOf(upgraded, slot['pedalId'])],
            'position': slot['position'],
            'isEnabled': true,
          },
      ];
    }
    upgraded.putIfAbsent('signalConnections', () => const <dynamic>[]);
  }

  if (from < 12) {
    // v12 let a rig say what its edges reach. A file from before it says nothing,
    // and nothing is the honest reading: a rig whose chain simply ran from the
    // first block to the last never recorded which amp or desk it ended at, and
    // inventing one would be putting words in the user's mouth.
    upgraded.putIfAbsent('signalEndpoints', () => const <dynamic>[]);
  }

  if (from < 13) {
    // v13 let a snapshot say which pedals were switched off, and where the rig
    // reached at either end. Each entry in an older file is read as enabled, the
    // same value the migration gives a row already on a phone: a snapshot
    // recorded the pedals on the board and nothing recorded a bypass. What the
    // edges reached is left unsaid, which needs no filling in - the column is
    // nullable, and null is what an old snapshot recorded.
    //
    // Still done, though nothing in the app reads a snapshot any more. A restore
    // is the only way those rows get back onto a phone, so this is the step that
    // decides whether they arrive whole or not at all.
    final entries = upgraded['snapshotEntries'];
    if (entries is List) {
      upgraded['snapshotEntries'] = [
        for (final entry in entries.whereType<Map<String, dynamic>>())
          {...entry, 'isEnabled': true},
      ];
    }
  }

  // v14 needs no step. The rigs feature went at that version and its tables
  // stayed, so a file from before it says exactly what a file from after it says.

  if (from < 15) {
    // v15 added the Academy. A file from before it has no curriculum and no
    // progress against one, and empty is right for both: the curriculum the app
    // ships with is seeded on first run, and a player who had no Academy has done
    // none of it.
    //
    // A restore is a replacement, so this does clear the curriculum the phone had
    // already seeded along with everything else. That is why the seeder checks
    // whether any course is stored every time the app opens rather than only on a
    // fresh install: the next launch after such a restore puts the curriculum back.
    for (final table in const [
      'academyCourses',
      'academyModules',
      'academyLessons',
      'academyExercises',
      'academyProgress',
      'academyBookmarks',
    ]) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  if (from < 17) {
    // v17 began recording which exercises the player got through and each sitting of
    // practice. Empty for both, which is what the migration does to a phone as well:
    // no file ever written said which exercise was ticked, and the practice in an
    // older file is a single total with no dates in it, so splitting it into sittings
    // would be inventing evenings.
    //
    // The total itself is on the progress row and comes across untouched, so a
    // restored lesson still says how long it was practised for - only in one line
    // rather than in a list.
    for (final table in const [
      'academyExerciseProgress',
      'academyPracticeSessions',
    ]) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  if (from < 18) {
    // v18 let a user remap a device's CC assignments and its patch-selection
    // strategy, the way NUX's own QuickTone app lets someone remap the MG-30
    // itself. A file from before it recorded no such thing, and empty is the
    // only honest reading: nobody had customized anything yet, because there
    // was nowhere to.
    for (final table in const [
      'midiParameterOverrides',
      'midiPatchSelectionSettings',
    ]) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  if (from < 19) {
    // v19 let a logged multi-effects unit be linked to a MIDI device profile,
    // and its patches and scenes given a program/scene number. A file from
    // before it has no such link, because there was nothing yet to link to.
    for (final table in const [
      'midiDeviceLinks',
      'midiPatchProgramNumbers',
      'midiSceneNumbers',
    ]) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  if (from < 20) {
    // v20 added the Patch Browser's favorites and "Recently Used" sections. A
    // file from before it recorded neither, because there was nowhere to.
    for (final table in const ['midiPatchFavorites', 'midiPatchRecents']) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  return upgraded;
}

/// The block type each pedal category became, frozen at v11.
///
/// A copy of `blockTypeFor` rather than a call to it, for the reason the SQL in
/// `buildMigrationStrategy` is frozen too: what an old file's rows are read as
/// must not change because the live mapping was edited later.
const Map<String, String> _blockTypes = {
  'tuner': 'tuner',
  'compressor': 'compressor',
  'equalizer': 'eq',
  'boost': 'boost',
  'overdrive': 'overdrive',
  'distortion': 'distortion',
  'fuzz': 'fuzz',
  'noiseGate': 'gate',
  'modulation': 'modulation',
  'chorus': 'chorus',
  'flanger': 'flanger',
  'phaser': 'phaser',
  'tremolo': 'tremolo',
  'delay': 'delay',
  'reverb': 'reverb',
  'ampSim': 'amp',
  'cabinetIr': 'cab',
  'multiEffects': 'multiEffect',
  'looper': 'looper',
  'utility': 'utility',
  'other': 'custom',
};

/// The category of the pedal a slot held, or null where the file does not say.
///
/// Null falls through to no block type at all, which `decodeVaultBackup` refuses
/// as a damaged file - a slot pointing at a pedal that is not in the backup is
/// one, and the restore would have been refused by the foreign key anyway.
String? _categoryOf(Map<String, dynamic> tables, Object? pedalId) {
  final pedals = tables['pedals'];
  if (pedals is! List) return null;

  for (final pedal in pedals.whereType<Map<String, dynamic>>()) {
    if (pedal['id'] == pedalId) {
      final category = pedal['category'];
      return category is String ? category : null;
    }
  }
  return null;
}
