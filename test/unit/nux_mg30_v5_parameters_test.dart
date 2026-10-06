import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_block_specs.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_model_names.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_parameters.dart';

void main() {
  group('nuxMg30V5Blocks', () {
    test('names the whole MG-30 chain, in the order signal reaches it', () {
      // Twelve: the eleven the chart names, and the Volume block it does not,
      // which the unit still shows last in its chain.
      expect(nuxMg30V5Blocks, hasLength(12));
      expect(nuxMg30V5Blocks.first.label, 'Wah');
      expect(nuxMg30V5Blocks.last.label, 'Volume');
    });

    test(
      'gives every block a distinct type-select CC and no knob CC overlap',
      () {
        // Volume alone has no type-select CC: the chart gives it none, and a
        // made-up one is how a wrong message gets sent.
        final typeSelectCcs = nuxMg30V5Blocks
            .map((block) => block.typeSelectCc)
            .whereType<int>()
            .toList();
        expect(typeSelectCcs, hasLength(nuxMg30V5Blocks.length - 1));
        expect(typeSelectCcs.toSet(), hasLength(typeSelectCcs.length));

        final allKnobCcs = [
          for (final block in nuxMg30V5Blocks) ...block.knobCcs,
        ];
        expect(allKnobCcs.toSet(), hasLength(allKnobCcs.length));
      },
    );
  });

  group('nuxMg30V5ModelNames', () {
    test('names exactly as many models as the chart counts, per block', () {
      // Two independent sources - the V5 MIDI implementation chart for the
      // counts, NUX's own editor for the names - agreeing block by block is
      // what says the name lists are the right lists in the right order.
      for (final block in nuxMg30V5Blocks) {
        expect(
          nuxMg30V5ModelNames[block.block],
          hasLength(block.modelCount),
          reason: block.label,
        );
      }
    });

    test('a model control stores the code its CC expects', () {
      final amp = nuxMg30V5BlockDefinitions.firstWhere(
        (block) => block.label == 'Amp',
      );

      // QuickTone lists BYPASS ahead of model 1, so position 12 of the seeded
      // selection is model code 12 - the value the type-select CC takes.
      expect(amp.modelNames, hasLength(35));
      expect(amp.modelNames[11], 'BRIT 800');
    });

    test('the Volume block offers no models, having no CC to select one', () {
      final volume = nuxMg30V5BlockDefinitions.firstWhere(
        (block) => block.label == 'Volume',
      );

      expect(volume.modelNames, isEmpty);
    });
  });

  group('nuxMg30V5Parameters', () {
    test('has exactly the 86 rows the V5 chart documents', () {
      expect(nuxMg30V5Parameters, hasLength(86));
    });

    test('never repeats a CC number across blocks and global parameters', () {
      final ccNumbers = nuxMg30V5Parameters
          .map((definition) => definition.ccNumber)
          .toList();

      expect(ccNumbers.toSet(), hasLength(ccNumbers.length));
    });

    test('covers every CC from 0 to 85 with no gaps', () {
      final ccNumbers = nuxMg30V5Parameters
          .map((definition) => definition.ccNumber)
          .toSet();

      expect(ccNumbers, Set<int>.from(List.generate(86, (index) => index)));
    });

    test(
      'keeps the four knob ranges the chart states as narrower than 0-100',
      () {
        final byCc = {
          for (final definition in nuxMg30V5Parameters)
            definition.ccNumber: definition,
        };

        expect((byCc[52]!.min, byCc[52]!.max), (0.0, 6.0)); // Modulation Knob 5
        expect((byCc[57]!.min, byCc[57]!.max), (0.0, 6.0)); // Delay Knob 4
        expect((byCc[66]!.min, byCc[66]!.max), (0.0, 7.0)); // IR Knob 1
        expect((byCc[67]!.min, byCc[67]!.max), (0.0, 2.0)); // IR Knob 2
      },
    );

    test(
      'gives each block\'s model-select parameter the chart\'s documented count',
      () {
        final byCc = {
          for (final definition in nuxMg30V5Parameters)
            definition.ccNumber: definition,
        };

        expect((byCc[3]!.min, byCc[3]!.max), (1.0, 35.0)); // Amp: 35 models
        expect((byCc[2]!.min, byCc[2]!.max), (1.0, 15.0)); // Effect: 15 models
        expect((byCc[9]!.min, byCc[9]!.max), (1.0, 25.0)); // IR: 25 models
      },
    );
  });
}
