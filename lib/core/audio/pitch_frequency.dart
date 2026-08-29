import 'dart:math';

import '../music/chord.dart';
import '../music/pitch_class.dart';

/// Turning the notes the theory engine works in into pitches that can be sounded.
///
/// The engine deals in pitch classes, which have no octave: the third of C is E,
/// wherever it is played. Sound needs the octave back, so this is where it is put on,
/// with MIDI numbers as the middle step because they are integers and every
/// instrument, chart and library counts them the same way.

/// Middle C, and the octave a chord is voiced in by default.
///
/// A guitar sounds an octave lower than it is written, and the low open E is MIDI 40.
/// Voicing a chord from here puts it in the range a guitar actually plays in rather
/// than in the whistle above the twelfth fret.
const int middleC = 60;
const int guitarLowE = 40;

/// Concert pitch. A4 is 440 Hz and MIDI 69, and every other note follows from those
/// two numbers and twelve equal steps to the octave.
const double concertA = 440;
const int concertAMidi = 69;

double frequencyOfMidi(int midi) =>
    concertA * pow(2, (midi - concertAMidi) / 12);

/// The MIDI number of a note in a given octave, counting as MIDI does: C4 is 60.
int midiOf(PitchClass note, {int octave = 4}) =>
    (octave + 1) * 12 + note.semitone;

/// The lowest MIDI number at or above [from] that sounds [note].
///
/// Used to voice a chord upwards from a bass note without the caller doing modular
/// arithmetic on octaves.
int midiAtOrAbove(PitchClass note, int from) {
  final offset = (note.semitone - from % 12) % 12;
  return from + offset;
}

/// A chord as notes to sound, stacked upwards in the order the chord is spelled.
///
/// The intervals are taken as written rather than folded into one octave, so a ninth
/// sounds above the seventh and not next to the root - which is the difference between
/// a chord a player recognises and a cluster. A slash chord puts its bass note
/// underneath, because that note being lowest is the whole point of writing it.
List<int> voicingOf(Chord chord, {int from = guitarLowE}) {
  final root = midiAtOrAbove(chord.root, from);
  final notes = [for (final interval in chord.type.intervals) root + interval];

  final bass = chord.bass;
  if (bass == null) {
    return notes;
  }

  final under = midiAtOrAbove(bass, from - 12);
  return [under, ...notes];
}

/// The same chord voiced so that one named interval of it is the highest note.
///
/// Which note is on top is what a voicing sounds like: the same Cmaj7 with the third
/// on top and with the seventh on top are two colours, and hearing which is which is
/// the ear training that separates a player who knows chords from one who knows
/// shapes. Everything above the wanted note is dropped an octave rather than the
/// wanted note being raised, so the chord stays in one register.
List<int> voicingTopped(Chord chord, int interval, {int from = middleC - 12}) {
  final root = midiAtOrAbove(chord.root, from);
  final notes = [
    for (final each in chord.type.intervals)
      root + (each > interval ? each - 12 : each),
  ];
  return notes..sort();
}
