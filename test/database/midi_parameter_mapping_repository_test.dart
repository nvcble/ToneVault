import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';

import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('reads the device profile defaults with no overrides stored', () async {
    final repository = midiParameterMappingRepository(database);

    final parameters = await repository
        .watchEffectiveParameters(_profile)
        .first;

    expect(parameters, hasLength(86));
    expect(parameters.firstWhere((p) => p.name == 'Scene').ccNumber, 80);
  });

  test('an override replaces the default CC for that parameter only', () async {
    final repository = midiParameterMappingRepository(database);

    await repository.setOverride(
      profile: _profile,
      parameterName: 'Scene',
      ccNumber: 90,
    );
    final parameters = await repository
        .watchEffectiveParameters(_profile)
        .first;

    expect(parameters.firstWhere((p) => p.name == 'Scene').ccNumber, 90);
    expect(parameters.firstWhere((p) => p.name == 'Pedal').ccNumber, 79);
  });

  test('refuses a parameter name the device profile does not ship', () async {
    final repository = midiParameterMappingRepository(database);

    await expectLater(
      repository.setOverride(
        profile: _profile,
        parameterName: 'Made up',
        ccNumber: 1,
      ),
      throwsA(isA<AppFailure>()),
    );
  });

  test('refuses a CC number outside the 7-bit MIDI range', () async {
    final repository = midiParameterMappingRepository(database);

    await expectLater(
      repository.setOverride(
        profile: _profile,
        parameterName: 'Scene',
        ccNumber: 128,
      ),
      throwsA(isA<AppFailure>()),
    );
    await expectLater(
      repository.setOverride(
        profile: _profile,
        parameterName: 'Scene',
        ccNumber: -1,
      ),
      throwsA(isA<AppFailure>()),
    );
  });

  test('resetOverride restores the default CC', () async {
    final repository = midiParameterMappingRepository(database);
    await repository.setOverride(
      profile: _profile,
      parameterName: 'Scene',
      ccNumber: 90,
    );

    await repository.resetOverride(
      deviceProfileId: _profile.id,
      parameterName: 'Scene',
    );

    final parameters = await repository
        .watchEffectiveParameters(_profile)
        .first;
    expect(parameters.firstWhere((p) => p.name == 'Scene').ccNumber, 80);
  });

  test('resetAllOverrides clears every remapped parameter at once', () async {
    final repository = midiParameterMappingRepository(database);
    await repository.setOverride(
      profile: _profile,
      parameterName: 'Scene',
      ccNumber: 90,
    );
    await repository.setOverride(
      profile: _profile,
      parameterName: 'Pedal',
      ccNumber: 91,
    );

    await repository.resetAllOverrides(_profile.id);

    final overridden = await repository.watchOverriddenNames(_profile.id).first;
    expect(overridden, isEmpty);
  });

  test(
    'watchOverriddenNames names only what has actually been remapped',
    () async {
      final repository = midiParameterMappingRepository(database);
      await repository.setOverride(
        profile: _profile,
        parameterName: 'Scene',
        ccNumber: 90,
      );

      final overridden = await repository
          .watchOverriddenNames(_profile.id)
          .first;

      expect(overridden, {'Scene'});
    },
  );
}
