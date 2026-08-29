import '../../../core/enums/learning_path.dart';
import '../../../core/enums/lesson_kind.dart';
import '../../../core/enums/music_genre.dart';
import '../../../core/enums/skill_level.dart';
import '../../../core/enums/time_signature.dart';

/// A curriculum as it is written down, before it is anything in the database.
///
/// Nested rather than flat, and with no ids and no positions on it. A course holds
/// its modules, a module its lessons, a lesson its exercises - so the file cannot
/// name a parent that is not in it, and the order they are written in is the order
/// they are taught in. That removes two whole classes of invalid file rather than
/// leaving them to be validated for.
///
/// This is the shape both the curriculum the app ships and a file the user imports
/// arrive as. There is deliberately no way to build one except by decoding a
/// document: the app has no course editor and is not getting one.
class CourseSpec {
  const CourseSpec({
    required this.slug,
    required this.path,
    required this.level,
    required this.title,
    required this.summary,
    required this.modules,
  });

  final String slug;
  final LearningPath path;
  final SkillLevel level;
  final String title;
  final String summary;
  final List<ModuleSpec> modules;
}

class ModuleSpec {
  const ModuleSpec({
    required this.slug,
    required this.title,
    required this.lessons,
    this.summary,
  });

  final String slug;
  final String title;
  final String? summary;
  final List<LessonSpec> lessons;
}

class LessonSpec {
  const LessonSpec({
    required this.slug,
    required this.title,
    required this.kind,
    required this.body,
    this.objective,
    this.commonMistakes = const [],
    this.practiceTips = const [],
    this.nextSkill,
    this.genre,
    this.estimatedMinutes,
    this.suggestedBpm,
    this.timeSignature,
    this.theoryKeys = const [],
    this.exercises = const [],
  });

  final String slug;
  final String title;
  final LessonKind kind;

  /// Markdown, as written. Rendering it is the screen's business.
  final String body;

  /// What the player will be able to do at the end of it, in a sentence. Read
  /// before the body, which is why it is stored apart from it.
  final String? objective;

  /// What players get wrong at this, and what to do about it. Optional, because a
  /// lesson that is a piece of reading has neither.
  final List<String> commonMistakes;
  final List<String> practiceTips;

  /// What this leads to, named rather than linked - see the table for why.
  final String? nextSkill;

  /// The style this lesson is about, where it is about one. Most are not: a lesson
  /// on barre chords belongs to no genre, and saying it was blues would be wrong.
  final MusicGenre? genre;
  final int? estimatedMinutes;
  final int? suggestedBpm;
  final TimeSignature? timeSignature;

  /// Chords, scales and progressions the theory engine can resolve, so a lesson
  /// shows a real fretboard without the diagram being drawn into its text.
  final List<String> theoryKeys;
  final List<ExerciseSpec> exercises;
}

class ExerciseSpec {
  const ExerciseSpec({
    required this.title,
    required this.instructions,
    required this.startBpm,
    required this.targetBpm,
    required this.timeSignature,
  });

  final String title;
  final String instructions;

  /// Where to set the metronome, and what to work up to. Both are stored, because
  /// an exercise is practised over weeks and the point is the distance between
  /// them.
  final int startBpm;
  final int targetBpm;
  final TimeSignature timeSignature;
}
