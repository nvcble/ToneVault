import '../../../core/music/chord_voicing.dart';

/// A chord box read out in words.
///
/// A diagram is the quickest way to take a shape in and the worst way to check you have
/// understood it: six dots look the same whether or not they are the ones you meant. So
/// every voicing the app draws it also writes out - which string, which fret, which
/// finger, which note - and a player who is unsure can read rather than squint. It is
/// also all a screen reader has to go on, because a row of coloured boxes tells it
/// nothing.
///
/// Words, not layout. Nothing here builds a widget and nothing here decides a colour, so
/// the same sentences serve the chord browser, a lesson and a spoken description.

/// What a player calls a string: the lowest-sounding one is the sixth.
///
/// The engine counts strings up from the bass because that is the order they are wired
/// and tuned in; a guitarist counts down from the treble. Every number that reaches a
/// player goes through here, so the two orders never get mixed up in a sentence.
String stringName(int string, {int stringCount = 6}) =>
    '${ordinal(stringCount - string)} string';

/// The fingers as a teacher names them, rather than as the shape table numbers them.
String fingerName(int finger) => switch (finger) {
  1 => 'index',
  2 => 'middle',
  3 => 'ring',
  4 => 'little',
  _ => 'thumb',
};

/// Where the shape sits and how much of a stretch it is.
String voicingPlace(ChordVoicing voicing) {
  final span = voicing.span == 1 ? 'one fret' : '${voicing.span} frets';
  final where = voicing.isOpen
      ? 'Open'
      : 'From the ${ordinal(voicing.lowestHeldFret)} fret';
  return '$where, $span under the hand';
}

/// One line per string, lowest first: what the hand does to it.
List<String> voicingWords(ChordVoicing voicing) => [
  for (var string = 0; string < voicing.stringCount; string++)
    '${stringName(string, stringCount: voicing.stringCount)}: '
        '${_whatHappensOn(voicing, string)}',
];

String _whatHappensOn(ChordVoicing voicing, int string) {
  final fret = voicing.fretOn(string);
  if (fret == null) {
    return 'not played';
  }

  final note = voicing
      .noteOn(string)!
      .name(flats: voicing.chord.notesPreferFlats);
  if (fret == 0) {
    return 'open, $note';
  }

  final finger = voicing.fingerOn(string);
  final held = finger == null ? '' : ', ${fingerName(finger)} finger';
  return '${ordinal(fret)} fret, $note$held';
}

/// `1st`, `2nd`, `12th`. Frets and strings are both counted, and both are read aloud.
String ordinal(int number) {
  final suffix = switch (number % 100) {
    11 || 12 || 13 => 'th',
    _ => switch (number % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    },
  };
  return '$number$suffix';
}
