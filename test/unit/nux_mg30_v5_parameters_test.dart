import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_block_specs.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_parameters.dart';

void main() {
  group('nuxMg30V5Blocks', () {
    test('names eleven blocks, the real MG-30 chain rather than the shorthand', () {
      expect(nuxMg30V5Blocks, hasLength(11));
    });

    test('gives every block a distinct type-select CC and no knob CC overlap', () {
      final typeSelectCcs = nuxMg30V5Blocks.map((block) => block.typeSelectCc).toList();
      expect(typeSelectCcs.toSet(), hasLength(typeSelectCcs.length));

      final allKnobCcs = [for (final block in nuxMg30V5Blocks) ...block.knobCcs];
      expect(allKnobCcs.toSet(), hasLength(allKnobCcs.length));
    });
  });

  group('nuxMg30V5Parameters', () {
    test('has exactly the 86 rows the V5 chart documents', () {
      expect(nuxMg30V5Parameters, hasLength(86));
    });

    test('never repeats a CC number across blocks and global parameters', () {
      final ccNumbers = nuxMg30V5Parameters.map((definition) => definition.ccNumber).toList();

      expect(ccNumbers.toSet(), hasLength(ccNumbers.length));
    });

    test('covers every CC from 0 to 85 with no gaps', () {
      final ccNumbers = nuxMg30V5Parameters.map((definition) => definition.ccNumber).toSet();

      expect(ccNumbers, Set<int>.from(List.generate(86, (index) => index)));
    });

    test('keeps the four knob ranges the chart states as narrower than 0-100', () {
      final byCc = {for (final definition in nuxMg30V5Parameters) definition.ccNumber: definition};

      expect((byCc[52]!.min, byCc[52]!.max), (0.0, 6.0)); // Modulation Knob 5
      expect((byCc[57]!.min, byCc[57]!.max), (0.0, 6.0)); // Delay Knob 4
      expect((byCc[66]!.min, byCc[66]!.max), (0.0, 7.0)); // IR Knob 1
      expect((byCc[67]!.min, byCc[67]!.max), (0.0, 2.0)); // IR Knob 2
    });

    test('gives each block\'s model-select parameter the chart\'s documented count', () {
      final byCc = {for (final definition in nuxMg30V5Parameters) definition.ccNumber: definition};

      expect((byCc[3]!.min, byCc[3]!.max), (1.0, 35.0)); // Amp: 35 models
      expect((byCc[2]!.min, byCc[2]!.max), (1.0, 15.0)); // Effect: 15 models
      expect((byCc[9]!.min, byCc[9]!.max), (1.0, 25.0)); // IR: 25 models
    });
  });
}
