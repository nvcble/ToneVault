import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';
import '../support/repositories.dart';

/// The pedals inside a multi-effects unit.
///
/// They are ordinary pedal rows, which is what lets every screen written for a
/// pedal work on them unchanged. What this pins down is the other half of that
/// bargain: they are reached only through their unit, and never counted as gear
/// a player owns separately.
void main() {
  late AppDatabase database;
  late PedalRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = pedalRepository(database, clock: () => DateTime.utc(2026, 8));
  });

  tearDown(() => database.close());

  /// A refusal the user can read, rather than a raw driver exception. Spelled out
  /// here as the other database tests do.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> addUnit({MultiEffectsMode mode = MultiEffectsMode.stomp}) {
    return repository.createPedal(
      PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.multiEffects,
        category: PedalCategory.multiEffects,
        multiEffectsMode: mode,
      ),
    );
  }

  Future<int> addStomp(int hostPedalId, String name) {
    return repository.createPedal(
      PedalDraft(
        name: name,
        type: PedalType.digital,
        category: PedalCategory.overdrive,
        hostPedalId: hostPedalId,
      ),
    );
  }

  test('a unit stores the mode it is used in', () async {
    final unitId = await addUnit(mode: MultiEffectsMode.scene);
    final unit = await database.pedalDao.findPedal(unitId);

    expect(unit!.multiEffectsMode, MultiEffectsMode.scene);
    expect(unit.hostPedalId, isNull);
  });

  test('a stomp is listed under its unit, not in the inventory', () async {
    final unitId = await addUnit();
    await addStomp(unitId, 'Tube Screamer');
    await addStomp(unitId, 'Hall Reverb');

    // The inventory is what the pedal list, the dashboard tallies, the rig chain
    // picker and the replacement list all read.
    final owned = await repository.watchPedals().first;
    expect(owned.map((pedal) => pedal.name), ['Valeton GP-200']);

    final inside = await repository.watchComponentPedals(unitId).first;
    expect(inside.map((pedal) => pedal.name), ['Hall Reverb', 'Tube Screamer']);
  });

  test('a stomp keeps controls and configurations of its own', () async {
    final unitId = await addUnit();
    final stompId = await addStomp(unitId, 'Tube Screamer');

    // "Every stomp is one pedal": the ordinary control and configuration
    // repositories take it with no special case at all.
    await controlRepository(database).createControl(
      stompId,
      const ControlDraft(
        name: 'Drive',
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
      ),
    );
    await configurationRepository(
      database,
    ).createConfiguration(stompId, const ConfigurationDraft(name: 'Lead'));

    final controls = await database.pedalControlDao.controlsOf(stompId);
    final configurations = await database.configurationDao
        .watchConfigurations(stompId)
        .first;

    expect(controls.single.name, 'Drive');
    expect(configurations.single.name, 'Lead');
  });

  test('a unit cannot be deleted while it still holds pedals', () async {
    final unitId = await addUnit();
    await addStomp(unitId, 'Tube Screamer');

    // The same refusal every other reference to a pedal earns, so nothing the
    // unit holds is swept away with it.
    await expectLater(
      repository.deletePedal(unitId),
      failsWith(
        'This pedal is on a rig, holds other pedals, or has configurations, '
        'history or snapshots attached. Take it off the rig, or change its '
        'status rather than deleting it.',
      ),
    );

    expect(await database.pedalDao.findPedal(unitId), isNotNull);
  });

  test('an emptied unit can be deleted', () async {
    final unitId = await addUnit();
    final stompId = await addStomp(unitId, 'Tube Screamer');

    await repository.deletePedal(stompId);
    await repository.deletePedal(unitId);

    expect(await repository.watchPedals().first, isEmpty);
  });
}
