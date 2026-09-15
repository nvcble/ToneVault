import 'package:drift/drift.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/bookmark_target.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/lesson_kind.dart';
import 'package:tone_vault/core/enums/music_genre.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/progress_state.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/enums/time_signature.dart';

import 'snapshot_fixture.dart';

/// A vault with one row in every table, for anything that has to handle the
/// whole database at once.
///
/// Written straight through the tables rather than through the repositories: a
/// backup has to carry whatever is in there, including the rows no repository
/// would write today.
Future<void> fillVault(AppDatabase database) async {
  final moment = DateTime.utc(2026, 8, 19, 12);

  final drivePedalId = await database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Caline PureSky',
          brand: const Value('Caline'),
          type: PedalType.analog,
          category: PedalCategory.overdrive,
          status: const Value(PedalStatus.active),
          purchaseDate: Value(moment),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  // A second pedal, so a replacement has two sides to it.
  final sparePedalId = await database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Boss SD-1',
          type: PedalType.analog,
          category: PedalCategory.overdrive,
          status: const Value(PedalStatus.replaced),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final controlId = await database
      .into(database.pedalControls)
      .insert(
        PedalControlsCompanion.insert(
          pedalId: drivePedalId,
          name: 'Gain',
          controlType: ControlType.clock,
          minValue: 0,
          maxValue: 1,
          step: const Value(0.05),
          displayOrder: 0,
        ),
      );

  final configurationId = await database
      .into(database.configurations)
      .insert(
        ConfigurationsCompanion.insert(
          pedalId: drivePedalId,
          name: 'Worship Lead',
          notes: const Value('Edge of breakup'),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.configurationValues)
      .insert(
        ConfigurationValuesCompanion.insert(
          configurationId: configurationId,
          controlId: controlId,
          value: 0.7,
        ),
      );

  // A multi-effects unit with a pedal inside it, so a patch has something its
  // scenes can reach for.
  final unitId = await database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Valeton GP-200',
          type: PedalType.digital,
          category: PedalCategory.multiEffects,
          status: const Value(PedalStatus.active),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final insidePedalId = await database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Tube Screamer',
          type: PedalType.digital,
          category: PedalCategory.overdrive,
          status: const Value(PedalStatus.active),
          hostPedalId: Value(unitId),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final insideControlId = await database
      .into(database.pedalControls)
      .insert(
        PedalControlsCompanion.insert(
          pedalId: insidePedalId,
          name: 'Drive',
          controlType: ControlType.clock,
          minValue: 0,
          maxValue: 1,
          displayOrder: 0,
        ),
      );

  final patchId = await database
      .into(database.patches)
      .insert(
        PatchesCompanion.insert(
          pedalId: unitId,
          name: 'Worship Clean',
          notes: const Value('Second service'),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final sceneId = await database
      .into(database.scenes)
      .insert(
        ScenesCompanion.insert(
          patchId: patchId,
          name: 'Verse',
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.scenePedals)
      .insert(
        ScenePedalsCompanion.insert(sceneId: sceneId, pedalId: insidePedalId),
      );

  await database
      .into(database.sceneValues)
      .insert(
        SceneValuesCompanion.insert(
          sceneId: sceneId,
          controlId: insideControlId,
          value: 0.4,
        ),
      );

  await database
      .into(database.changeLogs)
      .insert(
        ChangeLogsCompanion.insert(
          pedalId: drivePedalId,
          configurationId: Value(configurationId),
          controlId: Value(controlId),
          controlName: const Value('Gain'),
          changeType: ChangeType.controlValueChanged,
          oldValue: const Value(0.5),
          newValue: const Value(0.7),
          createdAt: moment,
        ),
      );

  await database
      .into(database.pedalReplacements)
      .insert(
        PedalReplacementsCompanion.insert(
          oldPedalId: sparePedalId,
          newPedalId: drivePedalId,
          reason: const Value('Quieter'),
          replacedAt: moment,
        ),
      );

  final pedalboardId = await database
      .into(database.pedalboards)
      .insert(
        PedalboardsCompanion.insert(
          name: 'Hybrid Worship Rig',
          description: const Value('MG-30 into the desk'),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final driveBlockId = await database
      .into(database.signalBlocks)
      .insert(
        SignalBlocksCompanion.insert(
          pedalboardId: pedalboardId,
          pedalId: Value(drivePedalId),
          blockType: SignalBlockType.overdrive,
          position: 0,
        ),
      );

  // An empty block, and a cable to it: a backup has to carry the parts of a
  // chain that hold no pedal as faithfully as the parts that do.
  final emptyBlockId = await database
      .into(database.signalBlocks)
      .insert(
        SignalBlocksCompanion.insert(
          pedalboardId: pedalboardId,
          blockType: SignalBlockType.delay,
          label: const Value('Slapback'),
          position: 1,
        ),
      );

  await database
      .into(database.signalConnections)
      .insert(
        SignalConnectionsCompanion.insert(
          pedalboardId: pedalboardId,
          sourceBlockId: driveBlockId,
          targetBlockId: emptyBlockId,
          connectionType: SignalConnectionType.series,
        ),
      );

  // Where the rig ends, said rather than assumed: this one goes to the desk, not
  // to an amplifier, which is the sort of thing a backup has to carry.
  final outputBlockId = await database
      .into(database.signalBlocks)
      .insert(
        SignalBlocksCompanion.insert(
          pedalboardId: pedalboardId,
          blockType: SignalBlockType.output,
          position: 2,
        ),
      );

  await database
      .into(database.signalEndpoints)
      .insert(
        SignalEndpointsCompanion.insert(
          blockId: outputBlockId,
          destination: const Value(SignalDestination.foh),
          gear: const Value('The desk on stage left'),
        ),
      );

  await fillSnapshot(
    database,
    pedalboardId: pedalboardId,
    pedalId: drivePedalId,
    moment: moment,
  );

  await _fillAcademy(database, moment);
  await _fillMidi(database, moment, unitId: unitId, patchId: patchId, sceneId: sceneId);
}

/// A remapped CC, a patch-selection strategy, a device link and a
/// program/scene number, so a backup carries a user's own MIDI setup the same
/// way it carries their gear.
Future<void> _fillMidi(
  AppDatabase database,
  DateTime moment, {
  required int unitId,
  required int patchId,
  required int sceneId,
}) async {
  await database
      .into(database.midiParameterOverrides)
      .insert(
        MidiParameterOverridesCompanion.insert(
          deviceProfileId: 'nux_mg30_v5',
          parameterName: 'Scene',
          ccNumber: 90,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.midiPatchSelectionSettings)
      .insert(
        MidiPatchSelectionSettingsCompanion.insert(
          deviceProfileId: 'nux_mg30_v5',
          usesBankSelect: const Value(false),
          updatedAt: moment,
        ),
      );

  await database
      .into(database.midiDeviceLinks)
      .insert(
        MidiDeviceLinksCompanion.insert(
          pedalId: unitId,
          deviceProfileId: 'nux_mg30_v5',
          linkedAt: moment,
        ),
      );

  await database
      .into(database.midiPatchProgramNumbers)
      .insert(
        MidiPatchProgramNumbersCompanion.insert(
          patchId: patchId,
          programNumber: 21,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.midiSceneNumbers)
      .insert(
        MidiSceneNumbersCompanion.insert(
          sceneId: sceneId,
          sceneNumber: 1,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.midiPatchFavorites)
      .insert(
        MidiPatchFavoritesCompanion.insert(patchId: patchId, createdAt: moment),
      );

  await database
      .into(database.midiPatchRecents)
      .insert(
        MidiPatchRecentsCompanion.insert(patchId: patchId, lastUsedAt: moment),
      );
}

/// A course with a module, a lesson, an exercise, the progress against it - state,
/// the tick on the exercise and the sitting it was practised in - and a bookmark.
///
/// The curriculum is carried by a backup as well as the progress, because progress
/// points at a lesson by id: a file holding one without the other would credit the
/// player against whatever lesson happened to be given that id.
Future<void> _fillAcademy(AppDatabase database, DateTime moment) async {
  final courseId = await database
      .into(database.academyCourses)
      .insert(
        AcademyCoursesCompanion.insert(
          slug: 'rhythm-beginner-first-chords',
          path: LearningPath.rhythm,
          level: SkillLevel.beginner,
          title: 'First Chords',
          summary: 'Open chords, and changing between them in time.',
          position: 0,
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final moduleId = await database
      .into(database.academyModules)
      .insert(
        AcademyModulesCompanion.insert(
          courseId: courseId,
          slug: 'open-chords',
          title: 'Open Chords',
          summary: const Value('E minor, A minor, and back again.'),
          position: 0,
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final lessonId = await database
      .into(database.academyLessons)
      .insert(
        AcademyLessonsCompanion.insert(
          moduleId: moduleId,
          slug: 'em-to-am',
          title: 'Em to Am',
          kind: LessonKind.technique,
          genre: const Value(MusicGenre.worship),
          body: 'Fret it, strum it, listen.',
          estimatedMinutes: const Value(10),
          suggestedBpm: const Value(70),
          timeSignature: const Value(TimeSignature.fourFour),
          position: 0,
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final exerciseId = await database
      .into(database.academyExercises)
      .insert(
        AcademyExercisesCompanion.insert(
          lessonId: lessonId,
          title: 'Two bars each',
          instructions: 'Change on the first beat, every time.',
          startBpm: 60,
          targetBpm: 90,
          timeSignature: TimeSignature.fourFour,
          position: 0,
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.academyExerciseProgress)
      .insert(
        AcademyExerciseProgressCompanion.insert(
          exerciseId: exerciseId,
          completedAt: moment,
        ),
      );

  // The sitting the practice on the progress row was earned in. Both are carried,
  // because the total is what a screen shows and the sitting is how it was earned.
  await database
      .into(database.academyPracticeSessions)
      .insert(
        AcademyPracticeSessionsCompanion.insert(
          lessonId: lessonId,
          seconds: 900,
          endedAt: moment,
        ),
      );

  await database
      .into(database.academyProgress)
      .insert(
        AcademyProgressCompanion.insert(
          lessonId: lessonId,
          state: ProgressState.inProgress,
          lastOpenedAt: moment,
          practiceSeconds: const Value(900),
        ),
      );

  // A bookmark on a chord rather than a lesson, because that is the one with no
  // row anywhere to point at.
  await database
      .into(database.academyBookmarks)
      .insert(
        AcademyBookmarksCompanion.insert(
          target: BookmarkTarget.chord,
          targetKey: 'Cmaj7',
          label: 'C major 7',
          createdAt: moment,
        ),
      );
}
