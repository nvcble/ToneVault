import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;
  late int unitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
  });

  tearDown(() => database.close());

  test('saveCapture stores raw bytes and the decoder\'s name', () async {
    final repository = midiPresetCaptureRepository(database);
    const decoded = DecodedNuxMg30V5Preset(
      programNumber: 5,
      name: 'Worship Lead',
      unsupportedFields: {'knobs'},
    );

    await repository.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 5,
      rawSysEx: Uint8List.fromList([0xF0, 0x43, 0x58, 0xF7]),
      decoded: decoded,
      clock: () => DateTime.utc(2026, 9),
    );

    final captures = await repository.watchCaptures(unitId).first;
    expect(captures.single.programNumber, 5);
    expect(captures.single.decodedName, 'Worship Lead');
    expect(captures.single.rawSysEx, [0xF0, 0x43, 0x58, 0xF7]);
    expect(captures.single.capturedAt, DateTime.utc(2026, 9));

    final summary = jsonDecode(captures.single.decodedSummaryJson!) as Map<String, dynamic>;
    expect(summary['name'], 'Worship Lead');
  });

  test('a second save for the same program number replaces the first', () async {
    final repository = midiPresetCaptureRepository(database);
    await repository.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 5,
      rawSysEx: Uint8List.fromList([0x00]),
    );

    await repository.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 5,
      rawSysEx: Uint8List.fromList([0x01]),
      decoded: const DecodedNuxMg30V5Preset(programNumber: 5, name: 'Replaced'),
    );

    final captures = await repository.watchCaptures(unitId).first;
    expect(captures, hasLength(1));
    expect(captures.single.rawSysEx, [0x01]);
    expect(captures.single.decodedName, 'Replaced');
  });

  test('findByProgramNumber is null when nothing has been captured for that slot', () async {
    final repository = midiPresetCaptureRepository(database);

    expect(await repository.findByProgramNumber(unitId, 9), isNull);
  });

  test('deleteCapture removes the row and reports whether one existed', () async {
    final repository = midiPresetCaptureRepository(database);
    await repository.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 5,
      rawSysEx: Uint8List.fromList([0x00]),
    );
    final id = (await repository.watchCaptures(unitId).first).single.id;

    expect(await repository.deleteCapture(id), isTrue);
    expect(await repository.deleteCapture(id), isFalse);
    expect(await repository.watchCaptures(unitId).first, isEmpty);
  });
}
