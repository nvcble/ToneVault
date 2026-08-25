import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/signal_block_draft.dart';
import '../support/chain_rows.dart';

/// What the user typed about a block, tidied before it becomes a row.
void main() {
  test('trims what was typed', () {
    const draft = SignalBlockDraft(
      blockType: SignalBlockType.delay,
      label: '  Slapback ',
      notes: ' Dotted eighths ',
    );

    final tidy = draft.normalized();
    expect(tidy.label, 'Slapback');
    expect(tidy.notes, 'Dotted eighths');
  });

  test('blank optional text becomes nothing at all', () {
    // A cleared label has to fall back to the block's type rather than leave it
    // called ' '.
    const draft = SignalBlockDraft(
      blockType: SignalBlockType.delay,
      label: '   ',
      notes: '',
    );

    final tidy = draft.normalized();
    expect(tidy.label, isNull);
    expect(tidy.notes, isNull);
    expect(tidy.blockType, SignalBlockType.delay);
  });

  test('a new block is in the chain unless it is said not to be', () {
    expect(
      const SignalBlockDraft(blockType: SignalBlockType.delay).isEnabled,
      isTrue,
    );
  });

  test('an existing block opens on what it already says', () {
    final block = chainBlock(
      10,
      type: SignalBlockType.delay,
      label: 'Slapback',
      isEnabled: false,
      notes: 'Dotted eighths',
    ).block;

    final draft = SignalBlockDraft.fromBlock(block);
    expect(draft.blockType, SignalBlockType.delay);
    expect(draft.label, 'Slapback');
    expect(draft.notes, 'Dotted eighths');
    expect(draft.isEnabled, isFalse);
  });
}
