import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/configuration_values_table.dart';
import '../tables/configurations_table.dart';

part 'configuration_dao.g.dart';

/// Typed queries over `configurations` and the values that belong to them.
///
/// Validation, timestamps and error translation belong to
/// `ConfigurationRepository`; this class only reads and writes rows.
@DriftAccessor(tables: [Configurations, ConfigurationValues])
class ConfigurationDao extends DatabaseAccessor<AppDatabase>
    with _$ConfigurationDaoMixin {
  ConfigurationDao(super.attachedDatabase);

  /// One pedal's configurations by name.
  ///
  /// SQLite's default collation is case-sensitive, which would sort "clean" after
  /// "Worship", so the ordering is explicitly case-insensitive.
  Stream<List<Configuration>> watchConfigurations(int pedalId) {
    return (select(configurations)
          ..where((row) => row.pedalId.equals(pedalId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Future<List<Configuration>> configurationsOf(int pedalId) {
    return (select(
      configurations,
    )..where((row) => row.pedalId.equals(pedalId))).get();
  }

  Stream<Configuration?> watchConfiguration(int configurationId) {
    return (select(
      configurations,
    )..where((row) => row.id.equals(configurationId))).watchSingleOrNull();
  }

  Future<Configuration?> findConfiguration(int configurationId) {
    return (select(
      configurations,
    )..where((row) => row.id.equals(configurationId))).getSingleOrNull();
  }

  /// Unordered: a configuration's values are read alongside the pedal's
  /// controls, which already carry the display order.
  Stream<List<ConfigurationValue>> watchValues(int configurationId) {
    return (select(
      configurationValues,
    )..where((row) => row.configurationId.equals(configurationId))).watch();
  }

  Future<List<ConfigurationValue>> valuesOf(int configurationId) {
    return (select(
      configurationValues,
    )..where((row) => row.configurationId.equals(configurationId))).get();
  }

  /// Inserts a configuration together with the values it starts out with.
  ///
  /// One transaction, so a configuration is never briefly visible without the
  /// positions it was created with.
  Future<int> insertConfiguration(
    ConfigurationsCompanion configuration, {
    Map<int, double> values = const {},
  }) {
    return transaction(() async {
      final configurationId = await into(configurations).insert(configuration);

      await batch((batch) {
        for (final entry in values.entries) {
          batch.insert(
            configurationValues,
            ConfigurationValuesCompanion.insert(
              configurationId: configurationId,
              controlId: entry.key,
              value: entry.value,
            ),
          );
        }
      });

      return configurationId;
    });
  }

  /// Returns whether a row matched [configurationId].
  Future<bool> updateConfiguration(
    int configurationId,
    ConfigurationsCompanion changes,
  ) async {
    final changedRows = await (update(
      configurations,
    )..where((row) => row.id.equals(configurationId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deleteConfiguration(int configurationId) async {
    final deletedRows = await (delete(
      configurations,
    )..where((row) => row.id.equals(configurationId))).go();
    return deletedRows > 0;
  }

  /// Stores where one control sits in one configuration, replacing whatever was
  /// there before.
  ///
  /// The `{configurationId, controlId}` unique key is what makes this an upsert
  /// rather than a second row for the same knob. The configuration's own
  /// timestamp moves in the same transaction, so a saved value never leaves the
  /// configuration looking untouched.
  Future<void> upsertValue({
    required int configurationId,
    required int controlId,
    required double value,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      await into(configurationValues).insert(
        ConfigurationValuesCompanion.insert(
          configurationId: configurationId,
          controlId: controlId,
          value: value,
        ),
        onConflict: DoUpdate(
          (_) => ConfigurationValuesCompanion(value: Value(value)),
          target: [
            configurationValues.configurationId,
            configurationValues.controlId,
          ],
        ),
      );

      await _touch(configurationId, updatedAt);
    });
  }

  /// Returns whether the control had a stored value to remove.
  Future<bool> deleteValue({
    required int configurationId,
    required int controlId,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final deletedRows =
          await (delete(configurationValues)..where(
                (row) =>
                    row.configurationId.equals(configurationId) &
                    row.controlId.equals(controlId),
              ))
              .go();

      if (deletedRows > 0) {
        await _touch(configurationId, updatedAt);
      }
      return deletedRows > 0;
    });
  }

  Future<void> _touch(int configurationId, DateTime updatedAt) async {
    await (update(configurations)
          ..where((row) => row.id.equals(configurationId)))
        .write(ConfigurationsCompanion(updatedAt: Value(updatedAt)));
  }
}
