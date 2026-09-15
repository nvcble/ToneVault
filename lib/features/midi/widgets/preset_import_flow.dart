import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/preset_transfer/imported_preset.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/preset_import_service.dart';
import 'preset_import_summary_view.dart';

/// Scan → review → import, against whatever [PresetImportService] it is
/// given - a real, verified transfer or an experimental one built from
/// already-captured diagnostic data. The flow itself does not know or care
/// which; that distinction is made by whoever constructs the service.
class PresetImportFlow extends StatefulWidget {
  const PresetImportFlow({required this.unitId, required this.service, super.key});

  final int unitId;
  final PresetImportService service;

  @override
  State<PresetImportFlow> createState() => _PresetImportFlowState();
}

enum _Stage { idle, fetching, ready, importing, done }

class _PresetImportFlowState extends State<PresetImportFlow> {
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
    final overwrites = await widget.service.countOverwrites(widget.unitId, _presets);
    if (overwrites > 0 && !await _confirmOverwriteAll(overwrites)) {
      return; // Cancel All: the dialog closes, nothing about the library changes.
    }

    setState(() => _stage = _Stage.importing);
    try {
      final summary = await widget.service.importPresets(
        unitId: widget.unitId,
        presets: _presets,
        // The bulk choice was already made above; every conflict from here
        // follows it, rather than asking again patch by patch.
        resolveDuplicate: (_, _) async => PresetImportDecision.overwrite,
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

  /// Asks once, for the whole batch, rather than once per conflicting patch -
  /// see the MIDI module brief's duplicate-handling requirement.
  Future<bool> _confirmOverwriteAll(int overwrites) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Presets'),
        content: Text(
          '$overwrites of ${_presets.length} incoming presets match a patch already '
          'in your library by program number. The rest of your library is untouched '
          'either way.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel All'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Overwrite All ($overwrites)'),
          ),
        ],
      ),
    );
    return proceed ?? false;
  }
}
