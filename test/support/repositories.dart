import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/academy_bookmark_dao.dart';
import 'package:tone_vault/core/database/daos/academy_course_dao.dart';
import 'package:tone_vault/core/database/daos/academy_progress_dao.dart';
import 'package:tone_vault/core/database/daos/backup_dao.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/database/daos/configuration_dao.dart';
import 'package:tone_vault/core/database/daos/patch_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_replacement_dao.dart';
import 'package:tone_vault/core/database/daos/scene_dao.dart';
import 'package:tone_vault/features/academy/data/bookmark_repository.dart';
import 'package:tone_vault/features/academy/data/curriculum_exporter.dart';
import 'package:tone_vault/features/academy/data/curriculum_importer.dart';
import 'package:tone_vault/features/academy/data/curriculum_repository.dart';
import 'package:tone_vault/features/academy/data/progress_repository.dart';
import 'package:tone_vault/features/backup/data/backup_repository.dart';
import 'package:tone_vault/features/configurations/data/configuration_repository.dart';
import 'package:tone_vault/features/configurations/data/configuration_value_repository.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/patches/data/patch_repository.dart';
import 'package:tone_vault/features/patches/data/scene_duplicator.dart';
import 'package:tone_vault/features/patches/data/scene_pedal_repository.dart';
import 'package:tone_vault/features/patches/data/scene_repository.dart';
import 'package:tone_vault/features/patches/data/scene_value_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';
import 'package:tone_vault/features/replacements/data/replacement_repository.dart';

/// Repositories wired to one in-memory database, the way the providers wire them
/// to the real one.
///
/// Every repository that writes also records history, so each test would
/// otherwise repeat the same assembly. Anything a test wants to control - a
/// clock, a change log that misbehaves - it passes in.
ChangeLogRepository changeLogRepository(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return ChangeLogRepository(ChangeLogDao(database), clock: clock);
}

PedalRepository pedalRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return PedalRepository(
    PedalDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

ControlRepository controlRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return ControlRepository(
    PedalControlDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
  );
}

ConfigurationRepository configurationRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return ConfigurationRepository(
    ConfigurationDao(database),
    PedalControlDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

ReplacementRepository replacementRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return ReplacementRepository(
    PedalReplacementDao(database),
    PedalDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

/// The only repository that reaches every table at once.
BackupRepository backupRepository(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return BackupRepository(BackupDao(database), clock: clock);
}

ConfigurationValueRepository configurationValueRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return ConfigurationValueRepository(
    ConfigurationDao(database),
    PedalControlDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

/// The patches of a multi-effects unit, and the scenes inside them. Both record
/// history: a named sound arriving, being renamed or going is part of the story of
/// the unit.
PatchRepository patchRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return PatchRepository(
    PatchDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

SceneRepository sceneRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return SceneRepository(
    PatchDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

/// Adding a pedal to a scene checks the unit holds it and seeds the defaults its
/// controls declare, and a pedal may be created from inside the scene, which is
/// why this one takes the whole set.
ScenePedalRepository scenePedalRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return ScenePedalRepository(
    SceneDao(database),
    PatchDao(database),
    PedalDao(database),
    PedalControlDao(database),
    pedalRepository(database, clock: clock, changeLog: changeLog),
    clock: clock,
  );
}

/// Copying a scene records the copy arriving, so it takes the change log too.
SceneDuplicator sceneDuplicator(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return SceneDuplicator(
    PatchDao(database),
    SceneDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}

/// The Academy's three, which record no history: the change log is the story of
/// the user's gear, and a lesson opened is not part of it.
CurriculumRepository curriculumRepository(AppDatabase database) {
  return CurriculumRepository(AcademyCourseDao(database));
}

CurriculumImporter curriculumImporter(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return CurriculumImporter(AcademyCourseDao(database), clock: clock);
}

CurriculumExporter curriculumExporter(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return CurriculumExporter(AcademyCourseDao(database), clock: clock);
}

ProgressRepository progressRepository(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return ProgressRepository(AcademyProgressDao(database), clock: clock);
}

BookmarkRepository bookmarkRepository(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return BookmarkRepository(AcademyBookmarkDao(database), clock: clock);
}

SceneValueRepository sceneValueRepository(
  AppDatabase database, {
  DateTime Function()? clock,
  ChangeLogRepository? changeLog,
}) {
  return SceneValueRepository(
    SceneDao(database),
    PatchDao(database),
    changeLog ?? changeLogRepository(database, clock: clock),
    clock: clock,
  );
}
