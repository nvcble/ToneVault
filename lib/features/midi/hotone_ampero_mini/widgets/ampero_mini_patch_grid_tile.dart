import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../data/ampero_mini_patch_layout.dart';

/// One patch in the Ampero Mini's grid, headed by the pedal's own label.
///
/// A single tap only pre-selects it - [preSelected] outlines it, and nothing is
/// sent. A double tap is what activates it on the device, which is when
/// [active] fills it.
///
/// Every patch is selectable over MIDI (see [amperoMiniIsSelectableOverMidi]);
/// the struck-through, greyed styling remains only for an index outside the
/// pedal's 198 patches.
///
/// [name] is only ever a name decoded from bytes the pedal sent, so it is null
/// on every patch until a patch-read command is confirmed for this model.
class AmperoMiniPatchGridTile extends StatelessWidget {
  const AmperoMiniPatchGridTile({
    required this.patchNumber,
    required this.name,
    required this.preSelected,
    required this.active,
    required this.favorite,
    required this.onToggleFavorite,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final int patchNumber;
  final String? name;
  final bool preSelected;
  final bool active;

  /// Whether the user has starred this slot, and what tapping the star does.
  /// A star is the user's own mark and says nothing about the pedal.
  final bool favorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectable = amperoMiniIsSelectableOverMidi(patchNumber);
    final foreground = active
        ? colors.onPrimary
        : selectable
        ? null
        : colors.outline;

    // The star is a sibling of the tile's gesture area, not inside it: under
    // an InkWell that listens for double taps, a tap on the star would wait out
    // the double-tap window before it fired.
    return Stack(
      children: [
        Positioned.fill(
          child: InkWell(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: Container(
              decoration: BoxDecoration(
                color: active ? colors.primary : null,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: preSelected ? colors.primary : colors.outlineVariant,
                  width: preSelected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: _labels(theme, colors, selectable, foreground),
            ),
          ),
        ),
        Positioned(top: 0, right: 0, child: _star(colors, foreground)),
      ],
    );
  }

  Widget _star(ColorScheme colors, Color? foreground) {
    return IconButton(
      icon: Icon(favorite ? Icons.star : Icons.star_border),
      iconSize: 20,
      visualDensity: VisualDensity.compact,
      tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
      color: favorite ? colors.tertiary : foreground ?? colors.outline,
      onPressed: onToggleFavorite,
    );
  }

  Widget _labels(
    ThemeData theme,
    ColorScheme colors,
    bool selectable,
    Color? foreground,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          amperoMiniPatchLabel(patchNumber),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: foreground,
            decoration: selectable ? null : TextDecoration.lineThrough,
          ),
        ),
        Text(
          name ?? (selectable ? '(name unknown)' : 'tap twice to try'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: foreground ?? colors.outline,
            fontStyle: name == null ? FontStyle.italic : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
