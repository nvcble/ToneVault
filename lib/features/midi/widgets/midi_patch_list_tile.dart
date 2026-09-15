import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'midi_number_field.dart';

/// One row of the Patches list: the patch, the program number it loads as, and
/// a way to send it.
class MidiPatchListTile extends StatelessWidget {
  const MidiPatchListTile({
    required this.name,
    required this.programNumber,
    required this.onNumberChanged,
    required this.onTap,
    this.onLoad,
    super.key,
  });

  final String name;

  /// Null until the user has said which of the device's slots this patch is.
  final int? programNumber;
  final void Function(int number) onNumberChanged;
  final VoidCallback onTap;

  /// Null when this patch cannot be loaded right now - nothing connected,
  /// experimental sending off, or no program number assigned yet.
  final VoidCallback? onLoad;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MidiNumberField(value: programNumber, onChanged: onNumberChanged),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Load this patch',
            onPressed: onLoad,
          ),
        ],
      ),
    );
  }
}
