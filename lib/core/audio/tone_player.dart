/// Something that can sound notes.
///
/// An interface because the app is full of places that want a chord played and none of
/// them should know how: the ear training asks for a chord, the theory screens will ask
/// for a scale, and a test asks for neither - it stands a recorder in here and reads
/// back what it was told to play, which is the only part worth asserting on.
abstract interface class TonePlayer {
  /// A chord, struck once as a strum.
  Future<void> playChord(List<int> midiNotes);

  /// Notes one after another, each on its own.
  Future<void> playNotes(List<int> midiNotes);

  /// Chords one after another, in time.
  Future<void> playSequence(List<List<int>> chords);

  Future<void> stop();

  Future<void> dispose();
}
