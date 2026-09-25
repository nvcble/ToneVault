import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../data/ampero_mini_patch_layout.dart';

/// One patch in the Ampero Mini's grid, headed by the pedal's own label.
///
/// A single tap only pre-selects it - [preSelected] outlines it, and nothing is
/// sent. A double tap is what activates it on the device, which is when
/// [active] fills it.
///
/// Factory patches are shown greyed with a struck-through label: the pedal has
/// them, so hiding them would misrepresent it, but it does not respond to a
/// plain Program Change for them - see [amperoMiniIsSelectableOverMidi]. Double
/// tapping one offers the experimental Bank Select attempts instead of
/// activating it, hence "tap twice to try".
///
/// [name] is only ever a name decoded from bytes the pedal sent, so it is null
/// on every patch until a patch-read command is confirmed for this model.
class AmperoMiniPatchGridTile extends StatelessWidget {
  const AmperoMiniPatchGridTile({
    required this.patchNumber,
    required this.name,
    required this.preSelected,
    required this.active,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final int patchNumber;
  final String? name;
  final bool preSelected;
  final bool active;
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

    return InkWell(
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
        child: Column(
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
        ),
      ),
    );
  }
}
