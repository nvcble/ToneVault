import 'package:drift/drift.dart';

import 'scenes_table.dart';

/// Which of a device's Pro Scene slots (1-3, for the MG-30) one scene sends
/// as, over the "Scene" MIDI parameter.
///
/// A scene with no row here has never been assigned a slot, and cannot be
/// sent - the same reasoning as `MidiPatchProgramNumbers`.
@DataClassName('MidiSceneNumber')
class MidiSceneNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sceneId => integer()
      .references(Scenes, #id, onDelete: KeyAction.cascade)
      .unique()();

  IntColumn get sceneNumber => integer()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (scene_number BETWEEN 1 AND 3)',
  ];
}
