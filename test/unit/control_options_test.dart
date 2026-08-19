import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/values/control_options.dart';

void main() {
  group('encodeControlOptions', () {
    test('round-trips the positions of a selection', () {
      const options = ['Chorus', 'Vibrato', 'Rotary'];

      expect(decodeControlOptions(encodeControlOptions(options)), options);
    });

    test('stores nothing for a control with no positions', () {
      expect(encodeControlOptions(const []), isNull);
    });

    test('keeps a label that would break naive delimiting', () {
      const options = ['Bass / Mid', 'Full, wet'];

      expect(decodeControlOptions(encodeControlOptions(options)), options);
    });
  });

  group('decodeControlOptions', () {
    test('reads an unset column as no positions', () {
      expect(decodeControlOptions(null), isEmpty);
      expect(decodeControlOptions(''), isEmpty);
    });

    test('reads a hand-edited value as no positions rather than throwing', () {
      // Anything that is not a JSON array of strings would otherwise take down
      // every screen that lists this control.
      expect(decodeControlOptions('not json'), isEmpty);
      expect(decodeControlOptions('"Chorus"'), isEmpty);
      expect(decodeControlOptions('{"1":"Chorus"}'), isEmpty);
    });

    test('keeps the entries of a partly wrong array', () {
      expect(decodeControlOptions('["Chorus", 7, null]'), ['Chorus']);
    });
  });
}
