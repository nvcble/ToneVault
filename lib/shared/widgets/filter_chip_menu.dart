import 'package:flutter/material.dart';

/// A chip that opens a short menu of choices, one of which is "any".
///
/// A dropdown would take a whole row for a value that is usually unset; a chip
/// says what it is filtering by and gets out of the way when it is not.
class FilterChipMenu<T> extends StatelessWidget {
  const FilterChipMenu({
    required this.emptyLabel,
    required this.clearLabel,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onSelected,
    super.key,
  });

  /// Shown on the chip while nothing is chosen.
  final String emptyLabel;

  /// The menu entry that puts the filter back to "any".
  final String clearLabel;

  final T? value;
  final List<T> options;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chosen = value;

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => onSelected(null),
          child: Text(clearLabel),
        ),
        for (final option in options)
          MenuItemButton(
            onPressed: () => onSelected(option),
            child: Text(labelOf(option)),
          ),
      ],
      builder: (context, controller, _) => FilterChip(
        label: Text(chosen == null ? emptyLabel : labelOf(chosen)),
        selected: chosen != null,
        // No check mark: the label already names the choice, and the tick only
        // pushes the text along.
        showCheckmark: false,
        avatar: chosen == null ? const Icon(Icons.arrow_drop_down) : null,
        onSelected: (_) =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
