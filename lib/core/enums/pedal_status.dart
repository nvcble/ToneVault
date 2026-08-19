/// Lifecycle of an owned pedal.
///
/// A pedal is never deleted once it has history attached to it. Retiring or
/// replacing a pedal only changes this status, so past configurations and
/// change logs stay readable.
enum PedalStatus {
  active,
  backup,
  storage,
  replaced,
  sold;

  String get label => switch (this) {
    PedalStatus.active => 'Active',
    PedalStatus.backup => 'Backup',
    PedalStatus.storage => 'In storage',
    PedalStatus.replaced => 'Replaced',
    PedalStatus.sold => 'Sold',
  };

  /// Whether the pedal is still part of the current rig, as opposed to being
  /// kept only for its history.
  bool get isOwned => this != PedalStatus.sold;
}
