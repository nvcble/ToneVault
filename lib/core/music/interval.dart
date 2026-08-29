/// Distances between notes, in semitones.
///
/// Named constants and a label, rather than a class. An interval in this engine is
/// only ever a number of semitones being added to a pitch class, and wrapping that
/// in a type would add ceremony to every scale formula and chord stack in here
/// without answering a question anybody asks.
///
/// The compound intervals matter to naming, not to arithmetic: a ninth is a second
/// an octave up, and both land on the same pitch class. They are kept apart here so
/// a chord can be described as having a ninth rather than a second, which is what a
/// player calls it.
const int unison = 0;
const int minorSecond = 1;
const int majorSecond = 2;
const int minorThird = 3;
const int majorThird = 4;
const int perfectFourth = 5;
const int tritone = 6;
const int perfectFifth = 7;
const int minorSixth = 8;
const int majorSixth = 9;
const int minorSeventh = 10;
const int majorSeventh = 11;
const int octave = 12;
const int minorNinth = 13;
const int majorNinth = 14;
const int augmentedNinth = 15;
const int eleventh = 17;
const int augmentedEleventh = 18;
const int thirteenth = 21;

/// Flats rather than sharps, because a scale is written down as flattened degrees:
/// a minor third is a flat three and nobody calls it a sharp two.
const List<String> _degreeNames = [
  '1',
  'b2',
  '2',
  'b3',
  '3',
  '4',
  'b5',
  '5',
  'b6',
  '6',
  'b7',
  '7',
];

const List<String> _labels = [
  'unison',
  'minor 2nd',
  'major 2nd',
  'minor 3rd',
  'major 3rd',
  'perfect 4th',
  'tritone',
  'perfect 5th',
  'minor 6th',
  'major 6th',
  'minor 7th',
  'major 7th',
];

/// What to call an interval. Anything an octave or more is named by the simple
/// interval it reduces to, with the octaves said separately, because "two octaves
/// and a major third" is how a musician says it and "28 semitones" is not.
String intervalLabel(int semitones) {
  final simple = semitones % 12;
  final octaves = semitones ~/ 12;

  if (octaves == 0) {
    return _labels[simple];
  }

  // "An octave and a major 2nd", not "1 octave and a major 2nd".
  final octaveText = octaves == 1 ? 'octave' : '$octaves octaves';
  return simple == 0 ? octaveText : '$octaveText and a ${_labels[simple]}';
}

/// Every name an interval will answer to, for anything that has to read a distance out
/// of typed words rather than count semitones.
///
/// Built from the labels rather than written out again, so a name a diagram shows is a
/// name a search can find. The rest are the other words players use for the same
/// distance: a tritone is a flat 5th to a guitarist and a sharp 4th to whoever wrote the
/// chart, and a tone is a major 2nd to everybody who has ever tuned up.
///
/// Unmodifiable, because a caller adding a name here would be teaching the engine a word
/// only that caller knows.
Map<String, int> get intervalNames => Map.unmodifiable(_intervalNames);

final Map<String, int> _intervalNames = {
  for (var semitones = 0; semitones < _labels.length; semitones++)
    _labels[semitones]: semitones,
  'octave': octave,
  'perfect octave': octave,
  'perfect unison': unison,
  'diminished 5th': tritone,
  'augmented 4th': tritone,
  'flat 5th': tritone,
  'sharp 4th': tritone,
  'semitone': minorSecond,
  'half step': minorSecond,
  'tone': majorSecond,
  'whole step': majorSecond,
};

/// The distance a written name means, or null where those words name no interval.
int? intervalFromName(String written) =>
    _intervalNames[written.trim().toLowerCase()];

/// What a player calls the interval when they are counting from the root: `1`, `b3`,
/// `5`, `b7`. This is how a scale is taught - the minor pentatonic is 1, b3, 4, 5, b7
/// in every key - and it is what goes inside the dots on a fretboard.
///
/// Compound intervals are numbered as extensions, because a note an octave and a tone
/// above the root is a ninth to everybody who plays one.
String degreeLabel(int semitones) {
  final simple = _degreeNames[semitones % 12];
  if (semitones < 12) {
    return simple;
  }

  final accidental = simple.length > 1 ? simple[0] : '';
  final number = int.parse(simple.substring(accidental.length)) + 7;
  return '$accidental$number';
}

/// The degree of the scale an interval lands on, counting the root as 1, so a
/// perfect fifth is 5 and a ninth is 9. Used for naming chord extensions, where the
/// number is the whole point.
///
/// Semitones alone cannot tell a sharp ninth from a minor tenth, because they are
/// the same distance. Where that distinction matters - naming an altered dominant -
/// the chord type carries its own symbol instead of asking here.
int intervalDegree(int semitones) {
  const degrees = [1, 2, 2, 3, 3, 4, 4, 5, 6, 6, 7, 7];
  return degrees[semitones % 12] + 7 * (semitones ~/ 12);
}
