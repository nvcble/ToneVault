import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_connection_failure.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_connection_controller.dart';

import '../support/fake_midi_transport.dart';

const _profile = NuxMg30V5Profile();
const _endpoint = MidiEndpoint(
  id: 'dev-1',
  name: 'MG-30',
  type: MidiTransportType.usb,
);

/// Builds a controller whose engine already has [transport] attached, so the
/// controller's own attach call is the no-op branch and never reaches
/// `transportFor` - which would otherwise build a real `UsbMidiTransport`.
MidiConnectionController _controllerWith(
  FakeMidiTransport transport, {
  Duration? scanTimeout,
}) {
  final engine = MidiEngine();
  engine.attach(profile: _profile, transportBuilder: () => transport);
  return MidiConnectionController(_profile, engine, scanTimeout: scanTimeout);
}

void main() {
  test(
    'starts disconnected and finds a plugged-in device on creation',
    () async {
      final controller = _controllerWith(
        FakeMidiTransport(endpoints: const [_endpoint]),
      );
      addTearDown(controller.dispose);

      expect(controller.state.state, MidiConnectionState.disconnected);
      await pumpEventQueue();

      expect(controller.state.hasDetectedDevice, isTrue);
    },
  );

  test('reports no device detected when nothing is plugged in', () async {
    final controller = _controllerWith(FakeMidiTransport());
    addTearDown(controller.dispose);
    await pumpEventQueue();

    await controller.connect();

    expect(controller.state.state, MidiConnectionState.disconnected);
    expect(controller.state.errorMessage, 'No MIDI device detected.');
  });

  test('connects once a device is found', () async {
    final controller = _controllerWith(
      FakeMidiTransport(endpoints: const [_endpoint]),
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();

    await controller.connect();
    await pumpEventQueue();

    expect(controller.state.state, MidiConnectionState.connected);
    expect(controller.state.errorMessage, isNull);
  });

  test('surfaces a connect failure instead of claiming success', () async {
    final controller = _controllerWith(
      FakeMidiTransport(
        endpoints: const [_endpoint],
        connectFailure: const MidiConnectionRefused(),
      ),
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();

    await controller.connect();
    await pumpEventQueue();

    expect(controller.state.state, MidiConnectionState.error);
    expect(
      controller.state.errorMessage,
      'Could not connect to the MIDI device.',
    );
  });

  test('names a timeout distinctly from a plain connect failure', () async {
    final controller = _controllerWith(
      FakeMidiTransport(
        endpoints: const [_endpoint],
        connectFailure: const MidiConnectionTimedOut(),
      ),
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();

    await controller.connect();
    await pumpEventQueue();

    expect(
      controller.state.errorMessage,
      'Timed out while connecting to the MIDI device.',
    );
  });

  test(
    'treats a device that vanished between scan and connect as none detected',
    () async {
      final controller = _controllerWith(
        FakeMidiTransport(
          endpoints: const [_endpoint],
          connectFailure: const MidiDeviceUnavailable(),
        ),
      );
      addTearDown(controller.dispose);
      await pumpEventQueue();

      await controller.connect();
      await pumpEventQueue();

      expect(controller.state.errorMessage, 'No MIDI device detected.');
    },
  );

  test(
    'rescans when the transport reports a device may have appeared',
    () async {
      final transport = FakeMidiTransport();
      final controller = _controllerWith(transport);
      addTearDown(controller.dispose);
      await pumpEventQueue();
      expect(controller.state.hasDetectedDevice, isFalse);

      // A device plugged in after the screen opened, without the user pressing
      // anything to ask for a rescan.
      transport.endpoints.add(_endpoint);
      transport.triggerAvailabilityChange();
      await pumpEventQueue();

      expect(controller.state.hasDetectedDevice, isTrue);
    },
  );

  test('isBusy is set while connecting and cleared once it settles', () async {
    final controller = _controllerWith(
      FakeMidiTransport(endpoints: const [_endpoint]),
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();

    final connecting = controller.connect();
    expect(controller.state.isBusy, isTrue);
    await connecting;

    expect(controller.state.isBusy, isFalse);
  });

  test(
    'a scan that never resolves surfaces as a timeout, not a stuck spinner',
    () async {
      final controller = _controllerWith(
        FakeMidiTransport(scanDelay: const Duration(seconds: 30)),
        scanTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      // A real Timer backs `.timeout()`, so waiting for actual wall-clock time
      // to pass - not just draining the microtask queue - is what proves the
      // timeout fires rather than the scan silently hanging forever.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.state.isBusy, isFalse);
      expect(
        controller.state.errorMessage,
        contains('Timed out looking for MIDI devices'),
      );
    },
  );

  test('disconnect returns to the disconnected state', () async {
    final controller = _controllerWith(
      FakeMidiTransport(endpoints: const [_endpoint]),
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();
    await controller.connect();
    await pumpEventQueue();

    await controller.disconnect();
    await pumpEventQueue();

    expect(controller.state.state, MidiConnectionState.disconnected);
  });
}
