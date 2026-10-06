import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_block_specs.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_layout_probe.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';

/// A dump with the block region written at [base] the way firmware v4.0.3 lays
/// it out, so a scan that works finds [base] and nothing else.
List<int> _dumpWithChainOrderAt(int base, {int length = 222}) {
  final bytes = List<int>.filled(length, 0xFF);
  final offsets = nuxMg30V5V403ChainOrderOffsets;
  final first = offsets.first.$1;

  for (var index = 0; index < offsets.length; index++) {
    final (offset, halved) = offsets[index];
    bytes[base + offset - first] = halved ? index * 2 : index;
  }
  return bytes;
}

void main() {
  test('the probe and the decoder read the same 12 blocks in step', () {
    // The probe checks a model code against the chart's range for the block at
    // the same index, so the two lists have to stay in the same order.
    expect(
      nuxMg30V5V403BlockSpecs.map((spec) => spec.label),
      nuxMg30V5Blocks.map((block) => block.label),
    );
  });

  test('finds the offset a chain-order region was written at', () {
    final findings = probeNuxMg30V5BlockLayout([
      _dumpWithChainOrderAt(147),
      _dumpWithChainOrderAt(147),
    ]);

    expect(findings.dumps, 2);
    expect(findings.frameLengths, {222});
    expect(findings.chainOrderBases, contains(147));
  });

  test('keeps only the offsets every dump agrees on', () {
    final findings = probeNuxMg30V5BlockLayout([
      _dumpWithChainOrderAt(147),
      _dumpWithChainOrderAt(40),
    ]);

    // One preset can read as a permutation by chance; two written at different
    // offsets cannot both be right, and neither offset survives the other.
    expect(findings.chainOrderBases, isNot(contains(147)));
    expect(findings.chainOrderBases, isNot(contains(40)));
  });

  test('reports nothing for no dumps rather than every offset', () {
    final findings = probeNuxMg30V5BlockLayout(const []);

    expect(findings.dumps, 0);
    expect(findings.chainOrderBases, isEmpty);
    expect(findings.modelCodeBases, isEmpty);
  });

  test('does not report a run of zeros as a model-code region', () {
    // Padding satisfies every range there is. Reporting it would bury the
    // offsets worth checking under one candidate per byte of the frame.
    final findings = probeNuxMg30V5BlockLayout([List<int>.filled(222, 0)]);

    expect(findings.modelCodeBases, isEmpty);
  });

  test('never reads past the end of a short frame', () {
    // A truncated capture is a thing the device really sends; the scan has to
    // stop rather than throw on it.
    expect(
      () => probeNuxMg30V5BlockLayout([
        const [0xF0, 0x43, 0x58, 0xF7],
      ]),
      returnsNormally,
    );
  });
}
