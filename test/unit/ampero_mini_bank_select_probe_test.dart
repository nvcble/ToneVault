import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_bank_select_probe.dart';

void main() {
  group('amperoMiniBankSelectAttempts', () {
    test('offers four layouts for the first factory patch', () {
      final attempts = amperoMiniBankSelectAttempts(99);

      expect(attempts, hasLength(4));
      expect(
        attempts.map((AmperoMiniBankSelectAttempt a) => a.summary),
        containsAll(<String>['CC0=1, CC32=0, PC 0', 'CC0=1, PC 0']),
      );
    });

    test(
      'counts the program number from F01-1, not from the absolute index',
      () {
        // F02-1 is index 102, the fourth factory patch, so program 3.
        expect(amperoMiniBankSelectAttempts(102).first.program, 3);
      },
    );

    test('drops a layout whose program number will not fit in seven bits', () {
      // The absolute-index layout is the only one that can overflow, and it
      // does from index 128 on - truncating it would send a different patch.
      final attempts = amperoMiniBankSelectAttempts(197);

      expect(attempts, hasLength(3));
      expect(
        attempts.every((AmperoMiniBankSelectAttempt a) => a.program <= 127),
        isTrue,
      );
    });

    test(
      'every layout is a Bank Select pair or MSB, then a Program Change',
      () {
        for (final attempt in amperoMiniBankSelectAttempts(99)) {
          final messages = attempt.messages(0);

          expect(messages.last, isA<ProgramChangeMessage>());
          final ccs = messages.whereType<ControlChangeMessage>().toList();
          expect(ccs.first.controller, 0);
          expect(
            ccs.length == 2 ? ccs.last.controller : 32,
            32,
            reason: 'an LSB, when sent at all, must be CC 32',
          );
        }
      },
    );

    test('a user patch keeps only the layout that is a plain selection', () {
      // The sheet is never opened for a user patch - a plain Program Change
      // already reaches those. If it were, the three factory-half layouts
      // would compute a negative program number and are dropped rather than
      // sent as something else.
      final attempts = amperoMiniBankSelectAttempts(0);

      expect(attempts, hasLength(1));
      expect(attempts.single.program, 0);
    });
  });
}
