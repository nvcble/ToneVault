import 'chord.dart';
import 'chord_type.dart';
import 'pitch_class.dart';

/// Notes read backwards into the chords they spell.
///
/// The rest of the engine works the other way round - a chord is a root and a quality, and
/// the notes fall out of it. This is the question asked from the other end, by a player who
/// has the notes and wants the name.

/// Every chord [notes] spells, in the order the notes were given.
///
/// Each note is tried as the root, because a handful of notes has no root of its own: C E G
/// is C major and C E A is A minor, and which note is underneath is the whole difference.
/// The order they were given decides which answer comes first, so a player who pressed the
/// root first is answered with the chord they were building.
///
/// More than one answer is not a fault. A diminished seventh is four chords at once and
/// every book says so; naming them all is truer than picking one. Empty where the notes
/// spell nothing this engine has a name for, because there is no chord called "C and D"
/// and a guess would be worse than saying nothing.
List<Chord> chordsOfNotes(Iterable<PitchClass> notes) {
  final all = {...notes};

  return [for (final root in all) ?_chordOn(root, all)];
}

Chord? _chordOn(PitchClass root, Set<PitchClass> notes) {
  final type = chordTypeFor([for (final note in notes) root.intervalTo(note)]);
  return type == null ? null : Chord(root, type);
}
