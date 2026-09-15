import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../core/midi/preset_transfer/imported_preset.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/preset_import_service.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/preset_import_providers.dart';
import '../widgets/preset_import_summary_view.dart';

/// Read-only preset import from a real device - see Part 1 of the MIDI
/// module brief.
///
/// Reachable from a device's Patches screen. Every device profile currently
/// has [presetImportServiceProvider] resolve to null - see that provider's
/// documentation - so today this always shows why, rather than an import
/// flow. The flow below exists so it can be built and tested against
/// `MockNuxMg30V5PresetTransferService` now, ready for whichever device
/// profile confirms a real transfer protocol first.
class PresetImportScreen extends ConsumerWidget {
  const PresetImportScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final pedalAsync = ref.watch(linkedPedalProvider(profileId));
    final service = ref.watch(presetImportServiceProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: const Text('Import Presets')),
      body: pedalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this device\'s gear',
          message: failureMessage(error),
        ),
        data: (pedal) {
          if (pedal == null) {
            return const EmptyState(
              icon: Icons.link_off,
              title: 'Not gear yet',
              message: 'Add this device as gear from its Patches screen first.',
            );
          }
          if (service == null) {
            return EmptyState(
              icon: Icons.block,
              title: 'Not available for ${profile.displayName}',
              message:
                  'NUX has not published a SysEx protocol for reading saved '
                  'patches off this unit, and its own MIDI implementation '
                  'chart names no command for it either. Confirming this '
                  'needs an official SysEx specification from NUX, or a MIDI '
                  'capture of NUX\'s own editor software reading a patch off '
                  'real hardware.',
            );
          }
          return _ImportFlow(unitId: pedal.id, service: service);
        },
      ),
    );
  }
}

enum _Stage { idle, fetching, ready, importing, done }

class _ImportFlow extends StatefulWidget {
  const _ImportFlow({required this.unitId, required this.service});

  final int unitId;
  final PresetImportService service;

  @override
  State<_ImportFlow> createState() => _ImportFlowState();
}

class _ImportFlowState extends State<_ImportFlow> {
  _Stage _stage = _Stage.idle;
  int _progressCompleted = 0;
  int _progressTotal = 0;
  List<ImportedPreset> _presets = const [];
  PresetImportSummary? _summary;

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.idle => Center(
        child: FilledButton(onPressed: _scan, child: const Text('Scan Device for Presets')),
      ),
      _Stage.fetching => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: _progressTotal == 0 ? null : _progressCompleted / _progressTotal,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Read $_progressCompleted of $_progressTotal presets...'),
            ],
          ),
        ),
      ),
      _Stage.ready => _presets.isEmpty
          ? const EmptyState(icon: Icons.folder_off, title: 'No presets found')
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: FilledButton(
                    onPressed: _importAll,
                    child: Text('Import ${_presets.length} presets'),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final preset in _presets)
                        ListTile(
                          title: Text('${preset.programNumber} — ${preset.name}'),
                          subtitle: Text(preset.confidence.label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      _Stage.importing => const Center(child: CircularProgressIndicator()),
      _Stage.done => PresetImportSummaryView(
        summary: _summary!,
        onDone: () => setState(() => _stage = _Stage.idle),
      ),
    };
  }

  Future<void> _scan() async {
    setState(() {
      _stage = _Stage.fetching;
      _progressCompleted = 0;
      _progressTotal = 0;
    });
    try {
      final presets = await widget.service.fetchPresets(
        onProgress: (completed, total) {
          if (mounted) {
            setState(() {
              _progressCompleted = completed;
              _progressTotal = total;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _presets = presets;
          _stage = _Stage.ready;
        });
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
        setState(() => _stage = _Stage.idle);
      }
    }
  }

  Future<void> _importAll() async {
    setState(() => _stage = _Stage.importing);
    try {
      final summary = await widget.service.importPresets(
        unitId: widget.unitId,
        presets: _presets,
        resolveDuplicate: _resolveDuplicate,
      );
      if (mounted) {
        setState(() {
          _summary = summary;
          _stage = _Stage.done;
        });
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
        setState(() => _stage = _Stage.ready);
      }
    }
  }

  Future<PresetImportDecision> _resolveDuplicate(ImportedPreset incoming, Patch existing) async {
    final decision = await showDialog<PresetImportDecision>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already imported'),
        content: Text(
          'Patch ${incoming.programNumber} on the device matches "${existing.name}", '
          'already in your library. Replace it with the incoming preset, or leave it as is?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(PresetImportDecision.skip),
            child: const Text('Keep existing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(PresetImportDecision.overwrite),
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
    return decision ?? PresetImportDecision.skip;
  }
}
