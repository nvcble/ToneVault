import 'package:flutter/material.dart';

/// What can be done to a rig as a whole.
///
/// The chain has the screen to itself, so these live behind one button rather
/// than as a row of icons competing with the tabs for the title bar.
///
/// Nothing is written here. The chosen action goes back to the caller, which is
/// what keeps this widget testable and the writes in one place.
enum RigOption { edit, clearChain, saveSnapshot, delete }

class RigOptionsMenu extends StatelessWidget {
  const RigOptionsMenu({
    required this.blockCount,
    required this.onSelected,
    super.key,
  });

  /// How many blocks are on the rig. Nothing to clear when there are none, so
  /// the action is offered greyed rather than quietly doing nothing.
  final int blockCount;

  final ValueChanged<RigOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RigOption>(
      tooltip: 'Rig options',
      onSelected: onSelected,
      itemBuilder: (menuContext) => [
        _item(RigOption.edit, Icons.edit_outlined, 'Edit rig'),
        _item(
          RigOption.clearChain,
          Icons.layers_clear_outlined,
          'Clear chain',
          enabled: blockCount > 0,
        ),
        _item(
          RigOption.saveSnapshot,
          Icons.camera_alt_outlined,
          'Save snapshot',
        ),
        _item(RigOption.delete, Icons.delete_outline, 'Delete rig'),
      ],
    );
  }

  PopupMenuItem<RigOption> _item(
    RigOption value,
    IconData icon,
    String label, {
    bool enabled = true,
  }) {
    return PopupMenuItem<RigOption>(
      value: value,
      enabled: enabled,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label),
        // Greys the icon as well as the label, which the menu alone would not.
        enabled: enabled,
      ),
    );
  }
}
