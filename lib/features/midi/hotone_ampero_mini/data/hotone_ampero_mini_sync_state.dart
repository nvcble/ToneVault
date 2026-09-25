/// Where one patch row stands relative to the physical device - kept
/// separate from device connection state and from pre-selected/active patch
/// number, per the MIDI module's state-separation requirement.
enum HotoneAmperoMiniSyncState {
  /// Never synchronized - a slot number this app knows exists (0-127) but has
  /// no data for.
  notSynced,

  /// Read from the device and not edited locally since.
  synced,

  /// Edited locally after a sync; not yet sent back to the device.
  modifiedLocally,

  /// A write to the device is in flight.
  writePending,

  /// The last write attempt did not complete successfully.
  writeFailed,

  /// Sent to the device and confirmed by reading it back.
  verified;

  String get storageName => name;

  static HotoneAmperoMiniSyncState fromStorageName(String value) =>
      HotoneAmperoMiniSyncState.values.firstWhere(
        (state) => state.name == value,
        orElse: () => HotoneAmperoMiniSyncState.notSynced,
      );
}
