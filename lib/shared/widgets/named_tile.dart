import 'package:flutter/material.dart';

/// One named thing in a list: what it is called, a line about it, and a way in.
///
/// Kept for tracking: `ConfigurationTile` is this row with a `Configuration`
/// hard-wired into it. It is left as it is rather than changed under working,
/// tested code; anything new uses this instead of adding another copy.
class NamedTile extends StatelessWidget {
  const NamedTile({
    required this.name,
    required this.subtitle,
    required this.onTap,
    this.onEdit,
    this.editTooltip = 'Rename',
    this.onCopy,
    this.copyTooltip = 'Duplicate',
    this.onRemove,
    this.removeTooltip = 'Remove',
    super.key,
  });

  final String name;

  /// The user's own words where there are any, and something factual where
  /// there are not, so a row always says more than its name.
  final String subtitle;
  final VoidCallback onTap;

  final VoidCallback? onEdit;
  final String editTooltip;

  /// Offered where another one like this is a real action, such as a scene built
  /// from the one beside it.
  final VoidCallback? onCopy;
  final String copyTooltip;

  /// Offered only where taking the thing out of this list is a real action.
  final VoidCallback? onRemove;
  final String removeTooltip;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: _trailing(),
      onTap: onTap,
    );
  }

  Widget? _trailing() {
    final buttons = [
      if (onEdit != null)
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: editTooltip,
          onPressed: onEdit,
        ),
      if (onCopy != null)
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          tooltip: copyTooltip,
          onPressed: onCopy,
        ),
      if (onRemove != null)
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: removeTooltip,
          onPressed: onRemove,
        ),
    ];

    if (buttons.isEmpty) {
      return null;
    }
    // A Row of one is still a Row, but sizing it down is what keeps a single
    // button from being stretched across the tile's trailing slot.
    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}
