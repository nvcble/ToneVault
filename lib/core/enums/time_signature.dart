/// A time signature the metronome can count.
///
/// Named by what it is rather than by numbers, because the enum name is what goes
/// into the database and into a course file: `sixEight` keeps meaning 6/8 after
/// the app has moved on, where an integer pair would need both halves read back
/// and trusted.
///
/// [beats] is how many clicks make a bar and [beatUnit] is the note each click
/// stands for. The compound signatures are counted in their written unit - 6/8 is
/// six eighth-note clicks, not two dotted-quarter ones - because a player learning
/// to feel 6/8 needs to hear all six before they can hear the two.
enum TimeSignature {
  twoFour(2, 4),
  threeFour(3, 4),
  fourFour(4, 4),
  fiveFour(5, 4),
  sixEight(6, 8),
  sevenEight(7, 8),
  nineEight(9, 8),
  twelveEight(12, 8);

  const TimeSignature(this.beats, this.beatUnit);

  final int beats;
  final int beatUnit;

  String get label => '$beats/$beatUnit';

  /// How long one click lasts at [bpm], where the tempo is given in the unit the
  /// signature counts in. A bar of 6/8 at 120 is six clicks of half a second.
  Duration clickInterval(int bpm) =>
      Duration(microseconds: Duration.microsecondsPerMinute ~/ bpm);
}
