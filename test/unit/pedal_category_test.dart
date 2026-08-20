import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';

/// What a pedal does, and with it whether it is dialled in on controls of its
/// own - which is what decides whether it is offered a Controls tab at all.
void main() {
  test('a multi-effects unit has no controls of its own', () {
    expect(PedalCategory.multiEffects.hasOwnControls, isFalse);
    expect(PedalCategory.multiEffects.label, 'Multi Effects');
  });

  test('and it is the only category that has none', () {
    // Asked across the whole enum rather than one category at a time: a category
    // added later has controls unless it says otherwise, and this is what would
    // catch one that quietly said otherwise.
    expect(PedalCategory.values.where((category) => !category.hasOwnControls), [
      PedalCategory.multiEffects,
    ]);
  });
}
