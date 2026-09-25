import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_parameter_definition.dart';

/// One parameter's value, changed locally and sent only when asked - see
/// section 11 of the MIDI module brief on preferring explicit sends.
class MidiParameterTile extends StatefulWidget {
  const MidiParameterTile({
    required this.definition,
    required this.onSend,
    super.key,
  });

  final MidiParameterDefinition definition;
  final void Function(int value) onSend;

  @override
  State<MidiParameterTile> createState() => _MidiParameterTileState();
}

class _MidiParameterTileState extends State<MidiParameterTile> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.definition.defaultValue ?? widget.definition.min;
  }

  @override
  Widget build(BuildContext context) {
    final definition = widget.definition;
    final divisions = (definition.max - definition.min).round();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(definition.name),
                Text(
                  'CC ${definition.ccNumber} · ${_value.round()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Slider(
              value: _value.clamp(definition.min, definition.max),
              min: definition.min,
              max: definition.max,
              divisions: divisions > 0 ? divisions : null,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Send',
            onPressed: () => widget.onSend(_value.round()),
          ),
        ],
      ),
    );
  }
}
