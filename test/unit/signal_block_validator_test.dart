import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/signal_block_draft.dart';
import 'package:tone_vault/features/pedalboards/data/signal_block_validator.dart';

/// What a block will and will not be called.
void main() {
  const limit = SignalBlockValidator.labelMaxLength;

  test('a label is optional', () {
    // A block is named by what it is for unless the user has something better to
    // call it.
    expect(SignalBlockValidator.label(null), isNull);
    expect(SignalBlockValidator.label(''), isNull);
    expect(SignalBlockValidator.label('   '), isNull);
  });

  test('a label as long as the column allows is accepted', () {
    expect(SignalBlockValidator.label('a' * limit), isNull);
  });

  test('a longer one says how long is allowed', () {
    expect(
      SignalBlockValidator.label('a' * (limit + 1)),
      'Use at most $limit characters.',
    );
  });

  test('the spaces around a label do not count against it', () {
    expect(SignalBlockValidator.label('  ${'a' * limit}  '), isNull);
  });

  test('a whole draft is judged on its label', () {
    const tooLong = SignalBlockDraft(
      blockType: SignalBlockType.delay,
      label:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
          'aaaaaaaaaaaaaaaaaa',
    );

    expect(SignalBlockValidator.draft(tooLong), isNotNull);
    expect(
      SignalBlockValidator.draft(
        const SignalBlockDraft(blockType: SignalBlockType.delay),
      ),
      isNull,
    );
  });
}
