import '../../../core/audio/tone_player.dart';
import '../../../core/music/chord.dart';

/// One question of an ear training drill: what is played, what may be answered, and
/// what the answer was once it has been given.
///
/// Made rather than stored. There is no table of questions and no editor to write one
/// in - a drill is a rule for making a question, and the theory engine works out the
/// notes - so the app has an endless supply of them the moment it is installed, which
/// is what the Academy promises.
class EarQuestion {
  const EarQuestion({
    required this.prompt,
    required this.choices,
    required this.answer,
    required this.explanation,
    required this.sound,
  });

  /// What is being asked: "What chord did you hear?".
  final String prompt;

  /// What may be answered, in the order they are shown. Shuffled when the question
  /// was made, so the right answer is not in the same place twice.
  final List<String> choices;

  /// Which of [choices] is right.
  final int answer;

  /// Why, in the terms the lesson would use: the chord said in words and its notes.
  /// Shown after an answer, right or wrong - a drill that only says "no" teaches
  /// nothing.
  final String explanation;

  final EarSound sound;

  String get answerLabel => choices[answer];

  bool isCorrect(int choice) => choice == answer;
}

/// Whether the question is heard as a chord, as notes in turn, or as bars of music.
enum EarSoundKind { chord, notes, sequence }

/// The sound of a question, as the notes to play.
///
/// MIDI numbers, because that is what a player takes: which instrument sounds them
/// and how is the audio layer's business, and a test can read this and assert on the
/// notes without a sound device in the room.
class EarSound {
  const EarSound(this.kind, this.bars);

  factory EarSound.chord(List<int> midiNotes) =>
      EarSound(EarSoundKind.chord, [midiNotes]);

  factory EarSound.notes(List<int> midiNotes) =>
      EarSound(EarSoundKind.notes, [midiNotes]);

  factory EarSound.sequence(List<List<int>> bars) =>
      EarSound(EarSoundKind.sequence, bars);

  final EarSoundKind kind;

  /// One entry a chord, in the order they are played.
  final List<List<int>> bars;

  Future<void> playOn(TonePlayer player) => switch (kind) {
    EarSoundKind.chord => player.playChord(bars.first),
    EarSoundKind.notes => player.playNotes(bars.first),
    EarSoundKind.sequence => player.playSequence(bars),
  };
}

/// A chord said in words and spelled out, which is what an answer has to show for the
/// drill to be teaching rather than testing.
String explainChord(Chord chord) {
  final flats = chord.prefersFlats;
  final notes = [for (final note in chord.notes) note.name(flats: flats)];
  return '${chord.root.name(flats: flats)} ${chord.type.label}\n'
      '${notes.join(' - ')}';
}
