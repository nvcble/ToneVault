import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/midi/midi_device_profile.dart';
import '../../../../shared/widgets/failure_snack_bar.dart';
import '../data/ampero_mini_bank_select_probe.dart';
import '../data/ampero_mini_patch_layout.dart';
import '../providers/hotone_ampero_mini_data_providers.dart';

/// Offers the untried Bank Select layouts for a factory patch, one send at a
/// time, and says plainly that only the pedal can tell you whether one worked.
///
/// Sending is the user's decision, not this app's: nothing here is confirmed,
/// so an attempt is never made automatically and a sent attempt is reported as
/// "sent" rather than as a selection. Bank Select is safe to try in a way blind
/// SysEx is not - CC 0 and CC 32 are reserved by the MIDI specification for
/// exactly this, so the worst case is that the pedal ignores it or lands on an
/// unexpected patch, which a footswitch undoes.
class AmperoMiniBankSelectSheet extends ConsumerStatefulWidget {
  const AmperoMiniBankSelectSheet({
    required this.profile,
    required this.patchNumber,
    super.key,
  });

  final MidiDeviceProfile profile;
  final int patchNumber;

  static Future<void> show(
    BuildContext context, {
    required MidiDeviceProfile profile,
    required int patchNumber,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        AmperoMiniBankSelectSheet(profile: profile, patchNumber: patchNumber),
  );

  @override
  ConsumerState<AmperoMiniBankSelectSheet> createState() =>
      _AmperoMiniBankSelectSheetState();
}

class _AmperoMiniBankSelectSheetState
    extends ConsumerState<AmperoMiniBankSelectSheet> {
  final _sent = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = amperoMiniPatchLabel(widget.patchNumber);
    final attempts = amperoMiniBankSelectAttempts(widget.patchNumber);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Try to reach $label', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A plain Program Change does not move this pedal to a factory '
              'patch. These are untried guesses at how it might be addressed. '
              'Watch the pedal as you send each one - nothing here can tell '
              'whether it worked, and MIDI Diagnostics records what was sent.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final attempt in attempts)
              _AttemptTile(
                attempt: attempt,
                sent: _sent.contains(attempt.summary),
                onSend: () => _send(attempt),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _send(AmperoMiniBankSelectAttempt attempt) async {
    try {
      await ref
          .read(hotoneAmperoMiniMidiServiceProvider)
          .sendBankSelectAttempt(profile: widget.profile, attempt: attempt);
      if (mounted) setState(() => _sent.add(attempt.summary));
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    }
  }
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({
    required this.attempt,
    required this.sent,
    required this.onSend,
  });

  final AmperoMiniBankSelectAttempt attempt;
  final bool sent;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(attempt.summary),
    subtitle: Text(
      sent ? 'Sent. Did the pedal move?' : attempt.hypothesis,
      style: Theme.of(context).textTheme.bodySmall,
    ),
    trailing: TextButton(
      onPressed: onSend,
      child: Text(sent ? 'Send again' : 'Send'),
    ),
  );
}
