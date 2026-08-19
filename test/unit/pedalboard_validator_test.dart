import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_validator.dart';

/// What a rig has to be named, and what a draft looks like once tidied up. Pure
/// rules, so no database.
void main() {
  group('name', () {
    test('accepts an ordinary rig name', () {
      expect(PedalboardValidator.name('Hybrid Worship Rig'), isNull);
    });

    test('asks for a name when there is nothing but spaces', () {
      expect(PedalboardValidator.name('   '), 'Enter a rig name.');
      expect(PedalboardValidator.name(null), 'Enter a rig name.');
    });

    test('holds to the length the column allows', () {
      final longest = 'r' * PedalboardValidator.nameMaxLength;

      expect(PedalboardValidator.name(longest), isNull);
      expect(
        PedalboardValidator.name('$longest!'),
        'Use at most ${PedalboardValidator.nameMaxLength} characters.',
      );
    });

    test('measures the trimmed name, not the typing around it', () {
      expect(PedalboardValidator.name('  Home Practice  '), isNull);
    });
  });

  group('normalized', () {
    test('trims the name and drops a blank description', () {
      final draft = const PedalboardDraft(
        name: '  Home Practice ',
        description: '   ',
      ).normalized();

      expect(draft.name, 'Home Practice');
      // Blank becomes null, so nothing is stored as an empty description.
      expect(draft.description, isNull);
    });

    test('keeps a description that says something', () {
      final draft = const PedalboardDraft(
        name: 'Home Practice',
        description: ' amp on the desk ',
      ).normalized();

      expect(draft.description, 'amp on the desk');
    });
  });
}
