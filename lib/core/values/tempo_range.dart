/// The tempos the app will count.
///
/// Thirty at the bottom because slower than that is not a pulse anybody can play
/// to - the gaps are long enough that a player is guessing rather than following.
/// Three hundred at the top because it is faster than any tempo a piece is
/// actually written at, and past it a click stops being separable by ear.
///
/// One pair of numbers, used by the metronome, by the exercises that suggest a
/// tempo, and by the importer that refuses a file claiming one outside it - so a
/// lesson cannot ship a tempo the metronome would not play.
const int minBpm = 30;
const int maxBpm = 300;

bool isPlayableBpm(int bpm) => bpm >= minBpm && bpm <= maxBpm;

/// Brings a tempo inside the range, for a dial the user is dragging rather than a
/// file being validated. A file is refused; a finger is simply stopped.
int clampBpm(int bpm) => bpm.clamp(minBpm, maxBpm);
