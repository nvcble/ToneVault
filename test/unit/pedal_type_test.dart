import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';

/// How a pedal makes its sound, which is what decides how its settings are read:
/// clock positions on an analog knob, numbers on a digital display.
void main() {
  test('every type reads out as the word a player would use', () {
    // Named one by one on purpose: a type added later should have to write its
    // own word rather than inherit an answer from this test.
    expect(PedalType.analog.label, 'Analog');
    expect(PedalType.digital.label, 'Digital');
    expect(PedalType.hybrid.label, 'Hybrid');
    expect(PedalType.values, hasLength(3));
  });
}

// Kept for tracking: this file used to assert `hasOwnControls` per type, with
// `multiEffects` the one type that had none. Both moved. What a pedal is made of
// and what it does are separate answers, so being a multi-effects unit is a
// category now; the rule is asserted in `pedal_category_test.dart`.
