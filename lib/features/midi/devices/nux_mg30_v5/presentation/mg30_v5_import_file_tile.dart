import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/failure_snack_bar.dart';
import '../application/mg30_v5_import_providers.dart';
import '../data/mg30_v5_patch_file_chooser.dart';
import '../protocol/mg30_v5_patch_file.dart';

/// Imports a QuickTone `.mg30patch` export into the unit's patch library.
///
/// The one import path that needs no hardware and no unverified protocol: the
/// file layout is established byte for byte, so what lands in the library is as
/// good as the device's own export. Reading patches over MIDI is a separate
/// action, and will say so when it is verified.
class Mg30V5ImportFileTile extends ConsumerStatefulWidget {
  const Mg30V5ImportFileTile({
    required this.unitId,
    this.chooser = chooseMg30PatchFile,
    super.key,
  });

  final int unitId;

  /// Injectable so a widget test can hand over bytes without a file picker.
  final Mg30PatchFileChooser chooser;

  @override
  ConsumerState<Mg30V5ImportFileTile> createState() =>
      _Mg30V5ImportFileTileState();
}

class _Mg30V5ImportFileTileState extends ConsumerState<Mg30V5ImportFileTile> {
  bool _running = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return ListTile(
      leading: const Icon(Icons.folder_open),
      title: const Text('Import patches from a QuickTone export'),
      subtitle: Text(
        result ??
            'Reads a .mg30patch file: every patch, its three Pro Scenes and the '
                'bytes they were decoded from.',
      ),
      trailing: _running
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _running ? null : _import,
    );
  }

  Future<void> _import() async {
    setState(() {
      _running = true;
      _result = null;
    });

    try {
      final bytes = await widget.chooser();
      if (bytes == null) {
        return;
      }
      final patches = readMg30V5PatchFile(bytes);
      final summary = await ref
          .read(mg30V5PatchLibraryImporterProvider)
          .import(unitId: widget.unitId, patches: patches);

      // The count comes from what was written, not from what was read: a slot
      // that failed is named rather than quietly folded into a success.
      setState(() {
        _result = summary.failures.isEmpty
            ? 'Imported ${summary.imported} patch(es).'
            : 'Imported ${summary.imported}, '
                  '${summary.failures.length} failed: '
                  '${summary.failures.first}';
      });
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }
}
