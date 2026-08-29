import 'package:drift/drift.dart';

import '../../enums/lesson_kind.dart';
import '../../enums/music_genre.dart';
import '../../enums/time_signature.dart';
import 'academy_modules_table.dart';

/// One lesson: what it says, and what the player needs to hand while reading it.
///
/// [suggestedBpm] and [timeSignature] are what the lesson opens the metronome at,
/// so a practice routine that says "start slow" starts slow without the player
/// having to guess what the author meant.
///
/// [theoryKeys] is an encoded list rather than a table of its own, in the way
/// `pedal_controls.options` is. The things it points at - a chord, a scale, a
/// progression - are worked out by the theory engine and have no rows to reference:
/// there is no `chords` table, because there is no end to the chords a lesson might
/// want to show. A key such as `chord:Cmaj7` is what the engine is asked to resolve.
@DataClassName('AcademyLesson')
@TableIndex(name: 'idx_academy_lessons_module', columns: {#moduleId, #position})
class AcademyLessons extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get moduleId =>
      integer().references(AcademyModules, #id, onDelete: KeyAction.cascade)();

  TextColumn get slug => text().withLength(min: 1, max: 80)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get kind => textEnum<LessonKind>()();

  /// The style the lesson is about, where it is about one. Most are not: a lesson
  /// on barre chords belongs to every genre that uses them.
  TextColumn get genre => textEnum<MusicGenre>().nullable()();

  /// Markdown, as the author wrote it. Long: a lesson is the one place in this
  /// app where a wall of text is the point.
  TextColumn get body => text()();

  /// What the player will be able to do at the end of it, in a sentence.
  ///
  /// Nullable, because a lesson written before the app asked for one is still a
  /// lesson. Shown above the text where it is there, so a player knows what they
  /// are reading for before they read it.
  TextColumn get objective => text().withLength(max: 240).nullable()();

  /// What players get wrong at this, and what to do instead: two encoded lists in
  /// the way [theoryKeys] is one. Both are read only under the lesson they belong
  /// to, so neither is worth a table.
  TextColumn get commonMistakes => text().nullable()();

  TextColumn get practiceTips => text().nullable()();

  /// What this leads to, named rather than linked.
  ///
  /// A slug would break the moment a course was re-ordered or re-imported, and what
  /// a player needs is the name of the thing to learn next - which is findable by
  /// searching for it, and still true if the curriculum moves it.
  TextColumn get nextSkill => text().withLength(max: 160).nullable()();

  IntColumn get estimatedMinutes => integer().nullable()();

  IntColumn get suggestedBpm => integer().nullable()();

  TextColumn get timeSignature => textEnum<TimeSignature>().nullable()();

  TextColumn get theoryKeys => text().nullable()();

  IntColumn get position => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {moduleId, slug},
  ];
}
