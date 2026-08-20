import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';

/// The dormant stomp/scene mode.
///
/// Nothing writes it any more, but a pedal saved while it was still asked for
/// still holds one, so both values have to keep parsing and keep reading as
/// words for as long as the column does.
void main() {
  test('both modes still parse and still read out', () {
    expect(MultiEffectsMode.stomp.label, 'Stomp mode');
    expect(MultiEffectsMode.scene.label, 'Scene mode');
    expect(MultiEffectsMode.values, hasLength(2));
  });
}

// Kept for tracking: this file used to assert the mode's screen words
// (description, tabLabel, componentsLabel, addComponentLabel) and the validator
// rule that only a multi-effects unit could carry a mode. All of it went with the
// mode itself: a unit is offered its Patch tab because of its category now, so
// nothing asks how the unit is used and nothing has a mode to reject.
