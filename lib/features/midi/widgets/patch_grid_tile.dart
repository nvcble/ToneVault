import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// One slot in [PatchNumberCarousel]'s grid: the Program Change number and
/// whatever patch, if any, has been given it.
///
/// A single tap only pre-selects a tile - it shows as [selected] but sends
/// nothing. A double tap is what actually loads it.
class PatchGridTile extends StatelessWidget {
  const PatchGridTile({
    required this.number,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  /// 1-based, matching the numbering printed on the device itself.
  final int number;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
