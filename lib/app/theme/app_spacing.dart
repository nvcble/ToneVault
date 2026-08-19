/// Spacing scale, so padding is chosen from a fixed set instead of ad-hoc
/// numbers scattered through widgets.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Minimum height for anything tappable. The app is used one-handed, often
  /// while holding a guitar, so rows and buttons never go below this.
  static const double minTouchTarget = 48;
}
