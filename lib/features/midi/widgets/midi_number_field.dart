import 'package:flutter/material.dart';

/// A small integer assigned to something - a patch's program number, a
/// scene's Pro Scene slot - editable in place.
class MidiNumberField extends StatefulWidget {
  const MidiNumberField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int? value;
  final void Function(int value) onChanged;

  @override
  State<MidiNumberField> createState() => _MidiNumberFieldState();
}

class _MidiNumberFieldState extends State<MidiNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(MidiNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: '—'),
        onSubmitted: (text) {
          final number = int.tryParse(text);
          if (number != null) {
            widget.onChanged(number);
          }
        },
      ),
    );
  }
}
