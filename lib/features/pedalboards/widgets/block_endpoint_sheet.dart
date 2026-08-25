import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/signal_destination.dart';
import '../../../core/enums/signal_source.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/endpoint_choices.dart';
import '../data/signal_endpoint_draft.dart';
import '../data/signal_endpoint_repository.dart';
import '../data/signal_endpoint_validator.dart';
import '../providers/pedalboard_providers.dart';
import 'sheet_note.dart';

/// Where signal leaves the rig at this block, or where it arrives from.
///
/// One sheet for both directions, because which of the two is asked is decided by
/// the block's own type rather than by the user: a send and an output go somewhere,
/// an input and a return come from somewhere. Asking both would let a block claim
/// to be two ends of the same cable.
///
/// Nothing is guessed. A rig that has not been asked stays unanswered, and the
/// chain reads as not-said rather than as a guitar and an amplifier.
class BlockEndpointSheet extends ConsumerStatefulWidget {
  const BlockEndpointSheet({required this.block, this.saved, super.key});

  final SignalBlock block;

  /// What this block already said it reaches, so the form opens on the user's own
  /// last answer. Handed in rather than read here: the sheet is a form over one
  /// row, and a stream pushing a change under a half-filled form would take the
  /// user's typing with it.
  final SignalEndpoint? saved;

  @override
  ConsumerState<BlockEndpointSheet> createState() => _BlockEndpointSheetState();
}

class _BlockEndpointSheetState extends ConsumerState<BlockEndpointSheet> {
  final TextEditingController _gear = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  SignalDestination? _destination;
  SignalSource? _source;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.saved;
    _destination = saved?.destination;
    _source = saved?.source;
    _gear.text = saved?.gear ?? '';
    _notes.text = saved?.notes ?? '';
  }

  @override
  void dispose() {
    _gear.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _facesOut => widget.block.blockType.carriesDestination;

  /// Whether there is enough to save. The validator would refuse an empty answer
  /// anyway; disabled reads better than a refusal the user could not have avoided.
  bool get _isReady {
    if (_facesOut ? _destination == null : _source == null) return false;
    final needsGear =
        _destination == SignalDestination.custom ||
        _source == SignalSource.custom;
    return !needsGear || _gear.text.trim().isNotEmpty;
  }

  Future<void> _run(
    Future<void> Function(SignalEndpointRepository endpoints) write,
  ) async {
    setState(() => _isSaving = true);

    try {
      await write(ref.read(signalEndpointRepositoryProvider));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              _facesOut ? 'Where does this go?' : 'Where does this come from?',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [..._choices(), const Divider(), ..._fields()],
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  /// The list of somewheres, grouped when it is long enough to need headings.
  List<Widget> _choices() {
    if (!_facesOut) {
      return [
        for (final source in sourceChoices)
          _ChoiceTile(
            label: source.label,
            isChosen: source == _source,
            onTap: () => setState(() => _source = source),
          ),
      ];
    }

    return [
      for (final group in destinationGroups) ...[
        SheetNote(group.heading),
        for (final destination in group.destinations)
          _ChoiceTile(
            label: destination.label,
            isChosen: destination == _destination,
            onTap: () => setState(() => _destination = destination),
          ),
      ],
    ];
  }

  List<Widget> _fields() {
    final needsGear =
        _destination == SignalDestination.custom ||
        _source == SignalSource.custom;

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: TextField(
          controller: _gear,
          maxLength: SignalEndpointValidator.gearMaxLength,
          // Redrawn as it is typed, because it decides whether Save is offered
          // when the answer is one the app has no name for.
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: needsGear
                ? 'What is it?'
                : 'What is at the other end (optional)',
            hintText: 'Marshall JVM 410',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: TextField(
          controller: _notes,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
        ),
      ),
    ];
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Only where there is something to forget, and worded as unsaying it
          // rather than as deleting: the block itself stays on the rig.
          if (widget.saved != null)
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => _run(
                      (endpoints) => endpoints.clearEndpoint(widget.block.id),
                    ),
              child: const Text('Not saying'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: _isReady && !_isSaving ? _saveDescription : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveDescription() {
    _run(
      (endpoints) => endpoints.describe(
        blockId: widget.block.id,
        draft: SignalEndpointDraft(
          destination: _destination,
          source: _source,
          gear: _gear.text,
          notes: _notes.text,
        ),
      ),
    );
  }
}

/// One somewhere signal could go or come from, ticked when it is the answer.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.isChosen,
    required this.onTap,
  });

  final String label;
  final bool isChosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isChosen ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(label, overflow: TextOverflow.ellipsis),
      selected: isChosen,
      onTap: onTap,
    );
  }
}
