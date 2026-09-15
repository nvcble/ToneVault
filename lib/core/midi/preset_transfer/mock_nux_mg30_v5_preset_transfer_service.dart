import '../midi_support_level.dart';
import 'imported_preset.dart';
import 'nux_mg30_v5_preset_transfer_service.dart';

/// Simulated presets for developing and testing the import pipeline before a
/// real SysEx protocol exists.
///
/// Every value here is invented, not read off hardware - exactly what
/// [NuxMg30V5PresetTransferService]'s own documentation warns against
/// passing off as real. This class is wired into tests only; the app's own
/// provider graph never constructs it, so no screen a real user opens can
/// end up showing simulated data as if it came from their device.
class MockNuxMg30V5PresetTransferService implements NuxMg30V5PresetTransferService {
  const MockNuxMg30V5PresetTransferService({
    this.presetCount = 3,
    this.delay = const Duration(milliseconds: 10),
  });

  final int presetCount;
  final Duration delay;

  @override
  Future<List<ImportedPreset>> importAllPresets({
    void Function(int completed, int total)? onProgress,
  }) async {
    final presets = <ImportedPreset>[];
    for (var i = 0; i < presetCount; i++) {
      await Future<void>.delayed(delay);
      presets.add(_presetAt(i));
      onProgress?.call(i + 1, presetCount);
    }
    return presets;
  }

  /// Block labels and parameter names match `nuxMg30V5Parameters` so tests
  /// exercise the same matching the import pipeline would use against a real
  /// device - only the values themselves are made up.
  ImportedPreset _presetAt(int index) => ImportedPreset(
    programNumber: index + 1,
    name: 'Simulated Patch ${index + 1}',
    confidence: MidiSupportLevel.unknown,
    blocks: const [
      ImportedBlock(label: 'Amp', modelNumber: 3, parameters: {'Amp Knob 1': 60, 'Amp Knob 2': 45}),
      ImportedBlock(label: 'Delay', modelNumber: 1, parameters: {'Delay Knob 1': 30}),
    ],
  );
}
