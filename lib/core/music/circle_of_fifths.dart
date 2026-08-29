import 'interval.dart';
import 'pitch_class.dart';
import 'scale.dart';
import 'scale_type.dart';

/// Key relationships, all of them counted rather than listed.
///
/// The circle of fifths is not a diagram this file draws - it is the observation that
/// going up a fifth twelve times passes every key once, and that keys a step apart on
/// that circle share all but one note. Everything here is that one fact applied.

/// [steps] fifths up from a note, or down where the number is negative. Seven up
/// from C is C#, seven down is Cb; both come out as the same fret, which is exactly
/// what the circle closing means.
PitchClass fifthsFrom(PitchClass root, int steps) =>
    root.transpose(perfectFifth * steps);

/// How many sharps a key is written with, or flats as a negative number. C is 0, G
/// is 1, F is -1, and the answer past six is the same key spelled the other way.
///
/// Counted from the distance round the circle, so there is no table of key signatures
/// here to disagree with the scales.
int keySignature(Scale key) {
  final tonic = key.type.isMinorSounding
      ? key.root.transpose(minorThird)
      : key.root;
  final fifths = (tonic.semitone * 7) % 12;
  return fifths > 6 ? fifths - 12 : fifths;
}

/// The minor key that shares a key signature with a major one, and back the other
/// way. A sixth up, or a third down, which is the same note.
Scale relativeMinor(Scale majorKey) =>
    Scale(majorKey.root.transpose(majorSixth), ScaleType.minor);

Scale relativeMajor(Scale minorKey) =>
    Scale(minorKey.root.transpose(minorThird), ScaleType.major);

/// The keys next door: a fifth either way, and the relative one. These are the keys a
/// song modulates to without anybody feeling it happen, because each shares six of
/// its seven notes with where it started.
List<Scale> neighbourKeys(Scale key) {
  final minorSounding = key.type.isMinorSounding;
  final type = minorSounding ? ScaleType.minor : ScaleType.major;

  return [
    Scale(fifthsFrom(key.root, 1), type),
    Scale(fifthsFrom(key.root, -1), type),
    minorSounding ? relativeMajor(key) : relativeMinor(key),
  ];
}

/// The twelve keys in the order a musician practises them: round the circle by
/// fourths, which is the order chord progressions actually move in.
List<Scale> cycleOfFourths(ScaleType type, {PitchClass? from}) {
  final start = from ?? PitchClass(0);
  return [
    for (var step = 0; step < 12; step++) Scale(fifthsFrom(start, -step), type),
  ];
}

/// How far apart two keys are on the circle, counted the short way round. 0 is the
/// same key, 1 is next door, 6 is as far as two keys get.
int fifthsBetween(PitchClass from, PitchClass to) {
  final distance = (from.intervalTo(to) * 7) % 12;
  return distance > 6 ? 12 - distance : distance;
}
