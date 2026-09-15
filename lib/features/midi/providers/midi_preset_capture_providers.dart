import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_preset_capture_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/midi_preset_capture_repository.dart';

final Provider<MidiPresetCaptureDao> midiPresetCaptureDaoProvider = Provider<MidiPresetCaptureDao>(
  (ref) => MidiPresetCaptureDao(ref.watch(appDatabaseProvider)),
);

final Provider<MidiPresetCaptureRepository> midiPresetCaptureRepositoryProvider =
    Provider<MidiPresetCaptureRepository>(
      (ref) => MidiPresetCaptureRepository(ref.watch(midiPresetCaptureDaoProvider)),
    );

/// Every capture stored for one unit, program number ascending.
final StreamProviderFamily<List<MidiPresetCapture>, int> midiPresetCapturesProvider =
    StreamProvider.family<List<MidiPresetCapture>, int>(
      (ref, pedalId) => ref.watch(midiPresetCaptureRepositoryProvider).watchCaptures(pedalId),
    );
