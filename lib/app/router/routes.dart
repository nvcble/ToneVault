import '../../core/enums/learning_path.dart';
import '../../core/enums/skill_level.dart';
import '../../features/academy/data/ear_drill.dart';
import '../../features/theory/data/theory_tab.dart';

/// Every route path in the app.
///
/// Screens navigate with these constants rather than string literals, so a
/// renamed path is a compile error instead of a runtime dead end.
abstract final class Routes {
  static const String dashboard = '/';
  static const String pedals = '/pedals';
  static const String history = '/history';
  static const String settings = '/settings';

  /// The Academy sits outside the tab shell on purpose. It is reached from the
  /// header of whichever tab the user is on, and a branch of the shell with no
  /// destination behind it would put the navigation bar's selected index out of
  /// range of the destinations it has.
  static const String academy = '/academy';

  /// The metronome sits beside the shell too, and for a plainer reason: it is a tool
  /// rather than a place, opened from the Academy or from an exercise and left behind
  /// still counting.
  static const String metronome = '/metronome';

  /// The metronome opened from a lesson's exercise, which is the same screen with
  /// somewhere to credit the practice to.
  ///
  /// A query parameter rather than a segment: the lesson is not where the metronome
  /// lives, it is who is asking. `/metronome` on its own is still the whole route,
  /// and it still works.
  static String metronomeForLesson(int lessonId) =>
      '$metronome?$lessonQuery=$lessonId';

  /// A path is named in the URL by its enum name, so `/academy/rhythm` means the
  /// same thing on a phone, in a test and in a bug report.
  static String academyPath(LearningPath path) => '$academy/${path.name}';

  static String academyLevel(LearningPath path, SkillLevel level) =>
      '${academyPath(path)}/${level.name}';

  /// A course by its row id rather than its slug. The slug is what a curriculum
  /// file uses to say which course it means; inside the app a course is a row, and
  /// a link that survives the course being re-imported is one that names the row.
  ///
  /// [lessonId] names one lesson of it to arrive with already open. The course is
  /// still the route - a lesson is not a screen of its own - so the lesson is a
  /// query parameter and a link without one lands on the course closed.
  static String academyCourse(
    LearningPath path,
    SkillLevel level,
    int courseId, {
    int? lessonId,
  }) {
    final course = '${academyLevel(path, level)}/$courseId';
    return lessonId == null ? course : '$course?$lessonQuery=$lessonId';
  }

  /// The name of the query parameter both the course screen and the metronome use
  /// to say which lesson they were opened for.
  static const String lessonQuery = 'lesson';

  /// Ear training, which belongs to no path: a player drills their ears whether they
  /// came in through rhythm or lead.
  static const String academyEar = '$academy/ear';

  static String academyEarDrill(EarDrill drill) => '$academyEar/${drill.name}';

  /// The theory browser, which belongs to no path either: the chords of a key are the
  /// same chords whether a player is strumming them or soloing over them.
  static const String academyTheory = '$academy/theory';

  /// The browser opened on one of its tabs, for a dashboard shortcut or a search result
  /// that is about the modes or the circle rather than about the chords of a key.
  static String academyTheoryTab(TheoryTab tab) =>
      '$academyTheory?$theoryTabQuery=${tab.name}';

  /// Named in the query rather than in the path: a tab is which view of the browser is
  /// showing, and the player can change it once they are there, so it is not part of
  /// what the screen is.
  static const String theoryTabQuery = 'tab';

  /// The explainer behind the numbers the browser writes everywhere else. Under the
  /// browser rather than beside it, because that is the screen it answers a question
  /// about.
  static const String academyTheoryNashville = '$academyTheory/nashville';

  /// What the player kept, and the search that finds anything they did not. Both read the
  /// whole curriculum, so neither sits under a path or a level.
  static const String academyBookmarks = '$academy/bookmarks';
  static const String academySearch = '$academy/search';

  /// Courses and lessons as files, in and out. Not under a path either: a file holds
  /// whole courses and says for itself which path each of them belongs to.
  static const String academyCurriculum = '$academy/curriculum';

  /// The MIDI module sits outside the tab shell too, for the same reason as
  /// the Academy: reached from the header, not a destination to keep
  /// selected.
  static const String midi = '/midi';

  /// [deviceId] is a device profile id (e.g. "nux_mg30_v5"), not a database
  /// row - there is no row until the device is actually added as gear in a
  /// later phase.
  static String midiConnect(String deviceId) => '$midi/$deviceId/connect';

  static String midiControl(String deviceId) => '$midi/$deviceId/control';

  static String midiParameters(String deviceId) => '$midi/$deviceId/parameters';

  static String midiMapping(String deviceId) => '$midi/$deviceId/mapping';

  static String midiMonitor(String deviceId) => '$midi/$deviceId/monitor';

  static String midiPatches(String deviceId) => '$midi/$deviceId/patches';

  /// A patch's own scenes, reached through the device rather than through a
  /// pedal id: the MIDI module knows a patch by which device it belongs to,
  /// the same way the Pedals tab knows one by which unit it belongs to.
  static String midiPatchScenes(String deviceId, int patchId) =>
      '${midiPatches(deviceId)}/$patchId/scenes';

  static String liveControl(String deviceId) => '$midi/$deviceId/live';

  /// Direct patch selection - see `MidiPatchBrowserScreen`.
  static String midiPatchBrowser(String deviceId) => '$midi/$deviceId/browse';

