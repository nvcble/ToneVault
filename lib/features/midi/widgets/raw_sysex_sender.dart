import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_message.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/midi_engine_providers.dart';

/// Sends exactly the bytes the user types, as SysEx - never a command this
/// app guessed at. This is the "controlled MIDI/SysEx messages" capability
/// the diagnostic brief asks for: the byte sequence to try comes from the
/// person doing the reverse-engineering, not from ToneVault pretending to
/// know a NUX protocol it has not confirmed.
class RawSysExSender extends ConsumerStatefulWidget {
  const RawSysExSender({super.key});

  @override
  ConsumerState<RawSysExSender> createState() => _RawSysExSenderState();
}

class _RawSysExSenderState extends ConsumerState<RawSysExSender> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send Raw SysEx', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Bytes you type are sent exactly as written. ToneVault does not '
              'know what they mean yet - this is for trying a candidate command '
              'against the real device, not a verified NUX protocol.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Hex bytes',
                hintText: 'F0 43 10 00 F7',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _sending ? null : _send,
                child: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final List<int> payload;
    try {
      final bytes = parseHexBytes(_controller.text);
      // The user may type the framing bytes themselves; either way, the
      // engine always sends one well-formed SysEx frame.
      payload = bytes.first == 0xF0 && bytes.last == 0xF7
          ? bytes.sublist(1, bytes.length - 1)
          : bytes;
    } on FormatException catch (error) {
      showFailureSnackBar(context, AppFailure(error.message));
      return;
    }

    setState(() => _sending = true);
    try {
      await ref.read(midiEngineProvider).send(SysExMessage(payload: payload));
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
