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

  static const String rigNewSegment = 'new';
  static const String rigDetailSegment = ':rigId';
  static const String rigEditSegment = 'edit';
  static const String snapshotNewSegment = 'snapshots/new';
  static const String snapshotDetailSegment = 'snapshots/:snapshotId';
  static const String snapshotEditSegment = 'edit';
}
