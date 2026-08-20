/// Every route path in the app.
///
/// Screens navigate with these constants rather than string literals, so a
/// renamed path is a compile error instead of a runtime dead end.
abstract final class Routes {
  static const String dashboard = '/';
  static const String pedals = '/pedals';
  static const String rigs = '/rigs';
  static const String history = '/history';
  static const String settings = '/settings';

  static const String pedalNew = '$pedals/new';

  static String pedalDetail(int pedalId) => '$pedals/$pedalId';

  static String pedalEdit(int pedalId) => '${pedalDetail(pedalId)}/edit';

  /// A stomp or block is added through the multi-effects unit that will hold it,
  /// which is where its host comes from. It is an ordinary pedal once saved, so
  /// it is read and edited through [pedalDetail] like any other.
  static String componentNew(int hostPedalId) =>
      '${pedalDetail(hostPedalId)}/components/new';

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

  static const String rigNew = '$rigs/new';

  static String rigDetail(int pedalboardId) => '$rigs/$pedalboardId';

  static String rigEdit(int pedalboardId) => '${rigDetail(pedalboardId)}/edit';

  /// A snapshot is of one rig, so it is reached through it.
  static String snapshotNew(int pedalboardId) =>
      '${rigDetail(pedalboardId)}/snapshots/new';

  static String snapshotDetail(int pedalboardId, int snapshotId) =>
      '${rigDetail(pedalboardId)}/snapshots/$snapshotId';

  static String snapshotEdit(int pedalboardId, int snapshotId) =>
      '${snapshotDetail(pedalboardId, snapshotId)}/edit';

  /// Nested routes are declared relative to their parent, so the paths handed
  /// to `GoRoute` are not the same strings used to navigate.
  static const String pedalNewSegment = 'new';
  static const String pedalDetailSegment = ':pedalId';
  static const String pedalEditSegment = 'edit';
  static const String componentNewSegment = 'components/new';
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

  static const String rigNewSegment = 'new';
  static const String rigDetailSegment = ':rigId';
  static const String rigEditSegment = 'edit';
  static const String snapshotNewSegment = 'snapshots/new';
  static const String snapshotDetailSegment = 'snapshots/:snapshotId';
  static const String snapshotEditSegment = 'edit';
}
