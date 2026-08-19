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

  /// Controls belong to one pedal, so they are reached through it.
  static String controlNew(int pedalId) =>
      '${pedalDetail(pedalId)}/controls/new';

  static String controlEdit(int pedalId, int controlId) =>
      '${pedalDetail(pedalId)}/controls/$controlId/edit';

  /// Nested routes are declared relative to their parent, so the paths handed
  /// to `GoRoute` are not the same strings used to navigate.
  static const String pedalNewSegment = 'new';
  static const String pedalDetailSegment = ':pedalId';
  static const String pedalEditSegment = 'edit';
  static const String controlNewSegment = 'controls/new';
  static const String controlEditSegment = 'controls/:controlId/edit';
}
