import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_parameter_definition.dart';

/// One parameter's CC assignment, editable the way NUX's own QuickTone app
/// lets a user remap it on the MG-30 itself.
class MidiMappingTile extends StatefulWidget {
  const MidiMappingTile({
    required this.definition,
    required this.isOverridden,
    required this.onChanged,
    required this.onReset,
    super.key,
  });

  final MidiParameterDefinition definition;
  final bool isOverridden;
  final void Function(int ccNumber) onChanged;
  final VoidCallback onReset;

  @override
  State<MidiMappingTile> createState() => _MidiMappingTileState();
}

class _MidiMappingTileState extends State<MidiMappingTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.definition.ccNumber?.toString() ?? '');
  }

  @override
  void didUpdateWidget(MidiMappingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.ccNumber != widget.definition.ccNumber) {
      _controller.text = widget.definition.ccNumber?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.definition.name),
      // A parameter the device profile ships no CC for reads as unassigned
      // rather than as "Default": its default is nothing, and the control that
      // uses it stays silent until this field is filled in. It also says that
      // the device confirms no CC for it, because filling the field in is not
      // the same as the unit listening - the MG-30's Tap Tempo has no CC in
      // either of its confirmed sources, so a number put here goes to
      // whatever that CC really means on the unit.
      subtitle: Text(
        widget.isOverridden
            ? 'Customized'
            : widget.definition.ccNumber == null
            ? 'Not assigned. This device confirms no CC for it.'
            : 'Default',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CC'),
              onSubmitted: (text) {
                final cc = int.tryParse(text);
                if (cc != null) {
                  widget.onChanged(cc);
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to default',
            onPressed: widget.isOverridden ? widget.onReset : null,
          ),
        ],
      ),
    );
  }
}
