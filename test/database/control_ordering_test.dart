import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';

/// Removing and rearranging a pedal's controls. Defining them is covered by
/// control_repository_test.dart.
void main() {
  late AppDatabase database;
  late ControlRepository repository;
  late int pedalId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlRepository(PedalControlDao(database));
    pedalId = await PedalRepository(PedalDao(database)).createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
  });

  tearDown(() => database.close());

  Future<int> addControl(String name) {
    return repository.createControl(
      pedalId,
      ControlDraft.ofType(ControlType.clock, name: name),
    );
  }

  group('deleteControl', () {
    test('removes the control', () async {
      final controlId = await addControl('Volume');

      await repository.deleteControl(controlId);

      expect(await database.pedalControlDao.controlsOf(pedalId), isEmpty);
    });

    test('reports a control that is already gone', () async {
      await expectLater(
        repository.deleteControl(404),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('reorderControls', () {
    test('renumbers the controls into the given order', () async {
      final first = await addControl('Volume');
      final second = await addControl('Tone');
      final third = await addControl('Gain');

      await repository.reorderControls(pedalId, [third, first, second]);

      final controls = await database.pedalControlDao.controlsOf(pedalId);
      expect(controls.map((control) => control.name), [
        'Gain',
        'Volume',
        'Tone',
      ]);
    });

    test('refuses a list that no longer matches the pedal', () async {
      // A list built before someone else added a control would otherwise
      // renumber around the change and silently drop it to the end.
      final first = await addControl('Volume');
      await addControl('Tone');

      await expectLater(
        repository.reorderControls(pedalId, [first]),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('changed while you were reordering'),
          ),
        ),
      );
    });

    test('accepts the order a pedal is already in', () async {
      final first = await addControl('Volume');
      final second = await addControl('Tone');

      await expectLater(
        repository.reorderControls(pedalId, [first, second]),
        completes,
      );
    });
  });
}
