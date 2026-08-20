import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/controls/data/control_copy_name.dart';
import 'package:tone_vault/features/controls/data/control_validator.dart';

/// What a copied control ends up called.
void main() {
  test('marks the copy as one', () async {
    expect(copyNameFor('Volume', taken: const ['Volume']), 'Volume copy');
  });

  test('numbers the copies after the first', () async {
    expect(
      copyNameFor('Volume', taken: const ['Volume', 'Volume copy']),
      'Volume copy 2',
    );
    expect(
      copyNameFor(
        'Volume',
        taken: const ['Volume', 'Volume copy', 'Volume copy 2'],
      ),
      'Volume copy 3',
    );
  });

  test('copies a copy rather than counting from the original', () async {
    // Duplicating "Volume copy" is duplicating that control, and the next free
    // name for it is its own with a marker on it.
    expect(
      copyNameFor('Volume copy', taken: const ['Volume', 'Volume copy']),
      'Volume copy copy',
    );
  });

  test('a name free on this pedal is used as it is', () async {
    // The gap left by a deleted copy is filled rather than skipped.
    expect(
      copyNameFor('Volume', taken: const ['Volume', 'Volume copy 2']),
      'Volume copy',
    );
  });

  test('ignores case the way the pedal does', () async {
    // The repository refuses "Volume copy" next to "volume copy", so a name that
    // differs only in case is not free here either.
    expect(
      copyNameFor('Volume', taken: const ['volume', 'VOLUME COPY']),
      'Volume copy 2',
    );
  });

  test('keeps the marker on a name at the column limit', () async {
    final long = 'V' * ControlValidator.nameMaxLength;

    // Clipped to make room, because the marker is what makes the name free -
    // dropping it would hand the repository the name it already refused.
    final copy = copyNameFor(long, taken: [long]);
    expect(copy.length, ControlValidator.nameMaxLength);
    expect(copy.endsWith(' copy'), isTrue);
    expect(ControlValidator.name(copy), isNull);
  });
}
