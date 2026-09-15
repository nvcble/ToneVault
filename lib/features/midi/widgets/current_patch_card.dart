import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';

/// The patch ToneVault last successfully loaded, shown the same way on the
/// Control, Live Control and Patch Browser screens.
///
/// Named by its program number rather than an invented bank/letter code (see
/// `MidiPatchBrowserScreen`) until the MG-30's real numbering scheme is
/// confirmed.
class CurrentPatchCard extends StatelessWidget {
  const CurrentPatchCard({required this.current, this.onChangePatch, super.key});

  final NumberedPatch? current;
  final VoidCallback? onChangePatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text('CURRENT PATCH', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          current == null ? '—' : '${current!.programNumber} — ${current!.patch.name}',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        if (onChangePatch != null) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onChangePatch, child: const Text('Change Patch')),
        ],
      ],
    );
  }
}
