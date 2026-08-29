import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/academy/data/lesson_tally.dart';

/// Two numbers, and the reading of them a player sees.
void main() {
  test('nothing counted is not nought per cent, it is nothing', () {
    expect(emptyTally.isEmpty, isTrue);
    expect(emptyTally.isComplete, isFalse);
    expect(emptyTally.fraction, 0);
    expect(emptyTally.percent, 0);
    expect(emptyTally.label, 'No lessons yet');
  });

  test('a percentage is rounded down, never up', () {
    // The one that matters: a hundred and ninety-nine of two hundred is not
    // finished, and rounding to the nearest would say it was.
    expect((lessons: 200, done: 199).percent, 99);
    expect((lessons: 3, done: 1).percent, 33);
    expect((lessons: 3, done: 2).percent, 66);
  });

  test('a hundred per cent is only every lesson', () {
    const tally = (lessons: 4, done: 4);

    expect(tally.percent, 100);
    expect(tally.isComplete, isTrue);
    expect(tally.fraction, 1);
    expect(tally.label, 'All 4 lessons done');
  });

  test('a fraction never leaves nought to one', () {
    // A tally cannot arrive like this from the database, but a progress bar handed
    // 1.5 throws, so it is clamped rather than trusted.
    expect((lessons: 2, done: 5).fraction, 1);
    expect((lessons: 0, done: 3).fraction, 0);
  });

  test('the label says the count first and the shape of it second', () {
    expect((lessons: 8, done: 3).label, '3 of 8 lessons - 37%');
    // Not "0 of 8": a player who has done none of it is told they have not started,
    // which is the same fact in the words they would use.
    expect((lessons: 8, done: 0).label, 'Not started - 8 lessons');
    expect((lessons: 1, done: 0).label, 'Not started - 1 lesson');
    expect((lessons: 1, done: 1).label, 'All 1 lesson done');
  });

  test('a level is the courses in it added up', () {
    final total = sumTallies(const [
      (lessons: 4, done: 4),
      (lessons: 6, done: 1),
      emptyTally,
    ]);

    expect(total, (lessons: 10, done: 5));
    expect(total.percent, 50);
  });

  test('and nothing added up is still nothing', () {
    expect(sumTallies(const []), emptyTally);
  });
}
