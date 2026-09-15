/// Why a [MidiTransport.connect] attempt failed, translated from whatever the
/// underlying transport or plugin threw so nothing above `transports/` needs
/// to know what plugin is behind it.
sealed class MidiConnectionFailure implements Exception {
  const MidiConnectionFailure();
}

/// The device stopped being visible between [MidiTransport.scan] and
/// [MidiTransport.connect] - unplugged, or the OS dropped it.
class MidiDeviceUnavailable extends MidiConnectionFailure {
  const MidiDeviceUnavailable();
}

/// The connection did not become usable within the transport's own timeout.
class MidiConnectionTimedOut extends MidiConnectionFailure {
  const MidiConnectionTimedOut();
}

/// The device or the platform refused the connection for any other reason -
/// a permission the user declined, a service the device did not expose, or
/// anything else the transport cannot narrow down further.
class MidiConnectionRefused extends MidiConnectionFailure {
  const MidiConnectionRefused();
}
