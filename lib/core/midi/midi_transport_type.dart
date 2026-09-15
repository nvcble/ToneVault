/// The physical link a [MidiTransport] speaks over.
enum MidiTransportType {
  usb,
  bluetooth;

  String get label => switch (this) {
    MidiTransportType.usb => 'USB MIDI',
    MidiTransportType.bluetooth => 'Bluetooth MIDI',
  };
}
