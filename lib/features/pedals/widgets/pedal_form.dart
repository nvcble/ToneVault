import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/pedal_status.dart';
import '../../../core/enums/pedal_type.dart';
import '../../../shared/formatting/app_date_format.dart';
import '../data/pedal_draft.dart';
import '../data/pedal_validator.dart';

/// Editable pedal fields, shared by the add and edit screens.
///
/// Owns field state only: it hands a [PedalDraft] to [onSubmit] and knows
/// nothing about saving, so both screens reuse it unchanged.
class PedalForm extends StatefulWidget {
  const PedalForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initialDraft,
    this.hostPedalId,
    this.isSaving = false,
    super.key,
  });

  final PedalDraft? initialDraft;
  final String submitLabel;

  /// The multi-effects unit this pedal sits inside, when it is a stomp or a
  /// block. Handed in by the screen that opened the form rather than entered:
  /// where a stomp lives is not a field anyone should be able to mistype.
  final int? hostPedalId;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// pedals.
  final bool isSaving;
  final ValueChanged<PedalDraft> onSubmit;

  @override
  State<PedalForm> createState() => _PedalFormState();
}

class _PedalFormState extends State<PedalForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _notesController;

  // Type and category start empty on a new pedal: guessing them would quietly
  // file a digital multi-effects unit as an analog overdrive.
  PedalType? _type;
  PedalCategory? _category;
  PedalStatus _status = PedalStatus.active;
  DateTime? _purchaseDate;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _nameController = TextEditingController(text: draft?.name ?? '');
    _brandController = TextEditingController(text: draft?.brand ?? '');
    _notesController = TextEditingController(text: draft?.notes ?? '');
    _type = draft?.type;
    _category = draft?.category;
    _status = draft?.status ?? PedalStatus.active;
    _purchaseDate = draft?.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// A multi-effects unit is described by its name and its category alone.
  ///
  /// What it sounds like is in its patches, and the pedals inside it carry their
  /// own brand, dates and status - asking for those on the outside as well only
  /// invites two answers that disagree.
  bool get _isUnit => _category == PedalCategory.multiEffects;

  void _submit() {
    final category = _category;
    // The type field is not on screen for a unit, so it is not asked for: every
    // multi-effects unit is digital, which is the same fact the v8 migration
    // asserted when the multi-effects pedal type was dropped.
    final type = _isUnit ? PedalType.digital : _type;

    if (!(_formKey.currentState?.validate() ?? false) ||
        type == null ||
        category == null) {
      return;
    }

    // The hidden fields hand back whatever they were holding rather than null:
    // a pedal that was filled in and then made a unit keeps its brand and its
    // purchase date, which are facts about it either way. Only the type is
    // decided here.
    widget.onSubmit(
      PedalDraft(
        name: _nameController.text,
        type: type,
        category: category,
        brand: _brandController.text,
        status: _status,
        purchaseDate: _purchaseDate,
        notes: _notesController.text,
        photoPath: widget.initialDraft?.photoPath,
        hostPedalId: widget.hostPedalId,
      ),
    );
  }

  Future<void> _pickPurchaseDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? today,
      // Pedals predate 1960, but a purchase does not, and the validator
      // rejects anything later than today anyway.
      firstDate: DateTime(1960),
      lastDate: today,
    );

    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseDate = _purchaseDate;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: PedalValidator.name,
          ),
          // Everything but the name and the category belongs to a pedal that
          // makes one sound; see [_isUnit].
          if (!_isUnit) ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                helperText: 'Optional',
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: PedalValidator.brand,
            ),
            const SizedBox(height: AppSpacing.md),
            _enumField<PedalType>(
              label: 'Type',
              value: _type,
              values: PedalType.values,
              labelOf: (type) => type.label,
              emptyMessage: 'Pick how this pedal makes its sound.',
              onChanged: (type) => setState(() => _type = type),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Category is what makes a pedal a multi-effects unit, and with it what
          // its own screen holds: patches instead of controls, and this form
          // without the fields above and below.
          _enumField<PedalCategory>(
            label: 'Category',
            value: _category,
            values: PedalCategory.values,
            labelOf: (category) => category.label,
            emptyMessage: 'Pick what this pedal does.',
            onChanged: (category) => setState(() => _category = category),
          ),
          if (!_isUnit) ...[
            const SizedBox(height: AppSpacing.md),
            _enumField<PedalStatus>(
              label: 'Status',
              value: _status,
              values: PedalStatus.values,
              labelOf: (status) => status.label,
              emptyMessage: 'Pick a status.',
              onChanged: (status) => setState(() => _status = status),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: widget.isSaving ? null : _pickPurchaseDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Purchase date',
                  helperText: 'Optional',
                  suffixIcon: purchaseDate == null
                      ? const Icon(Icons.calendar_today)
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear purchase date',
                          onPressed: () => setState(() => _purchaseDate = null),
                        ),
                ),
                child: Text(
                  purchaseDate == null ? 'Not set' : formatDate(purchaseDate),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                helperText: 'Optional',
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
                ? const SizedBox.square(
                    dimension: AppSpacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  /// One dropdown per enum-backed field.
  ///
  /// The fields differ only in their options, so they share a builder rather
  /// than four near-identical blocks.
  Widget _enumField<T extends Enum>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T) labelOf,
    required String emptyMessage,
    required ValueChanged<T> onChanged,
    String? helperText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, helperText: helperText),
      items: [
        for (final option in values)
          DropdownMenuItem<T>(value: option, child: Text(labelOf(option))),
      ],
      validator: (selected) => selected == null ? emptyMessage : null,
      onChanged: widget.isSaving
          ? null
          : (selected) {
              if (selected != null) {
                onChanged(selected);
              }
            },
    );
  }
}
