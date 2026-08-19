import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';

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

  ControlDraft draft({
    required String name,
    ControlType type = ControlType.clock,
    double minValue = 0,
    double maxValue = 1,
    double? step,
    double? defaultValue,
    String? unit,
    List<String> options = const [],
  }) {
    return ControlDraft(
      name: name,
      type: type,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      defaultValue: defaultValue,
      unit: unit,
      options: options,
    );
  }

  group('createControl', () {
    test('stores the control against its pedal', () async {
      final controlId = await repository.createControl(
        pedalId,
        draft(name: '  Volume  ', defaultValue: 0.5),
      );

      final control = await database.pedalControlDao.findControl(controlId);
      expect(control!.pedalId, pedalId);
      expect(control.name, 'Volume');
      expect(control.controlType, ControlType.clock);
      expect(control.defaultValue, 0.5);
    });

    test('adds each new control to the end of the list', () async {
      await repository.createControl(pedalId, draft(name: 'Volume'));
      await repository.createControl(pedalId, draft(name: 'Tone'));
      await repository.createControl(pedalId, draft(name: 'Gain'));

      final controls = await database.pedalControlDao.controlsOf(pedalId);
      expect(controls.map((control) => control.name), [
        'Volume',
        'Tone',
        'Gain',
      ]);
      expect(controls.map((control) => control.displayOrder), [0, 1, 2]);
    });

    test('numbers the first control of a second pedal from zero', () async {
      final otherPedalId = await PedalRepository(PedalDao(database))
          .createPedal(
            const PedalDraft(
              name: 'Mooer Yellow Comp',
              type: PedalType.analog,
              category: PedalCategory.compressor,
            ),
          );
      await repository.createControl(pedalId, draft(name: 'Volume'));

      final controlId = await repository.createControl(
        otherPedalId,
        draft(name: 'Comp'),
      );

      final control = await database.pedalControlDao.findControl(controlId);
      expect(control!.displayOrder, 0);
    });

    test(
      'stores selection positions and derives the domain from them',
      () async {
        final controlId = await repository.createControl(
          pedalId,
          draft(
            name: 'Mode',
            type: ControlType.selection,
            maxValue: 99,
            options: const ['Chorus', 'Vibrato', 'Rotary'],
          ),
        );

        final control = await database.pedalControlDao.findControl(controlId);
        expect(decodeControlOptions(control!.options), [
          'Chorus',
          'Vibrato',
          'Rotary',
        ]);
        expect(control.minValue, 0);
        expect(control.maxValue, 2);
      },
    );

    test('leaves options unset for every other type', () async {
      final controlId = await repository.createControl(
        pedalId,
        draft(name: 'Volume', options: const ['ignored']),
      );

      final control = await database.pedalControlDao.findControl(controlId);
      expect(control!.options, isNull);
    });

    test('reports a name already used on the same pedal', () async {
      await repository.createControl(pedalId, draft(name: 'Volume'));

      await expectLater(
        repository.createControl(pedalId, draft(name: 'volume')),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('already has a control called "volume"'),
          ),
        ),
      );
    });

    test('allows the same control name on a different pedal', () async {
      final otherPedalId = await PedalRepository(PedalDao(database))
          .createPedal(
            const PedalDraft(
              name: 'Rowin Noise Gate',
              type: PedalType.analog,
              category: PedalCategory.noiseGate,
            ),
          );
      await repository.createControl(pedalId, draft(name: 'Volume'));

      await expectLater(
        repository.createControl(otherPedalId, draft(name: 'Volume')),
        completes,
      );
    });

    test('reports invalid input as a readable failure', () async {
      await expectLater(
        repository.createControl(
          pedalId,
          draft(name: 'Mode', type: ControlType.selection),
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('at least 2 positions'),
          ),
        ),
      );
    });

    test('does not expose a driver exception for an unknown pedal', () async {
      await expectLater(
        repository.createControl(404, draft(name: 'Volume')),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('updateControl', () {
    test('rewrites the control without touching its position', () async {
      await repository.createControl(pedalId, draft(name: 'Volume'));
      final controlId = await repository.createControl(
        pedalId,
        draft(name: 'Tone'),
      );

      await repository.updateControl(
        controlId,
        draft(
          name: 'Treble',
          type: ControlType.percentage,
          maxValue: 100,
          step: 5,
          unit: '%',
        ),
      );

      final control = await database.pedalControlDao.findControl(controlId);
      expect(control!.name, 'Treble');
      expect(control.controlType, ControlType.percentage);
      expect(control.maxValue, 100);
      expect(control.step, 5);
      expect(control.displayOrder, 1);
    });

    test('lets a control keep its own name', () async {
      final controlId = await repository.createControl(
        pedalId,
        draft(name: 'Volume'),
      );

      await expectLater(
        repository.updateControl(controlId, draft(name: 'Volume', step: 0.1)),
        completes,
      );
    });

    test('reports a control that is already gone', () async {
      await expectLater(
        repository.updateControl(404, draft(name: 'Volume')),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            'That control no longer exists.',
          ),
        ),
      );
    });
  });
}
