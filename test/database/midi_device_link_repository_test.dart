import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';

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

    // Every block of the chain, in the order the profile lists it, which is the
    // order the unit shows: the player reads the app's chain against the one in
    // front of them, so Wah comes first and Volume last - not Amp first, which
    // is all name order ever gave.
    final blocks = await pedalRepository(
      database,
    ).watchComponentPedals(unitId).first;
    expect(blocks.map((block) => block.name), [
      for (final block in _profile.blockDefinitions) block.label,
    ]);
    expect(blocks.first.name, 'Wah');
    expect(blocks.last.name, 'Volume');

    final linked = await repository.watchLinkedPedal(_profile.id).first;
    expect(linked!.id, unitId);
  });

  test('the Send/Return loop carries the controls the chart names', () async {
    final repository = midiDeviceLinkRepository(database);
    final unitId = await repository.createLinkedGear(_profile);

    final blocks = await pedalRepository(
      database,
    ).watchComponentPedals(unitId).first;
    final loop = blocks.firstWhere((block) => block.name == 'Send/Return');
    final controls = await controlRepository(
      database,
    ).watchControls(loop.id).first;

    // Named in the chart rather than numbered, so these are the names the unit
    // uses rather than "Send/Return Knob 1" - behind the block's own on/bypass
    // selection, which every block with a type-select CC now gets.
    expect(controls.map((control) => control.name), [
      'Send/Return model',
      'Send',
      'Return',
      'SR Routing',
    ]);
  });

  test('a unit linked before a block existed can be brought up', () async {
    final repository = midiDeviceLinkRepository(database);
    final unitId = await repository.createLinkedGear(_profile);
    // Standing in for a unit linked by an older build, which had no Volume block.
    final volume = (await pedalRepository(
      database,
    ).componentPedals(unitId)).firstWhere((block) => block.name == 'Volume');
    await pedalRepository(database).deletePedal(volume.id);

    expect(await repository.addMissingBlocks(_profile), 1);
    // Idempotent, so the action is safe to press twice.
    expect(await repository.addMissingBlocks(_profile), 0);

    final blocks = await pedalRepository(database).componentPedals(unitId);
    expect(blocks.last.name, 'Volume');
    expect(blocks, hasLength(_profile.blockDefinitions.length));
  });

  test(
    'seeds one control per block parameter, named to match the profile',
    () async {
      final repository = midiDeviceLinkRepository(database);
      final unitId = await repository.createLinkedGear(_profile);

      final blocks = await pedalRepository(
        database,
      ).watchComponentPedals(unitId).first;
      final ampBlock = blocks.firstWhere((pedal) => pedal.name == 'Amp');

      final controls = await controlRepository(
        database,
      ).watchControls(ampBlock.id).first;
      // 1 model-select control + 8 knobs, matching NuxBlockSpec's amp entry.
      expect(controls, hasLength(9));
      expect(controls.map((control) => control.name), contains('Amp model'));
      expect(controls.map((control) => control.name), contains('Amp Knob 3'));
    },
  );

  test(
    'a knob with a narrower range than 0-100 is seeded as numeric, not percentage',
    () async {
      final repository = midiDeviceLinkRepository(database);
      final unitId = await repository.createLinkedGear(_profile);

      final blocks = await pedalRepository(
        database,
      ).watchComponentPedals(unitId).first;
      final irBlock = blocks.firstWhere((pedal) => pedal.name == 'IR');
      final controls = await controlRepository(
        database,
      ).watchControls(irBlock.id).first;

      final knob1 = controls.firstWhere(
        (control) => control.name == 'IR Knob 1',
      );
      expect(knob1.controlType, ControlType.numeric);
      expect(knob1.minValue, 0);
      expect(knob1.maxValue, 7);
    },
  );

  test('refuses to link the same device profile twice', () async {
    final repository = midiDeviceLinkRepository(database);
    await repository.createLinkedGear(_profile);

    await expectLater(
      repository.createLinkedGear(_profile),
      throwsA(isA<AppFailure>()),
    );
  });

  test('a linked unit can be deleted, which frees the profile again', () async {
    final repository = midiDeviceLinkRepository(database);
    final unitId = await repository.createLinkedGear(_profile);
    await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));

    // The whole of what linking creates - the unit, its blocks, their controls,
    // the link itself - and a patch written on it afterwards. All of it is the
    // unit's, so deleting the unit is enough; anything left behind would hold it
    // in place and leave the user with a unit they cannot remove.
    await pedalRepository(database).deletePedal(unitId);

    expect(await pedalRepository(database).watchPedals().first, isEmpty);
    expect(await repository.watchLinkedPedal(_profile.id).first, isNull);
    await repository.createLinkedGear(_profile);
  });
}
