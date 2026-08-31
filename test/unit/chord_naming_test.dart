import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord_naming.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// Notes read back into the chord they spell, which is the engine run backwards.
void main() {
  List<PitchClass> notes(String written) => [
    for (final name in written.split(' ')) PitchClass.parse(name),
  ];

  List<String> named(String written) => [
    for (final chord in chordsOfNotes(notes(written))) chord.symbol,
  ];

  test('three notes are named as the chord they are', () {
    expect(named('C E G'), ['C']);
    expect(named('A C E'), ['Am']);
    expect(named('C E G B'), ['Cmaj7']);
  });

  test('and which note was pressed first decides what it is called', () {
    // The same three notes both ways round. C E A is A minor whichever end it is read
    // from, and the answer comes back on the root the notes actually have.
    expect(named('C E A'), ['Am']);
    expect(named('A C E'), ['Am']);
  });

  test('a note pressed twice is the same one note', () {
    expect(named('C E G C'), ['C']);
    expect(chordsOfNotes(notes('C C')), isEmpty);
  });

  test('notes that spell more than one chord are given as both', () {
    // A diminished seventh is four chords at once, one on each of its notes, and every
    // book on harmony says so rather than choosing.
    expect(named('C Eb Gb A'), hasLength(4));
    expect(named('C Eb Gb A'), contains('Cdim7'));

    // The same three notes, suspended from either end - which is the ambiguity a
    // suspension is, and the order they were pressed in is what breaks it.
    expect(named('C F G'), ['Csus4', 'Fsus2']);
    expect(named('F C G'), ['Fsus2', 'Csus4']);
  });

  test('and notes that spell nothing are answered with nothing', () {
    expect(chordsOfNotes(notes('C Db')), isEmpty);
    expect(chordsOfNotes(notes('C')), isEmpty);
    expect(chordsOfNotes(const []), isEmpty);
  });
}
