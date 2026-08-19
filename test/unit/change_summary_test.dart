import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/history/data/change_summary.dart';

/// How a stored entry reads on the timeline.
void main() {
  final volume = PedalControl(
    id: 3,
    pedalId: 7,
    name: 'Volume',
    controlType: ControlType.clock,
    minValue: 0,
    maxValue: 1,
    displayOrder: 0,
  );

  ChangeLog entry({
    required ChangeType changeType,
    String? configurationName,
    String? controlName,
    double? oldValue,
    double? newValue,
    String? oldText,
    String? newText,
    String? reason,
  }) {
    return ChangeLog(
      id: 1,
      pedalId: 7,
      configurationName: configurationName,
      controlName: controlName,
      changeType: changeType,
      oldValue: oldValue,
      newValue: newValue,
      oldText: oldText,
      newText: newText,
      reason: reason,
      createdAt: DateTime(2026, 8, 19, 14, 5),
    );
  }

  ChangeLog move({double? oldValue, double? newValue}) => entry(
    changeType: ChangeType.controlValueChanged,
    configurationName: 'Worship Lead',
    controlName: 'Volume',
    oldValue: oldValue,
    newValue: newValue,
  );

  group('changeHeadline', () {
    test('reads a knob move in the notation of its own control', () {
      final headline = changeHeadline(
        move(oldValue: 0.25, newValue: 0.75),
        control: volume,
      );

      expect(headline, 'Volume moved from 9:30 to 2:30');
    });

    test('reads the bare number once the control is gone', () {
      // Nothing is left to say the number means a clock position, so the log
      // shows what it actually stored rather than guessing.
      expect(
        changeHeadline(move(oldValue: 0.25, newValue: 0.75)),
        'Volume moved from 0.25 to 0.75',
      );
    });

    test('reads a first position as being set', () {
      expect(
        changeHeadline(move(newValue: 0.5), control: volume),
        'Volume set to 12:00',
      );
    });

    test('keeps where a cleared control used to sit', () {
      expect(
        changeHeadline(move(oldValue: 0.5), control: volume),
        'Volume cleared, was 12:00',
      );
    });

    test('reads the configuration events by name', () {
      expect(
        changeHeadline(
          entry(
            changeType: ChangeType.configurationCreated,
            configurationName: 'Worship Lead',
          ),
        ),
        'Worship Lead created',
      );
      expect(
        changeHeadline(
          entry(
            changeType: ChangeType.configurationRenamed,
            configurationName: 'Lead',
            oldText: 'Worship Lead',
            newText: 'Lead',
          ),
        ),
        'Worship Lead renamed to Lead',
      );
      expect(
        changeHeadline(
          entry(
            changeType: ChangeType.configurationDeleted,
            configurationName: 'Worship Lead',
          ),
        ),
        'Worship Lead deleted',
      );
    });

    test('reads the control and pedal events', () {
      expect(
        changeHeadline(
          entry(changeType: ChangeType.controlAdded, controlName: 'Volume'),
        ),
        'Volume added',
      );
      expect(
        changeHeadline(
          entry(changeType: ChangeType.controlRemoved, controlName: 'Volume'),
        ),
        'Volume removed',
      );
      expect(
        changeHeadline(
          entry(
            changeType: ChangeType.pedalStatusChanged,
            oldText: 'Active',
            newText: 'Backup',
          ),
        ),
        'Moved from Active to Backup',
      );
      expect(
        changeHeadline(
          entry(changeType: ChangeType.pedalReplaced, newText: 'NUX MG-30'),
        ),
        'Replaced by NUX MG-30',
      );
    });

    test('still says something about an entry that lost its name', () {
      // Every column but the type is nullable, and a row that reads as "null"
      // would be worse than useless on the timeline.
      expect(
        changeHeadline(entry(changeType: ChangeType.controlRemoved)),
        'A control removed',
      );
    });
  });

  group('changeContext', () {
    test('names the pedal, the configuration and the moment', () {
      expect(
        changeContext(move(newValue: 0.5), pedalName: 'Caline PureSky'),
        'Caline PureSky · Worship Lead · 2026-08-19 14:05',
      );
    });

    test('leaves out a pedal that the screen already names', () {
      expect(
        changeContext(move(newValue: 0.5)),
        'Worship Lead · 2026-08-19 14:05',
      );
    });

    test('does not repeat a configuration the headline already names', () {
      expect(
        changeContext(
          entry(
            changeType: ChangeType.configurationCreated,
            configurationName: 'Worship Lead',
          ),
        ),
        '2026-08-19 14:05',
      );
    });
  });
}
