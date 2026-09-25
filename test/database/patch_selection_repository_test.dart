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

  test('has no override until one is set', () async {
    final repository = patchSelectionRepository(database);

    final override = await repository.watchOverride(_profile.id).first;

    expect(override, isNull);
  });

  test(
    'setOverride stores only the fields given, alongside what was already there',
    () async {
      final repository = patchSelectionRepository(database);
      await repository.setOverride(profile: _profile, bankSelectMsb: 5);

      await repository.setOverride(profile: _profile, usesBankSelect: false);

      final override = await repository.watchOverride(_profile.id).first;
      expect(override!.usesBankSelect, isFalse);
      expect(override.bankSelectMsb, 5);
    },
  );

  test(
    'a clear flag removes a field back to the device profile default',
    () async {
      final repository = patchSelectionRepository(database);
      await repository.setOverride(profile: _profile, bankSelectMsb: 5);

      await repository.setOverride(profile: _profile, clearBankSelectMsb: true);

      final override = await repository.watchOverride(_profile.id).first;
      expect(override!.bankSelectMsb, isNull);
    },
  );

  test('refuses a Bank Select value outside the 7-bit MIDI range', () async {
    final repository = patchSelectionRepository(database);

    await expectLater(
      repository.setOverride(profile: _profile, bankSelectMsb: 128),
      throwsA(isA<AppFailure>()),
    );
  });

  test('resetOverride removes the whole strategy', () async {
    final repository = patchSelectionRepository(database);
    await repository.setOverride(
      profile: _profile,
      usesBankSelect: false,
      bankSelectMsb: 5,
    );

    await repository.resetOverride(_profile.id);

    final override = await repository.watchOverride(_profile.id).first;
    expect(override, isNull);
  });
}
