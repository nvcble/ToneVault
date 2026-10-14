import 'package:flutter/material.dart';

import '../../../core/midi/midi_parameter_names.dart';
import 'midi_trigger_controls.dart';

/// The unit's two assignable footswitches, A and B.
///
/// Latching rather than momentary: on the MG-30 each switch turns whatever the
/// loaded patch assigned it to on and off, so the button shows which way it is
/// set and sends [ccOn] one way, [ccOff] the other. What it actually does is
/// the patch's business, not this widget's - the same button is a boost on one
/// patch and a delay on the next.
class MidiFootswitchButtons extends StatelessWidget {
  const MidiFootswitchButtons({
    required this.onToggle,
    this.on = const {},
    super.key,
  });

  /// The switches currently latched on, by parameter name - what this app last
  /// sent, never a reading from the device.
  final Set<String> on;

  /// Null disables both - see `MidiSceneButtons.onSelect`.
  final void Function(String parameterName, bool on)? onToggle;

  @override
  Widget build(BuildContext context) {
    return MidiTriggerRow(
      children: [
        for (final name in MidiParameterNames.switches)
          MidiTriggerButton(
            label: name,
            selected: on.contains(name),
            onPressed: onToggle == null
                ? null
                : () => onToggle!(name, !on.contains(name)),
          ),
      ],
    );
  }
}
