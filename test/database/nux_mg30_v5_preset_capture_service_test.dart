import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_log_entry.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/data/nux_mg30_v5_preset_capture_service.dart';
import 'package:tone_vault/features/midi/data/nux_mg30_v5_preset_reader.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/fake_midi_transport.dart';
import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();
const _endpoint = MidiEndpoint(id: 'dev-1', name: 'MG-30', type: MidiTransportType.usb);
const _fastTimeout = Duration(milliseconds: 50);

/// A 218-byte "get preset data" reply for [programNumber] - just enough
/// shape for `NuxMg30V5SysEx.isPresetDataResponse` to accept it.
SysExMessage _replyFor(int programNumber) {
  final bytes = List<int>.filled(218, 0);
  bytes[1] = 0x43;
  bytes[2] = 0x58;
  bytes[3] = 0x70;
  bytes[4] = 0x0B;
  bytes[5] = 0x02;
  bytes[6] = programNumber;
  return SysExMessage(payload: bytes.sublist(1, 217));
}

void main() {
  late AppDatabase database;
  late int unitId;
  late MidiEngine engine;
  late FakeMidiTransport transport;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    engine = MidiEngine();
    transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);
  });

  tearDown(() => database.close());

  /// Answers every "get preset data" request the fake transport sees except
  /// those naming a program number in [dropRequestsFor] - a stand-in for the
  /// real device answering (or failing to answer) each read in turn.
  void autoReply({Set<int> dropRequestsFor = const {}}) {
    engine.log.listen((entry) {
      if (entry.direction != MidiDirection.outgoing) {
        return;
      }
      final bytes = entry.message.toBytes();
      if (bytes.length == 15 && bytes[4] == 0x0B && !dropRequestsFor.contains(bytes[6])) {
        transport.receive(_replyFor(bytes[6]));
      }
    });
  }

  test('captures every program number in range and reports the summary', () async {
    autoReply();
    final service = NuxMg30V5PresetCaptureService(
      NuxMg30V5PresetReader(engine),
      midiPresetCaptureRepository(database),
    );

    final summary = await service.captureAll(
      unitId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      onDuplicate: PresetCaptureDecision.skip,
      lastProgramNumber: 2,
      readTimeout: _fastTimeout,
    );

    expect(summary.captured, 3);
    expect(summary.overwritten, 0);
    expect(summary.skipped, 0);
    expect(summary.failures, isEmpty);

    final captures = await midiPresetCaptureRepository(database).watchCaptures(unitId).first;
    expect(captures.map((c) => c.programNumber), [0, 1, 2]);
  });

  test('skips a program number already captured when told to keep it', () async {
    final captures = midiPresetCaptureRepository(database);
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 1,
      rawSysEx: Uint8List.fromList([0x00]),
    );
    autoReply();
    final service = NuxMg30V5PresetCaptureService(NuxMg30V5PresetReader(engine), captures);

    final summary = await service.captureAll(
      unitId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      onDuplicate: PresetCaptureDecision.skip,
      lastProgramNumber: 1,
      readTimeout: _fastTimeout,
    );

    expect(summary.captured, 1);
    expect(summary.skipped, 1);
    final row = await captures.findByProgramNumber(unitId, 1);
    expect(row!.rawSysEx, [0x00]);
  });

  test('overwrites an already-captured slot when told to replace it', () async {
    final captures = midiPresetCaptureRepository(database);
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 1,
      rawSysEx: Uint8List.fromList([0x00]),
    );
    autoReply();
    final service = NuxMg30V5PresetCaptureService(NuxMg30V5PresetReader(engine), captures);

    final summary = await service.captureAll(
      unitId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      onDuplicate: PresetCaptureDecision.overwrite,
      lastProgramNumber: 1,
      readTimeout: _fastTimeout,
    );

    expect(summary.captured, 1);
    expect(summary.overwritten, 1);
    final row = await captures.findByProgramNumber(unitId, 1);
    expect(row!.rawSysEx, isNot([0x00]));
  });

  test('records a timeout as a failure without stopping the rest of the run', () async {
    autoReply(dropRequestsFor: {0});
    final service = NuxMg30V5PresetCaptureService(
      NuxMg30V5PresetReader(engine),
      midiPresetCaptureRepository(database),
    );

    final summary = await service.captureAll(
      unitId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      onDuplicate: PresetCaptureDecision.skip,
      lastProgramNumber: 1,
      readTimeout: _fastTimeout,
    );

    expect(summary.captured, 1);
    expect(summary.failures.map((f) => f.programNumber), [0]);
    expect(summary.stoppedEarly, isFalse);
    expect(summary.failures.single.message, isNotEmpty);
  });

  test('gives up rather than working through a whole bank that cannot answer', () async {
    // Nothing replies, which is what a wrong command or a device that does not
    // support this read looks like. 128 slots x the read timeout is minutes of
    // waiting to be told the same thing 128 times.
    final service = NuxMg30V5PresetCaptureService(
      NuxMg30V5PresetReader(engine),
      midiPresetCaptureRepository(database),
    );

    final summary = await service.captureAll(
      unitId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      onDuplicate: PresetCaptureDecision.skip,
      readTimeout: _fastTimeout,
      giveUpAfterConsecutiveFailures: 3,
    );

    expect(summary.stoppedEarly, isTrue);
    expect(summary.failures, hasLength(3));
    expect(summary.captured, 0);
  });

  test('reports a refused send as the reason, not just a slot number', () async {
    // Disconnected, so the transport refuses every send - the case a capture
    // that showed only "Failed: 0, 1, 2..." could not be told apart from a
    // device that simply never answered.
    await engine.disconnect();
    final service = NuxMg30V5PresetCaptureService(
      NuxMg30V5PresetReader(engine),
      midiPresetCaptureRepository(database),
    );

    final summary = await service.captureAll(
      unitId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      onDuplicate: PresetCaptureDecision.skip,
      readTimeout: _fastTimeout,
      giveUpAfterConsecutiveFailures: 2,
    );

    final groups = groupCaptureFailures(summary.failures);
    expect(groups, hasLength(1), reason: 'one reason, however many slots hit it');
    expect(groups.single.count, 2);
    expect(groups.single.message, contains('while disconnected'));
  });
}
