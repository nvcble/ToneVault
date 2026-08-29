import 'pitch_class.dart';
import 'tuning.dart';

/// One place on the neck: a string, a fret, and the note it gives.
class FretNote {
  const FretNote({
    required this.string,
    required this.fret,
    required this.note,
  });

  /// 0 is the lowest-sounding string, which a guitarist calls the sixth.
  final int string;

  /// 0 is the open string.
  final int fret;

  final PitchClass note;

  @override
  bool operator ==(Object other) =>
      other is FretNote &&
      other.string == string &&
      other.fret == fret &&
      other.note == note;

  @override
  int get hashCode => Object.hash(string, fret, note);

  @override
  String toString() => 'string $string fret $fret: $note';
}

/// The stretch of neck a diagram is looking at.
///
/// Where the notes are is arithmetic, not drawing: a fret is a semitone, so a window
/// of the neck is a tuning plus two fret numbers. Keeping that here means the widget
/// that draws a fretboard has no music in it, and every diagram in the app - a scale
/// shape, a chord voicing, an ear-training answer - is the same widget handed a
/// different set of notes.
class Fretboard {
  const Fretboard({
    this.tuning = Tuning.standard,
    this.firstFret = 0,
    this.fretCount = 12,
  });

  final Tuning tuning;

  /// The lowest fret drawn. 0 means the nut is showing.
  final int firstFret;

  /// How many frets after [firstFret] are drawn.
  final int fretCount;

  int get lastFret => firstFret + fretCount;

  PitchClass noteAt(int string, int fret) => tuning.noteAt(string, fret);

  /// Every place in the window where one of [notes] can be played, string by string.
  ///
  /// All of them, rather than one shape. Which of these to show as a fingering is a
  /// question about hands and about the lesson, and neither is something this class
  /// can answer - but a scale drawn across the whole neck is what shows a player that
  /// the shape they learnt is the same five notes further up.
  List<FretNote> positionsOf(Iterable<PitchClass> notes) {
    final wanted = notes.toSet();
    return [
      for (var string = 0; string < tuning.stringCount; string++)
        for (var fret = firstFret; fret <= lastFret; fret++)
          if (wanted.contains(noteAt(string, fret)))
            FretNote(string: string, fret: fret, note: noteAt(string, fret)),
    ];
  }

  /// The lowest place on each string where [note] is playable in the window. What a
  /// player looks for when they are asked to find a note rather than play a shape.
  List<FretNote> lowestOf(PitchClass note) {
    final found = <FretNote>[];
    for (var string = 0; string < tuning.stringCount; string++) {
      for (var fret = firstFret; fret <= lastFret; fret++) {
        if (noteAt(string, fret) == note) {
          found.add(FretNote(string: string, fret: fret, note: note));
          break;
        }
      }
    }
    return found;
  }

  /// The frets a guitar has a dot on, which is how a player finds their place.
  static bool isInlaid(int fret) =>
      const {3, 5, 7, 9, 12, 15, 17, 19, 21, 24}.contains(fret);
}
