import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_message.dart';
import '../../../core/midi/midi_request_failure.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/inline_button_theme.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_preset_capture_providers.dart';

/// Milestone 1 of the preset-import brief: read exactly one MG-30 preset by
/// number and show what actually came back - never a fabricated result.
///
/// Everything here is labeled experimental on purpose: the request/response
/// shape is reverse-engineered from a GPL-3.0 community project confirmed
/// only on its own firmware (v4.0.3), not against this app's V5 unit - see
/// `NuxMg30V5SysEx`. A successful read here is evidence towards V5
/// compatibility, not proof of it, until the decoded fields are checked by
/// eye against what is actually saved in that patch slot.
///
/// [unitId] is the gear row to save a capture against - null when this
/// device has not been added as gear yet, in which case reading still works
/// but nothing can be saved.
class NuxMg30V5PresetReadPanel extends ConsumerStatefulWidget {
  const NuxMg30V5PresetReadPanel({required this.profileId, required this.unitId, super.key});

  final String profileId;
  final int? unitId;

  @override
  ConsumerState<NuxMg30V5PresetReadPanel> createState() => _NuxMg30V5PresetReadPanelState();
}

class _NuxMg30V5PresetReadPanelState extends ConsumerState<NuxMg30V5PresetReadPanel> {
  final _controller = TextEditingController(text: '1');
  bool _reading = false;
  bool _saving = false;
  bool _saved = false;
  Object? _error;
  MidiMessage? _response;
  DecodedNuxMg30V5Preset? _decoded;
  int? _readProgramNumber;

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
            Text('Read One Preset (Experimental)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Unverified for V5 - reverse-engineered from a community project '
              'confirmed only on older firmware. A successful read is evidence, '
              'not proof, of V5 compatibility.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            InlineButtonTheme(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Program number (0-127; "01A" = 0)',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _reading ? null : _read,
                    child: _reading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Read Preset'),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_readableError(_error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_response != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Preset received. Raw response length: ${_response!.toBytes().length} bytes.'),
              const SizedBox(height: AppSpacing.xs),
              if (widget.unitId == null)
                const Text(
                  'Add this device as gear to save captures.',
                  style: TextStyle(fontSize: 12),
                )
              else
                OutlinedButton(
                  onPressed: _saving || _saved ? null : _save,
                  child: Text(
                    _saved
                        ? 'Saved'
                        : _saving
                        ? 'Saving...'
                        : 'Save Capture',
                  ),
                ),
            ],
            if (_decoded != null) ..._decodedSummary(_decoded!),
          ],
        ),
      ),
    );
  }

  List<Widget> _decodedSummary(DecodedNuxMg30V5Preset decoded) {
    return [
      const SizedBox(height: AppSpacing.sm),
      Text('Program ${decoded.programNumber}: "${decoded.name ?? '(name not decoded)'}"'),
      if (decoded.tempoBpm != null) Text('Tempo: ${decoded.tempoBpm} BPM'),
      if (decoded.signalChainOrder.isNotEmpty)
        Text('Chain order: ${decoded.signalChainOrder.join(' → ')}'),
      for (final block in decoded.blocks)
        Text(
          '${block.label}: model ${block.modelCode}, '
          'scenes ${block.bypassPerScene.map((on) => on ? 'on' : 'off').join('/')}'
          '${block.isParallel == true ? ' (parallel)' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Not decoded: ${decoded.unsupportedFields.join('; ')}.',
        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
      ),
    ];
  }

  Future<void> _read() async {
    final programNumber = int.tryParse(_controller.text.trim());
    if (programNumber == null || programNumber < 0 || programNumber > 127) {
      setState(() => _error = 'Enter a program number from 0 to 127.');
      return;
    }

    setState(() {
      _reading = true;
      _error = null;
      _response = null;
      _decoded = null;
      _saved = false;
      _readProgramNumber = programNumber;
    });

    try {
      final response = await ref.read(nuxMg30V5PresetReaderProvider).readPreset(programNumber);
      DecodedNuxMg30V5Preset? decoded;
      try {
        decoded = decodeNuxMg30V5Preset(response);
      } catch (_) {
        // The read itself succeeded - showing the raw length still matters
        // even if decoding this particular reply fails.
        decoded = null;
      }
      if (mounted) {
        setState(() {
          _response = response;
          _decoded = decoded;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _save() async {
    final unitId = widget.unitId;
    final response = _response;
    final programNumber = _readProgramNumber;
    if (unitId == null || response == null || programNumber == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(midiPresetCaptureRepositoryProvider)
          .saveCapture(
            pedalId: unitId,
            deviceProfileId: widget.profileId,
            programNumber: programNumber,
            rawSysEx: response.toBytes(),
            decoded: _decoded,
          );
      if (mounted) setState(() => _saved = true);
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _readableError(Object error) => switch (error) {
    String message => message,
    MidiRequestTimedOut _ =>
      'The MG-30 did not answer within the timeout. It may not respond to '
          'this SysEx command on V5 firmware, or the unit is busy.',
    StateError _ => 'Not connected to the MG-30.',
    _ => 'Could not read that preset. The response may not match what this '
        'app expects for V5.',
  };
}