  /// Read-only preset import - see `PresetImportScreen`.
  static String midiPresetImport(String deviceId) => '$midi/$deviceId/import';

  /// A scene's own signal chain, for turning blocks on and off and editing
  /// their knobs before sending. See `MidiPatchEditorScreen`.
  static String midiSceneEditor(String deviceId, int patchId, int sceneId) =>
      '${midiPatchScenes(deviceId, patchId)}/$sceneId/editor';

  static const String midiDeviceIdParam = 'deviceId';
  static const String midiPatchIdParam = 'patchId';
  static const String midiSceneIdParam = 'sceneId';
  static const String midiConnectSegment = ':$midiDeviceIdParam/connect';
  static const String midiControlSegment = ':$midiDeviceIdParam/control';
  static const String midiParametersSegment = ':$midiDeviceIdParam/parameters';
  static const String midiMappingSegment = ':$midiDeviceIdParam/mapping';
  static const String liveControlSegment = ':$midiDeviceIdParam/live';
  static const String midiPatchBrowserSegment = ':$midiDeviceIdParam/browse';
  static const String midiPresetImportSegment = ':$midiDeviceIdParam/import';
  static const String midiMonitorSegment = ':$midiDeviceIdParam/monitor';
  static const String midiPatchesSegment = ':$midiDeviceIdParam/patches';
  static const String midiPatchScenesSegment =
      ':$midiDeviceIdParam/patches/:$midiPatchIdParam/scenes';
  static const String midiSceneEditorSegment =
      ':$midiDeviceIdParam/patches/:$midiPatchIdParam/scenes/:$midiSceneIdParam/editor';

  static const String pedalNew = '$pedals/new';

  static String pedalDetail(int pedalId) => '$pedals/$pedalId';

  static String pedalEdit(int pedalId) => '${pedalDetail(pedalId)}/edit';

  /// Controls belong to one pedal, so they are reached through it.
  static String controlNew(int pedalId) =>
      '${pedalDetail(pedalId)}/controls/new';

  static String controlEdit(int pedalId, int controlId) =>
      '${pedalDetail(pedalId)}/controls/$controlId/edit';

  /// Configurations belong to one pedal too, for the same reason.
  static String configurationNew(int pedalId) =>
      '${pedalDetail(pedalId)}/configurations/new';

  static String configurationDetail(int pedalId, int configurationId) =>
      '${pedalDetail(pedalId)}/configurations/$configurationId';

  static String configurationEdit(int pedalId, int configurationId) =>
      '${configurationDetail(pedalId, configurationId)}/edit';

  /// A multi-effects unit keeps patches where an ordinary pedal keeps
  /// configurations, so they hang off the unit in the same way.
  static String patchNew(int pedalId) => '${pedalDetail(pedalId)}/patches/new';

  static String patchDetail(int pedalId, int patchId) =>
      '${pedalDetail(pedalId)}/patches/$patchId';

  static String patchEdit(int pedalId, int patchId) =>
      '${patchDetail(pedalId, patchId)}/edit';

  /// A scene is one sound within a patch, so it is reached through it. Two
  /// patches may each have a "Verse", which is why the patch stays in the path.
  static String sceneNew(int pedalId, int patchId) =>
      '${patchDetail(pedalId, patchId)}/scenes/new';

  static String sceneDetail(int pedalId, int patchId, int sceneId) =>
      '${patchDetail(pedalId, patchId)}/scenes/$sceneId';

  static String sceneEdit(int pedalId, int patchId, int sceneId) =>
      '${sceneDetail(pedalId, patchId, sceneId)}/edit';

  /// A pedal entered from inside a scene. It is filed under the unit like any
  /// other block, so it is read and edited through [pedalDetail] afterwards; the
  /// scene is in the path only because that is what the new pedal joins.
  static String scenePedalNew(int pedalId, int patchId, int sceneId) =>
      '${sceneDetail(pedalId, patchId, sceneId)}/pedals/new';

  /// Nested routes are declared relative to their parent, so the paths handed
  /// to `GoRoute` are not the same strings used to navigate.
  static const String pedalNewSegment = 'new';
  static const String pedalDetailSegment = ':pedalId';
  static const String pedalEditSegment = 'edit';
  static const String controlNewSegment = 'controls/new';
  static const String controlEditSegment = 'controls/:controlId/edit';
  static const String configurationNewSegment = 'configurations/new';
  static const String configurationDetailSegment =
      'configurations/:configurationId';
  static const String configurationEditSegment = 'edit';
  static const String patchNewSegment = 'patches/new';
  static const String patchDetailSegment = 'patches/:patchId';
  static const String patchEditSegment = 'edit';
  static const String sceneNewSegment = 'scenes/new';
  static const String sceneDetailSegment = 'scenes/:sceneId';
  static const String sceneEditSegment = 'edit';
  static const String scenePedalNewSegment = 'pedals/new';
  static const String academyPathSegment = ':path';
  static const String academyLevelSegment = ':level';
  static const String academyCourseSegment = ':courseId';

  /// Declared before [academyPathSegment], which would otherwise match `ear`,
  /// `theory`, `bookmarks`, `search` or `curriculum` as the name of a learning path.
  static const String academyEarSegment = 'ear';
  static const String academyEarDrillSegment = ':drill';
  static const String academyTheorySegment = 'theory';
  static const String academyNashvilleSegment = 'nashville';
  static const String academyBookmarksSegment = 'bookmarks';
  static const String academySearchSegment = 'search';
  static const String academyCurriculumSegment = 'curriculum';
}
