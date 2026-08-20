import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_validator.dart';

/// The mode a multi-effects unit is used in, and the rule that it belongs to a
/// multi-effects unit and nothing else.
void main() {
  PedalDraft draft({required PedalType type, MultiEffectsMode? mode}) =>
      PedalDraft(
        name: 'Valeton GP-200',
        type: type,
        category: PedalCategory.multiEffects,
        multiEffectsMode: mode,
      );

  group('wording', () {
    test('every mode says what it is and what it means', () {
      // Named one by one on purpose: a mode added later should have to write its
      // own words rather than inherit an answer from this test.
      expect(MultiEffectsMode.stomp.label, 'Stomp mode');
      expect(MultiEffectsMode.scene.label, 'Scene mode');
      expect(MultiEffectsMode.stomp.tabLabel, 'Stomps');
      expect(MultiEffectsMode.scene.tabLabel, 'Patch');
      expect(MultiEffectsMode.stomp.addComponentLabel, 'Add stomp');
      expect(MultiEffectsMode.scene.addComponentLabel, 'Add pedal');
      expect(MultiEffectsMode.values, hasLength(2));
    });

    test('a stomp is described as one pedal', () {
      expect(MultiEffectsMode.stomp.description, contains('one pedal'));
      expect(MultiEffectsMode.scene.description, contains('patch'));
    });
  });

  group('validation', () {
    test('a multi-effects unit has to say which mode it is used in', () {
      expect(
        PedalValidator.draft(
          draft(type: PedalType.multiEffects),
          now: DateTime.utc(2026, 8, 20),
        ),
        'Pick whether this unit is used in stomp mode or scene mode.',
      );
    });

    test('and is accepted once it does', () {
      expect(
        PedalValidator.draft(
          draft(type: PedalType.multiEffects, mode: MultiEffectsMode.scene),
          now: DateTime.utc(2026, 8, 20),
        ),
        isNull,
      );
    });

    test('nothing else may carry a mode', () {
      expect(
        PedalValidator.multiEffectsMode(
          MultiEffectsMode.stomp,
          PedalType.analog,
        ),
        'Only a multi-effects unit has a stomp or scene mode.',
      );
    });

    test('a mode left behind by a changed type is dropped, not rejected', () {
      // The type field can be changed after the mode was picked, and the leftover
      // would otherwise say something about a pedal it no longer describes.
      final normalized = draft(
        type: PedalType.analog,
        mode: MultiEffectsMode.stomp,
      ).normalized();

      expect(normalized.multiEffectsMode, isNull);
      expect(
        PedalValidator.draft(normalized, now: DateTime.utc(2026, 8, 20)),
        isNull,
      );
    });
  });
}
