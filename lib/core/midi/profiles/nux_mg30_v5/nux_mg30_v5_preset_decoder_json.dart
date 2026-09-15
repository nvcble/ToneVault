import 'dart:convert';

import 'nux_mg30_v5_preset_decoder.dart';

/// Serializes a [DecodedNuxMg30V5Preset] for `MidiPresetCaptures.decodedSummaryJson`
/// - a record of what one decoder version made of a capture, kept beside the
/// raw bytes so a later decoder can be compared against it without
/// reconnecting to the device.
String encodeDecodedPresetAsJson(DecodedNuxMg30V5Preset preset) => jsonEncode({
  'programNumber': preset.programNumber,
  'name': preset.name,
  'tempoBpm': preset.tempoBpm,
  'signalChainOrder': preset.signalChainOrder,
  'blocks': [
    for (final block in preset.blocks)
      {
        'label': block.label,
        'modelCode': block.modelCode,
        'bypassPerScene': block.bypassPerScene,
        'isParallel': block.isParallel,
      },
  ],
  'unsupportedFields': preset.unsupportedFields.toList(),
});
