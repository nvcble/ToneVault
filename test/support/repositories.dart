import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/database/daos/configuration_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_replacement_dao.dart';
import 'package:tone_vault/core/database/daos/pedalboard_dao.dart';
import 'package:tone_vault/features/configurations/data/configuration_repository.dart';
import 'package:tone_vault/features/configurations/data/configuration_value_repository.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_repository.dart';
import 'package:tone_vault/features/pedalboards/data/rig_chain_repository.dart';
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

/// The one repository that records no history: a rig is a grouping of pedals,
/// not something that happened to one.
PedalboardRepository pedalboardRepository(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return PedalboardRepository(PedalboardDao(database), clock: clock);
}

RigChainRepository rigChainRepository(
  AppDatabase database, {
  DateTime Function()? clock,
}) {
  return RigChainRepository(
    PedalboardDao(database),
    PedalDao(database),
    clock: clock,
  );
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
