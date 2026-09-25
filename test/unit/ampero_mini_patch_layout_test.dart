import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_patch_layout.dart';

void main() {
  group('amperoMiniPatchLabel', () {
    test('matches the pedal at the boundary the user checked by hand', () {
      // VERIFIED ON HARDWARE 2026-09-16: comparing the app against the pedal,
      // the last user patch reads P33-3 and the next patch reads F01-1. This
      // is the observation that corrected a bank numbering that was one low.
      expect(amperoMiniPatchLabel(98), 'P33-3');
      expect(amperoMiniPatchLabel(99), 'F01-1');
    });

    test('banks are numbered from 01, so the very first patch is P01-1', () {
      expect(amperoMiniPatchLabel(0), 'P01-1');
      expect(amperoMiniPatchLabel(1), 'P01-2');
      expect(amperoMiniPatchLabel(2), 'P01-3');
      expect(amperoMiniPatchLabel(3), 'P02-1');
    });

    test('the factory half restarts its bank numbering', () {
      expect(amperoMiniPatchLabel(101), 'F01-3');
      expect(amperoMiniPatchLabel(102), 'F02-1');
      expect(amperoMiniPatchLabel(amperoMiniPatchCount - 1), 'F33-3');
    });

    test('every index produces a label the pedal could show', () {
      // Guards the arithmetic end to end: 33 banks of 3 in each half, no
      // bank 00 and no bank 34.
      for (var index = 0; index < amperoMiniPatchCount; index++) {
        expect(
          amperoMiniPatchLabel(index),
          matches(RegExp(r'^[PF](0[1-9]|[12]\d|3[0-3])-[1-3]$')),
          reason: 'index $index',
        );
      }
    });

    test('a label is never reused between the two halves', () {
      final labels = {
        for (var index = 0; index < amperoMiniPatchCount; index++)
          amperoMiniPatchLabel(index),
      };

      expect(labels, hasLength(amperoMiniPatchCount));
    });
  });

  group('patch layout', () {
    test('holds Hotone\'s published counts, not a Program Change ceiling', () {
      // OFFICIAL: "Patches: 198 (99 user patches, 99 factory patches)".
      expect(amperoMiniPatchCount, 198);
      expect(amperoMiniUserPatchCount, 99);
      expect(amperoMiniFactoryPatchCount, 99);
    });

    test('each half is 33 banks of three', () {
      expect(amperoMiniBanksPerSection, 33);
      expect(
        amperoMiniBanksPerSection * amperoMiniPatchesPerBank,
        amperoMiniUserPatchCount,
      );
    });

    test('the user and factory halves split at index 99', () {
      expect(amperoMiniIsUserPatch(98), isTrue);
      expect(amperoMiniIsUserPatch(99), isFalse);
      expect(amperoMiniIsUserPatch(-1), isFalse);
    });

    test('every user patch is selectable over MIDI', () {
      for (var index = 0; index < amperoMiniUserPatchCount; index++) {
        expect(amperoMiniIsSelectableOverMidi(index), isTrue);
      }
    });

    test('no factory patch is selectable over MIDI', () {
      // VERIFIED ON HARDWARE 2026-09-16: Program Change 99 - F01-1 - left the
      // pedal on the patch it already had, while Program Change 1 loaded P01-2
      // in the same session. The whole factory half is refused rather than
      // sent-and-hoped-for, since a Program Change this pedal ignores is
      // indistinguishable from a successful one at this end.
      expect(amperoMiniIsSelectableOverMidi(99), isFalse);
      expect(amperoMiniIsSelectableOverMidi(127), isFalse);
      expect(amperoMiniIsSelectableOverMidi(amperoMiniPatchCount - 1), isFalse);
    });

    test('a negative index is not selectable', () {
      expect(amperoMiniIsSelectableOverMidi(-1), isFalse);
    });

    test('exactly the 99 factory patches are the unreachable ones', () {
      final unreachable = [
        for (var n = 0; n < amperoMiniPatchCount; n++)
          if (!amperoMiniIsSelectableOverMidi(n)) n,
      ];

      expect(unreachable, hasLength(amperoMiniFactoryPatchCount));
      expect(unreachable.every((n) => !amperoMiniIsUserPatch(n)), isTrue);
    });
  });
}
