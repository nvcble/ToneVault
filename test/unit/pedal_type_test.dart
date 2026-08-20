import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';

/// Which types are dialled in on controls of their own, since that is what
/// decides whether a pedal is offered a Controls tab at all.
void main() {
  test('a multi-effects unit has no controls of its own', () {
    expect(PedalType.multiEffects.hasOwnControls, isFalse);
  });

  test('every other type does', () {
    // Named one by one on purpose: a type added later should have to say which
    // side it falls on rather than inherit an answer from this test.
    expect(PedalType.analog.hasOwnControls, isTrue);
    expect(PedalType.digital.hasOwnControls, isTrue);
    expect(PedalType.hybrid.hasOwnControls, isTrue);
    expect(PedalType.values, hasLength(4));
  });

  test('reads out as the word a player would use', () {
    expect(PedalType.multiEffects.label, 'Multi-effects');
  });
}
