import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/control_editor.dart';
import 'control_tile.dart';

/// A pedal's controls, in the order they sit on the pedal.
///
/// The order is the user's own arrangement rather than anything derived, so it
/// is dragged rather than sorted.
class ReorderableControlList extends ConsumerStatefulWidget {
  const ReorderableControlList({
    required this.pedalId,
    required this.controls,
    required this.onEdit,
    super.key,
  });

  final int pedalId;
  final List<PedalControl> controls;
  final ValueChanged<PedalControl> onEdit;

  @override
  ConsumerState<ReorderableControlList> createState() =>
      _ReorderableControlListState();
}

class _ReorderableControlListState
    extends ConsumerState<ReorderableControlList> {
  late List<PedalControl> _controls = widget.controls;

  /// A drag is being written; see [didUpdateWidget].
  bool _isSaving = false;

  /// A copy is being written, so one tap cannot become two controls. Kept apart
  /// from [_isSaving] because a copy has no local order to protect: the new
  /// control should appear as soon as the database reports it.
  bool _isDuplicating = false;

  bool get _isBusy => _isSaving || _isDuplicating;

  @override
  void didUpdateWidget(covariant ReorderableControlList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A drag shows the new order immediately and writes it afterwards. Until
    // that write lands the database still reports the old order, and adopting it
    // here would bounce every row back under the user's finger.
    if (!_isSaving) {
      _controls = widget.controls;
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final moved = [..._controls];
    // onReorderItem reports the index the row ends up at, so no adjustment for
    // the row that was just removed is needed here.
    moved.insert(newIndex, moved.removeAt(oldIndex));

    setState(() {
      _controls = moved;
      _isSaving = true;
    });

    try {
      await ref.read(controlEditorProvider).reorder(widget.pedalId, [
        for (final control in moved) control.id,
      ]);
    } catch (error) {
      if (mounted) {
        // Put the list back the way the database still has it.
        setState(() => _controls = widget.controls);
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Copies a control, and says what the copy is called: it lands at the end of
  /// the list, which on a pedal with a few controls is off screen.
  Future<void> _duplicate(PedalControl control) async {
    setState(() => _isDuplicating = true);

    try {
      final name = await ref.read(controlEditorProvider).duplicate(control.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Added "$name".')));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isDuplicating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: _controls.length,
      onReorderItem: _reorder,
      // The whole row is tappable for editing, so dragging gets its own handle
      // instead of a long press that would fight the tap.
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final control = _controls[index];

        return ControlTile(
          key: ValueKey<int>(control.id),
          control: control,
          onTap: _isBusy ? null : () => widget.onEdit(control),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Copying is per control, so it sits on the control rather than in
              // a menu over the whole list.
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: 'Duplicate control',
                onPressed: _isBusy ? null : () => _duplicate(control),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.drag_handle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
