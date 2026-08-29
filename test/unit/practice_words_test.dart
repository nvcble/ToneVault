import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/academy/data/practice_words.dart';

/// The practice a player has put in, in words.
void main() {
  group('how long it was', () {
    test('a short sitting is not given a number', () {
      // "0 min" reads as nothing recorded, and forty seconds of practice is not
      // nothing.
      expect(formatPracticeTime(40), 'less than a minute');
      expect(formatPracticeTime(59), 'less than a minute');
    });

    test('minutes are counted up to the hour', () {
      expect(formatPracticeTime(60), '1 min');
      expect(formatPracticeTime(1800), '30 min');
      expect(formatPracticeTime(3540), '59 min');
    });

    test('an hour is said as an hour', () {
      expect(formatPracticeTime(3600), '1 h');
      expect(formatPracticeTime(7200), '2 h');
    });

    test('and the minutes past it are said with it', () {
      expect(formatPracticeTime(5400), '1 h 30 min');
      expect(formatPracticeTime(9000), '2 h 30 min');
    });

    test('the part-minute is dropped rather than rounded up', () {
      // A minute that has not finished has not been practised, and a total the app
      // rounded up is a total the player did not earn.
      expect(formatPracticeTime(119), '1 min');
      expect(formatPracticeTime(3599), '59 min');
      expect(formatPracticeTime(3659), '1 h');
    });
  });

  group('and over how many sittings', () {
    test('one sitting is named as one, not counted', () {
      expect(
        practiceSummary(seconds: 1800, sittings: 1),
        '30 min in one sitting',
      );
    });

    test('several are counted', () {
      expect(
        practiceSummary(seconds: 5400, sittings: 4),
        '1 h 30 min over 4 sittings',
      );
    });

    test('practice with no sittings behind it is left as the time alone', () {
      // What a phone that upgraded into this reads: the total was recorded before
      // sittings were, so "over 0 sittings" would be the app calling its own record
      // empty and any number would be inventing evenings.
      expect(practiceSummary(seconds: 5400, sittings: 0), '1 h 30 min');
    });
  });
}
