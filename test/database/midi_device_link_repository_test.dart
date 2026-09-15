import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';

import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('has no linked pedal until one is created', () async {
    final repository = midiDeviceLinkRepository(database);

    final pedal = await repository.watchLinkedPedal(_profile.id).first;

    expect(pedal, isNull);
  });

  test('creates the unit, one pedal per block, and links it', () async {
    final repository = midiDeviceLinkRepository(database);

    final unitId = await repository.createLinkedGear(_profile);

    final unit = await pedalRepository(database).watchPedal(unitId).first;
    expect(unit!.name, _profile.displayName);

    final blocks = await pedalRepository(database).watchComponentPedals(unitId).first;
    expect(blocks, hasLength(_profile.blockDefinitions.length));

    final linked = await repository.watchLinkedPedal(_profile.id).first;
    expect(linked!.id, unitId);
  });

  test('seeds one control per block parameter, named to match the profile', () async {
    final repository = midiDeviceLinkRepository(database);
    final unitId = await repository.createLinkedGear(_profile);

    final blocks = await pedalRepository(database).watchComponentPedals(unitId).first;
    final ampBlock = blocks.firstWhere((pedal) => pedal.name == 'Amp');

    final controls = await controlRepository(database).watchControls(ampBlock.id).first;
    // 1 model-select control + 8 knobs, matching NuxBlockSpec's amp entry.
    expect(controls, hasLength(9));
    expect(controls.map((control) => control.name), contains('Amp model'));
    expect(controls.map((control) => control.name), contains('Amp Knob 3'));
  });

  test('a knob with a narrower range than 0-100 is seeded as numeric, not percentage', () async {
    final repository = midiDeviceLinkRepository(database);
    final unitId = await repository.createLinkedGear(_profile);

    final blocks = await pedalRepository(database).watchComponentPedals(unitId).first;
    final irBlock = blocks.firstWhere((pedal) => pedal.name == 'IR');
    final controls = await controlRepository(database).watchControls(irBlock.id).first;

    final knob1 = controls.firstWhere((control) => control.name == 'IR Knob 1');
    expect(knob1.controlType, ControlType.numeric);
    expect(knob1.minValue, 0);
    expect(knob1.maxValue, 7);
  });

  test('refuses to link the same device profile twice', () async {
    final repository = midiDeviceLinkRepository(database);
    await repository.createLinkedGear(_profile);

    await expectLater(repository.createLinkedGear(_profile), throwsA(isA<AppFailure>()));
  });
}
