import '../../../core/database/app_database.dart';
import '../../../core/enums/signal_block_type.dart';

/// What the user chose about one block of a chain, before it becomes a row.
///
/// The pedal in the block is not here, and neither is its position. Both are
/// changed by their own gestures - a picker and a drag - so a form that carried
/// them would be a second way to do what the chain already does.
class SignalBlockDraft {
  const SignalBlockDraft({
    required this.blockType,
    this.label,
    this.notes,
    this.isEnabled = true,
  });

  factory SignalBlockDraft.fromBlock(SignalBlock block) {
    return SignalBlockDraft(
      blockType: block.blockType,
      label: block.label,
      notes: block.notes,
      isEnabled: block.isEnabled,
    );
  }

  final SignalBlockType blockType;

  /// What the block is called on the board, where the pedal's own name is not
  /// what the user thinks of it as ('Always on', 'Solo boost').
  final String? label;

  final String? notes;
  final bool isEnabled;

  /// Trims text and turns blank optional text into null, so a block left with a
  /// cleared label falls back to its type rather than being called ' '.
  SignalBlockDraft normalized() {
    return SignalBlockDraft(
      blockType: blockType,
      label: _tidied(label),
      notes: _tidied(notes),
      isEnabled: isEnabled,
    );
  }

  static String? _tidied(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
