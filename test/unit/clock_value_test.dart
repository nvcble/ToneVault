import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/values/clock_value.dart';

void main() {
  group('reading a stored value', () {
    test('maps the ends and the middle of the sweep', () {
      expect(ClockValue.fromNormalized(0).label, '7:00');
      expect(ClockValue.fromNormalized(0.5).label, '12:00');
      expect(ClockValue.fromNormalized(1).label, '5:00');
    });

    test('is linear across the sweep', () {
      // The quarter positions are the ones a player actually calls out.
      expect(ClockValue.fromNormalized(0.25).label, '9:30');
      expect(ClockValue.fromNormalized(0.75).label, '2:30');
      expect(ClockValue.fromNormalized(0.1).label, '8:00');
      expect(ClockValue.fromNormalized(0.9).label, '4:00');
    });

    test('reads the hour on a clock face rather than a 24 hour clock', () {
      expect(ClockValue.fromNormalized(0.5).hour, 12);
      expect(ClockValue.fromNormalized(0.55).hour, 12);
      expect(ClockValue.fromNormalized(0.6).hour, 1);
      expect(ClockValue.fromNormalized(1).hour, 5);
    });

    test('pads the minutes so positions line up in a list', () {
      expect(ClockValue.fromNormalized(0.05).label, '7:30');
      expect(ClockValue.fromNormalized(0.55).label, '12:30');
    });

    test('pins a value from outside the sweep to the nearest end stop', () {
      expect(ClockValue.fromNormalized(-2).label, '7:00');
      expect(ClockValue.fromNormalized(11).label, '5:00');
    });

    test('refuses a value that is not a number', () {
      expect(
        () => ClockValue.fromNormalized(double.nan),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('entering a clock reading', () {
    test('round-trips through the stored value', () {
      expect(ClockValue.at(hour: 7, minute: 0).normalized, 0);
      expect(ClockValue.at(hour: 9, minute: 30).normalized, 0.25);
      expect(ClockValue.at(hour: 12, minute: 0).normalized, 0.5);
      expect(ClockValue.at(hour: 2, minute: 30).normalized, 0.75);
      expect(ClockValue.at(hour: 5, minute: 0).normalized, 1);
    });

    test('treats afternoon hours as later in the sweep, not earlier', () {
      final noon = ClockValue.at(hour: 12, minute: 0);
      final one = ClockValue.at(hour: 1, minute: 0);

      expect(one.normalized, greaterThan(noon.normalized));
    });

    test('rejects readings a knob cannot be in', () {
      // 6:00 is the gap between the two end stops.
      expect(() => ClockValue.at(hour: 6, minute: 0), throwsArgumentError);
      expect(() => ClockValue.at(hour: 5, minute: 30), throwsArgumentError);
      expect(() => ClockValue.at(hour: 6, minute: 59), throwsArgumentError);
      expect(() => ClockValue.at(hour: 0, minute: 0), throwsArgumentError);
      expect(() => ClockValue.at(hour: 13, minute: 0), throwsArgumentError);
      expect(() => ClockValue.at(hour: 9, minute: 60), throwsArgumentError);
    });
  });

  group('snapping', () {
    test('rounds to the nearest half hour', () {
      expect(ClockValue.snapped(0.26).label, '9:30');
      expect(ClockValue.snapped(0.27).label, '9:30');
      expect(ClockValue.snapped(0.28).label, '10:00');
      expect(ClockValue.snapped(0.999).label, '5:00');
    });

    test('leaves a value that is already on a position alone', () {
      final quarter = ClockValue.at(hour: 9, minute: 30);
      expect(ClockValue.snapped(quarter.normalized), quarter);
    });

    test('agrees with the step ControlType.clock hands out', () {
      // These two are declared apart, and a knob that snaps to one increment
      // while its slider steps by another would be maddening to use.
      expect(
        ClockValue.snapMinutes / ClockValue.sweepMinutes,
        ControlType.clock.defaultStep,
      );
      expect(ControlType.clock.defaultDomain, (min: 0.0, max: 1.0));
    });
  });
}
