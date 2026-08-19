import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/configurations/data/configuration_defaults.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';

/// What a configuration starts out as, before any of it reaches the database.
void main() {
  PedalControl control({
    required int id,
    required String name,
    double? defaultValue,
  }) {
    return PedalControl(
      id: id,
      pedalId: 1,
      name: name,
      controlType: ControlType.clock,
      minValue: 0,
      maxValue: 1,
      defaultValue: defaultValue,
      displayOrder: id,
    );
  }

  group('normalized', () {
    test('trims the name and the notes', () {
      final draft = const ConfigurationDraft(
        name: '  Worship Lead  ',
        notes: '  Bridge only  ',
      ).normalized();

      expect(draft.name, 'Worship Lead');
      expect(draft.notes, 'Bridge only');
    });

    test('drops notes that are only whitespace', () {
      final draft = const ConfigurationDraft(
        name: 'Clean',
        notes: '   ',
      ).normalized();

      expect(draft.notes, isNull);
    });

    test('keeps the starting positions as they are', () {
      final draft = const ConfigurationDraft(
        name: 'Clean',
        values: {3: 0.75},
      ).normalized();

      // Positions are numbers in a control's own domain; there is nothing to
      // tidy about them.
      expect(draft.values, {3: 0.75});
    });
  });

  group('fromConfiguration', () {
    test('carries the name and notes of an existing configuration', () {
      final draft = ConfigurationDraft.fromConfiguration(
        Configuration(
          id: 5,
          pedalId: 1,
          name: 'Worship Lead',
          notes: 'Bridge only',
          createdAt: DateTime.utc(2026, 8, 19),
          updatedAt: DateTime.utc(2026, 8, 19),
        ),
      );

      expect(draft.name, 'Worship Lead');
      expect(draft.notes, 'Bridge only');
      // The positions it holds are edited one control at a time, so a draft of
      // an existing configuration never carries them.
      expect(draft.values, isEmpty);
    });
  });

  group('configurationDefaults', () {
    test('starts a control at the default its definition declares', () {
      final defaults = configurationDefaults([
        control(id: 1, name: 'Volume', defaultValue: 0.5),
        control(id: 2, name: 'Tone', defaultValue: 0.25),
      ]);

      expect(defaults, {1: 0.5, 2: 0.25});
    });

    test('leaves a control with no default unset rather than guessing', () {
      final defaults = configurationDefaults([
        control(id: 1, name: 'Volume', defaultValue: 0.5),
        control(id: 2, name: 'Tone'),
      ]);

      // A configuration records where the pedal actually was, so a position
      // nobody stated is absent rather than invented.
      expect(defaults, {1: 0.5});
    });
  });
}
