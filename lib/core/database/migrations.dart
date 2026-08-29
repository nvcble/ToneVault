import 'package:drift/drift.dart';

import 'migrations/schema_steps_v10_v13.dart';
import 'migrations/schema_steps_v15_v16.dart';
import 'migrations/schema_steps_v17.dart';
import 'migrations/schema_steps_v2_v9.dart';

/// Schema history. Every version bump gets an entry here and a matching branch
/// in one of the step files beside this one, so user data is never dropped to fix
/// a schema.
///
/// - v1: pedals, pedal_controls, configurations, configuration_values,
///   change_logs, pedal_replacements, pedalboards.
/// - v2: pedal_controls.options, the position names of a selection control.
/// - v3: change_logs.old_text and change_logs.new_text, so history can record a
///   rename or a status change as well as a knob that moved.
/// - v4: pedalboard_slots, the ordered signal chain of each rig.
/// - v5: rig_snapshots, rig_snapshot_entries and rig_snapshot_values, a rig as
///   it stood on one date with every reading frozen.
/// - v6: pedals.host_pedal_id and pedals.multi_effects_mode, the stomps and
///   blocks inside a multi-effects unit and how that unit is organised.
/// - v7: change_logs.control_pedal_name, so a scene's history says which pedal
///   on the patch the control it moved belongs to.
/// - v8: no new column. The 'multiEffects' pedal type was dropped, so the rows
///   stored as one are refiled as digital pedals of the multi-effects category.
/// - v9: patches, scenes, scene_pedals and scene_values, the sounds of a
///   multi-effects unit: a patch holds scenes, and a scene says which of the
///   unit's pedals it uses and where their controls sit.
/// - v10: rig_snapshot_values.control_pedal_name, so a snapshot of a unit on one
///   of its scenes says which pedal inside it each frozen reading came from. The
///   table is rebuilt rather than altered, because the reading is only unique per
///   pedal now and SQLite cannot change a UNIQUE constraint in place.
/// - v11: signal_blocks replaces pedalboard_slots and signal_connections joins
///   them up. A rig is designed before it is owned, so a block says what belongs
///   at that point in the chain and holds a pedal only once there is one to put
///   there; the connections say what feeds what, which a plain chain leaves empty
///   and reads off the order instead.
/// - v12: signal_endpoints, what the edges of a rig reach. A rig does not always
///   begin at a guitar and end at an amplifier, so an input, an output, a send or
///   a return says which socket it is - and a send and a return name each other,
///   which is what a trip out through an amp's effects loop and back is made of.
///   Purely additive: a rig that says nothing here reads exactly as it did.
/// - v13: rig_snapshot_entries.is_enabled and rig_snapshots.endpoint_summary, so
///   a snapshot says which pedals were switched off as well as which were on, and
///   where the rig reached at either end. The entries table is rebuilt rather than
///   altered: SQLite adds a column after the UNIQUE constraint and `createAll`
///   writes it before, so an altered table would stop reading the same as a new
///   install's.
/// - v14: nothing. The rigs feature was taken out of the app at this version, and
///   the seven tables it was built on are left exactly as they stand. Not one of
///   them is read or written by the app any more, but every row in them is
///   something the user recorded - which pedals were on the board, how they were
///   wired, and where every knob stood on a night they played - and there is no
///   screen left to get it back from once it is gone. A step that dropped them
///   would be a destructive migration bought for three statements of tidiness.
///
///   They stay reachable in the one way that still works: [BackupDao] carries all
///   seven, so a backup taken after the upgrade holds them and a file written
///   before it still restores. Dropping them belongs to a later version, and only
///   after there is somewhere for the rows to go first.
/// - v15: academy_courses, academy_modules, academy_lessons,
///   academy_exercises, academy_progress and academy_bookmarks, the Guitar
///   Academy. Purely additive: six new tables and four indexes, no ALTER and no
///   DROP, so a phone upgrading into it keeps every pedal, patch and board it
///   already had. The curriculum itself is not written here - it is seeded from
///   the assets the app ships with on the next launch, which is also what puts it
///   back after a restore from a file that predates it.
/// - v16: academy_lessons.objective, .common_mistakes, .practice_tips and
///   .next_skill, the parts of a lesson an instructor says out loud rather than
///   writes into the explanation: what it is for, what people get wrong at it,
///   what to do about that, and what it leads to. Four nullable columns with no
///   default, so every lesson already written reads exactly as it did and simply
///   says none of them - which is what the screen shows for a lesson that has
///   nothing here. The curriculum the app ships fills them in and is re-seeded on
///   the next launch, so nothing is backfilled in SQL either.
/// - v17: academy_exercise_progress and academy_practice_sessions, what the player
///   did rather than what the curriculum says. A row in the first is an exercise
///   worked through; a row in the second is one sitting with the metronome running.
///   Purely additive, and neither is backfilled: no phone has ever recorded which
///   exercise was done, and the practice already banked is one number with no dates
///   in it, so inventing sittings from it would be inventing evenings. The running
///   total stays on the progress row rather than becoming a sum over the new table,
///   which is what keeps an upgrading phone's hours from going back to nought.
const int currentSchemaVersion = 17;

MigrationStrategy buildMigrationStrategy(GeneratedDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // The steps live in four files beside this one, split only for length and
      // called in the order they shipped in. Ascending order is a requirement
      // rather than a tidiness: v10 rebuilds a table v5 created, and v11 reads a
      // pedal category that v8 corrected.
      //
      // Each one preserves existing rows.
      await upgradeThroughV9(database, from);
      await upgradeThroughV13(database, from);
      await upgradeThroughV16(database, from);
      await upgradeThroughV17(database, from);

      if (to > currentSchemaVersion) {
        throw StateError('No migration registered up to schema $to.');
      }
    },
    beforeOpen: (details) async {
      // SQLite disables foreign keys per connection, so without this the
      // restrict/cascade rules declared on the tables would do nothing.
      await database.customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
