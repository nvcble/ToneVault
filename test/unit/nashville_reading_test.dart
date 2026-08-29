import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/data/nashville_reading.dart';

/// A typed line read either way round, and what happens to a line that is wrong.
void main() {
  final c = Scale(PitchClass.parse('C'), ScaleType.major);
  final eb = Scale(PitchClass.parse('Eb'), ScaleType.major);

  test('numbers become the chords of the key', () {
    final reading = readNashville(
      '1 5 6m 4',
      c,
      NashvilleDirection.numbersToChords,
    );

    expect(reading!.isRead, isTrue);
    expect(reading.answer, 'C   G   Am   F');
  });

  test('and chords become the numbers they are called by', () {
    final reading = readNashville(
      'C G Am F',
      c,
      NashvilleDirection.chordsToNumbers,
    );

    expect(reading!.isRead, isTrue);
    expect(reading.answer, '1 5 6 4');
  });

  test('the chords are spelled the way the key spells its notes', () {
    // A four in Eb is Ab, not the G# it also is. This is the whole reason the key is
    // handed to the reader rather than the notes being named from the semitone.
    final reading = readNashville(
      '1 4 5',
      eb,
      NashvilleDirection.numbersToChords,
    );

    expect(reading!.answer, 'Eb   Ab   Bb');
  });

  test('a line is read however a chart separates it', () {
    expect(
      readNashville('1-5-6m-4', c, NashvilleDirection.numbersToChords)!.answer,
      'C   G   Am   F',
    );
    expect(
      readNashville(
        'C | G | Am | F',
        c,
        NashvilleDirection.chordsToNumbers,
      )!.answer,
      '1 5 6 4',
    );
  });

  test(
    'a line the engine cannot read comes back as a problem, not a throw',
    () {
      final reading = readNashville(
        '1 5 9',
        c,
        NashvilleDirection.numbersToChords,
      );

      expect(reading!.isRead, isFalse);
      expect(reading.answer, isNull);
      expect(reading.problem, '"9" is not a chord number in a key.');
    },
  );

  test('and so does a word that is not a chord', () {
    final reading = readNashville(
      'C G banana',
      c,
      NashvilleDirection.chordsToNumbers,
    );

    expect(reading!.isRead, isFalse);
    expect(reading.problem, isNotEmpty);
  });

  test('nothing typed is nothing to say, in either direction', () {
    for (final direction in NashvilleDirection.values) {
      expect(readNashville('', c, direction), isNull);
      expect(readNashville('   ', c, direction), isNull);
    }
  });

  test('each direction says what it wants and shows one', () {
    for (final direction in NashvilleDirection.values) {
      expect(direction.label, isNotEmpty);
      expect(direction.prompt, isNotEmpty);
      expect(direction.example, isNotEmpty);
    }
    expect(NashvilleDirection.numbersToChords.example, '1 5 6m 4');
    expect(NashvilleDirection.chordsToNumbers.example, 'C G Am F');
  });

  test('an answer read back the other way is the line again', () {
    final chords = readNashville(
      '1 5 6m 4',
      c,
      NashvilleDirection.numbersToChords,
    )!.answer!;
    final numbers = readNashville(
      chords,
      c,
      NashvilleDirection.chordsToNumbers,
    )!.answer!;

    // `6m` comes back as `6`, because minor is what C major has on its sixth degree
    // and a bare number means whatever the key has there.
    expect(numbers, '1 5 6 4');
  });
}
