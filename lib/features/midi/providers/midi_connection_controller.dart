import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_connection_failure.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../core/midi/midi_engine.dart';
import '../data/midi_connection_snapshot.dart';
import 'midi_engine_providers.dart';

/// Connection state for one device profile at a time.
///
/// Kept for the app's lifetime rather than disposed when the connection
/// screen closes: the device stays connected while the user moves on to
/// patch control or Live Control, so leaving this screen must not tear the
/// link down.
final StateNotifierProviderFamily<
  MidiConnectionController,
  MidiConnectionSnapshot,
  String
>
midiConnectionProvider =
    StateNotifierProvider.family<MidiConnectionController, MidiConnectionSnapshot, String>(
      (ref, profileId) {
        final profile = MidiDeviceRegistry.findById(profileId);
        if (profile == null) {
          throw ArgumentError('Unknown MIDI device profile "$profileId".');
        }
        return MidiConnectionController(profile, ref.watch(midiEngineProvider));
      },
    );

/// What the connection screen does, without any of it holding the logic.
class MidiConnectionController extends StateNotifier<MidiConnectionSnapshot> {
  MidiConnectionController(MidiDeviceProfile profile, this._engine, {Duration? scanTimeout})
    : _scanTimeout = scanTimeout ?? _defaultScanTimeout,
      super(MidiConnectionSnapshot.initial(profile)) {
    _engine.attach(
      profile: profile,
      transportBuilder: () => transportFor(profile.connectionTypes.first),
    );
    _stateSubscription = _engine.connectionState.listen(_onConnectionStateChanged);
    // A USB device plugged or unplugged after this screen opened is picked up
    // without the user having to press anything, though [connect] also
    // rescans immediately before it tries, in case this event is slow to
    // arrive or does not fire at all on a given platform.
    _availabilitySubscription = _engine.availabilityChanged.listen((_) => scan());
    unawaited(scan());
  }

  final MidiEngine _engine;
  final Duration _scanTimeout;
  StreamSubscription<MidiConnectionState>? _stateSubscription;
  StreamSubscription<void>? _availabilitySubscription;

  /// Looks for the device again. Called on start, and again before [connect]
  /// so a device plugged in after this screen opened is still found.
  Future<void> scan() => _busyWhile(_scan);

  Future<void> connect() => _busyWhile(() async {
    await _scan();
    final endpoint = state.endpoints.firstOrNull;
    if (endpoint == null) {
      state = state.copyWith(errorMessage: _noDeviceMessage);
      return;
    }

    try {
      await _engine.connect(endpoint);
    } on MidiDeviceUnavailable {
      state = state.copyWith(errorMessage: _noDeviceMessage);
    } on MidiConnectionTimedOut {
      state = state.copyWith(errorMessage: _connectTimeoutMessage);
    } on MidiConnectionFailure {
      state = state.copyWith(errorMessage: _connectFailureMessage);
    }
  });

  Future<void> _scan() async {
    try {
      // Bounded rather than a bare `await`: on Android, a USB MIDI query
      // that never gets a permission response from the OS hangs forever
      // instead of throwing, which would otherwise leave [isBusy] spinning
      // with no way for the user to know anything went wrong.
      final endpoints = await _engine.scan().timeout(_scanTimeout);
      state = state.copyWith(endpoints: endpoints, clearError: true);
    } on TimeoutException {
      state = state.copyWith(errorMessage: _scanTimeoutMessage);
    } catch (_) {
      state = state.copyWith(errorMessage: _scanFailureMessage);
    }
  }

  /// Marks [MidiConnectionSnapshot.isBusy] for the duration of [action], so a
  /// progress indicator can tell the user something is happening rather than
  /// the screen looking stuck.
  Future<void> _busyWhile(Future<void> Function() action) async {
    state = state.copyWith(isBusy: true);
    try {
      await action();
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<void> disconnect() async {
    try {
      await _engine.disconnect();
    } catch (_) {
      state = state.copyWith(errorMessage: _disconnectFailureMessage);
    }
  }

  void _onConnectionStateChanged(MidiConnectionState connectionState) {
    state = state.copyWith(
      state: connectionState,
      clearError: connectionState != MidiConnectionState.error,
    );
  }

  static const _defaultScanTimeout = Duration(seconds: 8);
  static const _noDeviceMessage = 'No MIDI device detected.';
  static const _scanFailureMessage = 'Could not look for MIDI devices.';
  static const _scanTimeoutMessage =
      'Timed out looking for MIDI devices. If your phone showed a USB '
      'permission prompt, allow it and try again.';
  static const _connectTimeoutMessage = 'Timed out while connecting to the MIDI device.';
  static const _connectFailureMessage = 'Could not connect to the MIDI device.';
  static const _disconnectFailureMessage = 'Could not disconnect from the MIDI device.';

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _availabilitySubscription?.cancel();
    super.dispose();
  }
}
