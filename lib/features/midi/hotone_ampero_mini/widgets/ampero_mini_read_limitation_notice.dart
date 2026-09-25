import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// States plainly what this grid is and is not.
///
/// The tiles below it are the pedal's own 198 patch slots (OFFICIAL count), of
/// which the 99 user patches are selectable - VERIFIED ON HARDWARE, because
/// sending one does change the loaded patch, and because sending a factory one
/// does not. They are *not* patches read out of the device: no request/response
/// command for reading Ampero Mini patch data has been confirmed, so names and
/// contents are genuinely unavailable rather than merely not fetched yet.
///
/// The wording says names *should* come from the pedal, because that is the
/// requirement and it is not met yet - it does not offer the user a way to
/// type names instead, which would answer a different question than the one
/// they asked.
///
/// Deliberately one line high, with the rest behind Details: the patch list
/// is what the user came for, and an explanation tall enough to push the
/// first rows off a phone screen would be its own bug.
class AmperoMiniReadLimitationNotice extends StatelessWidget {
  const AmperoMiniReadLimitationNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Names cannot be read from this pedal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showDetails(context),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why patches have no names'),
        // Scrollable: this is four paragraphs, which does not fit a short
        // screen in landscape, and an overflowing dialog is unreadable.
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All 198 patches are shown, labelled as the pedal labels '
                'them: 99 user patches P01-1 to P33-3, then 99 factory patches '
                'F01-1 to F33-3. They are the pedal\'s slots, though, not '
                'patches read off the device.',
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Every user patch can be selected from here, and that is '
                'verified on the hardware. No factory patch is, yet: sending '
                'F01-1 as a plain Program Change left the pedal where it was. '
                'They are shown struck through, and double-tapping one offers '
                'a few experimental Bank Select attempts to try while watching '
                'the pedal - none of them confirmed.',
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                '"Last sent" is what this app put on the wire, and no more than '
                'that. The pedal has no confirmed way of reporting which patch '
                'it loaded, so changing patches with its own footswitches will '
                'not show up here.',
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Patch names should come from the pedal, and they will once the '
                'command that asks it for a patch is known. No such command has '
                'been confirmed for this model, and the pedal never sends names '
                'unprompted, so there is nothing to display yet. Showing '
                'made-up names would be worse than showing none.',
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'MIDI Diagnostics, in this screen\'s overflow menu, records what '
                'the pedal sends and exports it as JSON - which is how the '
                'protocol is being worked out.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
