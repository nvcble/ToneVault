import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/action_row.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/configuration_validator.dart';
import '../data/control_value_range.dart';
import '../providers/configuration_editor.dart';
import 'control_value_editor.dart';

/// Sets one control on one configuration.
///
/// A sheet rather than a screen: setting a rig up means walking the pedal's
/// controls in order, and the list has to stay behind the editor. Nothing is
/// written until Save, so backing out of a control leaves it exactly as it was -
/// including leaving it unset.
class ValueEditorSheet extends ConsumerStatefulWidget {
  const ValueEditorSheet({
    required this.configurationId,
    required this.control,
    this.storedValue,
    super.key,
  });

  final int configurationId;
  final PedalControl control;

  /// Null when this control has never been set on this configuration.
  final double? storedValue;

  @override
  ConsumerState<ValueEditorSheet> createState() => _ValueEditorSheetState();
}

class _ValueEditorSheetState extends ConsumerState<ValueEditorSheet> {
  late double? _value = widget.storedValue ?? startingValueFor(widget.control);
  final TextEditingController _reasonController = TextEditingController();
  String? _problem;
  bool _isSaving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Blank means the user chose not to explain themselves, which the history
  /// records as no reason rather than as an empty one.
  String? get _reason {
    final reason = _reasonController.text.trim();
    return reason.isEmpty ? null : reason;
  }

  Future<void> _save() async {
    final problem = ConfigurationValidator.value(
      _value,
      control: widget.control,
    );
    if (problem != null) {
      setState(() => _problem = problem);
      return;
    }

    await _run(
      () => ref
          .read(configurationEditorProvider)
          .setValue(
            configurationId: widget.configurationId,
            controlId: widget.control.id,
            value: _value!,
            reason: _reason,
          ),
    );
  }

  Future<void> _clear() {
    return _run(
      () => ref
          .read(configurationEditorProvider)
          .clearValue(
            configurationId: widget.configurationId,
            controlId: widget.control.id,
            reason: _reason,
          ),
    );
  }

  /// A failed write leaves the sheet open, so the reading on screen is never one
  /// the database disagreed with.
  Future<void> _run(Future<void> Function() write) async {
    setState(() => _isSaving = true);

    try {
      await write();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Clears the keyboard the typed editor brings up.
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.control.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ControlValueEditor(
            control: widget.control,
            value: _value,
            errorText: _problem,
            onChanged: _isSaving
                ? null
                : (value) => setState(() {
                    _value = value;
                    _problem = null;
                  }),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _reasonController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Why the change?',
              hintText: 'Needed more saturation for lead',
              helperText: 'Optional, and kept in this pedal\'s history',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return ActionRow(
      leading: widget.storedValue == null
          ? null
          : TextButton(
              onPressed: _isSaving ? null : _clear,
              child: const Text('Clear'),
            ),
      children: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Kept for tracking: this is the row that made the sheet look dead. The app
  // theme gives FilledButton an infinite minimum width, which a Row cannot
  // satisfy, so opening the sheet threw during layout instead of drawing. Any
  // action bar built this way has the same fault; ActionRow above is the fix.
  //
  // Widget _buildActions() {
  //   return Row(
  //     children: [
  //       if (widget.storedValue != null)
  //         TextButton(
  //           onPressed: _isSaving ? null : _clear,
  //           child: const Text('Clear'),
  //         ),
  //       const Spacer(),
  //       TextButton(
  //         onPressed: _isSaving ? null : () => Navigator.pop(context),
  //         child: const Text('Cancel'),
  //       ),
  //       const SizedBox(width: AppSpacing.sm),
  //       FilledButton(
  //         onPressed: _isSaving ? null : _save,
  //         child: const Text('Save'),
  //       ),
  //     ],
  //   );
  // }
}
