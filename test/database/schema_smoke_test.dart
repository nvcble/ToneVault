import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  final timestamp = DateTime.utc(2026, 8, 19, 10, 30);

  Future<int> insertPedal({String name = 'Caline PureSky'}) {
    return database.into(database.pedals).insert(
      PedalsCompanion.insert(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
  }

  Future<int> insertControl({
    required int pedalId,
    String name = 'Gain',
    double minValue = 0,
    double maxValue = 1,
    double? step,
  }) {
    return database.into(database.pedalControls).insert(
      PedalControlsCompanion.insert(
        pedalId: pedalId,
        name: name,
        controlType: ControlType.clock,
        minValue: minValue,
        maxValue: maxValue,
        step: Value(step),
        displayOrder: 0,
      ),
    );
  }

  test('creates every v1 table', () async {
    final rows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final tables = rows.map((row) => row.read<String>('name')).toSet();

    expect(
      tables,
      containsAll(<String>[
        'pedals',
        'pedal_controls',
        'configurations',
        'configuration_values',
        'change_logs',
        'pedal_replacements',
        'pedalboards',
      ]),
    );
  });

  test('enables foreign key enforcement on the connection', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('rejects a control pointing at a pedal that does not exist', () async {
    await expectLater(
      insertControl(pedalId: 999),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects a control whose domain is inverted', () async {
    final pedalId = await insertPedal();
    await expectLater(
      insertControl(pedalId: pedalId, minValue: 1, maxValue: 0),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects a non-positive step', () async {
    final pedalId = await insertPedal();
    await expectLater(
      insertControl(pedalId: pedalId, step: 0),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rejects two controls sharing a name on the same pedal', () async {
    final pedalId = await insertPedal();
    await insertControl(pedalId: pedalId, name: 'Volume');

    await expectLater(
      insertControl(pedalId: pedalId, name: 'Volume'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('allows the same control name on two different pedals', () async {
    final firstPedal = await insertPedal();
    final secondPedal = await insertPedal(name: 'Joyo American Sound');

    await insertControl(pedalId: firstPedal, name: 'Volume');
    await insertControl(pedalId: secondPedal, name: 'Volume');

    final controls = await database.select(database.pedalControls).get();
    expect(controls, hasLength(2));
  });

  test('rejects a pedal replacing itself', () async {
    final pedalId = await insertPedal();

    await expectLater(
      database.into(database.pedalReplacements).insert(
        PedalReplacementsCompanion.insert(
          oldPedalId: pedalId,
          newPedalId: pedalId,
          replacedAt: timestamp,
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('defaults a new pedal to active and round-trips its timestamps',
      () async {
    final pedalId = await insertPedal();
    final pedal = await (database.select(
      database.pedals,
    )..where((row) => row.id.equals(pedalId))).getSingle();

    expect(pedal.status, PedalStatus.active);
    expect(pedal.createdAt, timestamp);
  });

  test('stores timestamps as ISO-8601 text rather than integers', () async {
    await insertPedal();
    final row = await database
        .customSelect('SELECT created_at FROM pedals')
        .getSingle();

    expect(row.read<String>('created_at'), startsWith('2026-08-19T10:30'));
  });
}
