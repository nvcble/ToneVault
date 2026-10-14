import 'package:flutter/material.dart';

import '../data/tap_tempo.dart';
import 'midi_trigger_controls.dart';

/// Tap tempo for the connected unit.
///
/// Every tap goes straight out as its own message, which is what the device
/// counts the gaps between - the app does not work out a tempo and then send
/// that, because no CC on the MG-30 carries a BPM. The reading on the button
/// is feedback for the player, not the thing being sent.
class TapTempoButton extends StatefulWidget {
  const TapTempoButton({
    required this.onTap,
    this.onBpm,
    this.now,
    super.key,
  });

  /// Null disables it - see `MidiTriggerButton.onPressed`.
  final VoidCallback? onTap;

  /// The tempo the taps so far imply, once there have been two of them.
  ///
  /// Separate from [onTap] because the two are different things: [onTap] is
  /// the tap itself, which goes out per tap, while this is a reading that
  /// only exists from the second tap onwards. Null leaves the reading on the
  /// button and nowhere else, which is what it did before anything wanted it.
  final void Function(int bpm)? onBpm;

  /// When a tap happened. Injectable only so a test can tap on a clock it
  /// controls; nothing in the app passes it.
  final DateTime Function()? now;

  @override
  State<TapTempoButton> createState() => _TapTempoButtonState();
}

class _TapTempoButtonState extends State<TapTempoButton> {
  final TapTempo _tapTempo = TapTempo();
  int? _bpm;

  @override
  Widget build(BuildContext context) {
    return MidiTriggerButton(
      label: _bpm == null ? 'Tap tempo' : 'Tap · $_bpm BPM',
      selected: _bpm != null,
      onPressed: widget.onTap == null ? null : _tap,
    );
  }

  void _tap() {
    final bpm = _tapTempo.tap((widget.now ?? DateTime.now)());
    setState(() => _bpm = bpm);
    widget.onTap!();
    if (bpm != null) {
      widget.onBpm?.call(bpm);
    }
  }
}
