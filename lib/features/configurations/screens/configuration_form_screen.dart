import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/configuration_draft.dart';
import '../providers/configuration_editor.dart';
import '../providers/configuration_providers.dart';
import '../widgets/configuration_form.dart';

/// Adds a configuration to [pedalId], or renames [configurationId] when one is
/// given.
class ConfigurationFormScreen extends ConsumerStatefulWidget {
  const ConfigurationFormScreen({
    required this.pedalId,
    this.configurationId,
    super.key,
  });

  final int pedalId;
  final int? configurationId;

  @override
  ConsumerState<ConfigurationFormScreen> createState() =>
      _ConfigurationFormScreenState();
}

class _ConfigurationFormScreenState
    extends ConsumerState<ConfigurationFormScreen> {
  bool _isSaving = false;

  bool get _isEditing => widget.configurationId != null;

  Future<void> _save(ConfigurationDraft draft) async {
    setState(() => _isSaving = true);

    try {
      final configurationId = await ref
          .read(configurationEditorProvider)
          .save(
            draft,
            pedalId: widget.pedalId,
            configurationId: widget.configurationId,
          );
      if (mounted) {
        // Straight to the settings, which is what a new configuration is for.
        context.go(Routes.configurationDetail(widget.pedalId, configurationId));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  Future<void> _confirmDelete(int configurationId) async {
    final name =
        ref.read(configurationProvider(configurationId)).valueOrNull?.name ??
        'this configuration';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete configuration?'),
        content: Text(
          'Every position stored under $name is deleted with it. The pedal and '
          'its controls are untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(configurationEditorProvider).delete(configurationId);
      if (mounted) {
        context.go(Routes.pedalDetail(widget.pedalId));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configurationId = widget.configurationId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit configuration' : 'Add configuration'),
        actions: configurationId == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: _isSaving
                      ? null
                      : () => _confirmDelete(configurationId),
                ),
              ],
      ),
      body: configurationId == null
          ? ConfigurationForm(
              submitLabel: 'Add configuration',
              isSaving: _isSaving,
              onSubmit: _save,
            )
          : _buildEditBody(configurationId),
    );
  }

  Widget _buildEditBody(int configurationId) {
    return ref
        .watch(configurationProvider(configurationId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this configuration',
            message: failureMessage(error),
          ),
          data: (configuration) {
            if (configuration == null) {
              return const EmptyState(
                icon: Icons.help_outline,
                title: 'That configuration no longer exists',
              );
            }

            return ConfigurationForm(
              // A different configuration has to start the fields over; the same
              // one keeps whatever is half-typed.
              key: ValueKey<int>(configuration.id),
              initialDraft: ConfigurationDraft.fromConfiguration(configuration),
              submitLabel: 'Save changes',
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
