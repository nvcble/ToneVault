import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// One slot in [PatchNumberCarousel]'s grid: the Program Change number and
/// whatever patch, if any, has been given it.
///
/// A single tap only pre-selects a tile - its border highlights, as
/// [selected], but nothing is sent. A double tap is what actually loads it,
/// which is when [loaded] fills its background.
class PatchGridTile extends StatelessWidget {
  const PatchGridTile({
    required this.number,
    required this.label,
    required this.selected,
    required this.loaded,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  /// 1-based, matching the numbering printed on the device itself.
  final int number;
  final String label;
  final bool selected;
  final bool loaded;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = loaded ? colors.onPrimary : null;
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: loaded ? colors.primary : null,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
            ),
            // One line: twelve slots to a page leaves a tile short enough that
            // a second line of name would not fit under the number on a small
            // phone. The full name of the selected slot is spelled out under
            // the grid - see `PatchNumberCarousel`.
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: foreground),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
