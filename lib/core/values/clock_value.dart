/// A position on an analog knob, read the way players describe one: fully
/// counter-clockwise is 7:00, straight up is 12:00, fully clockwise is 5:00.
///
/// Only the normalized `0..1` value is ever stored; the clock reading is
/// presentation. The mapping is linear across a 600 minute sweep, so 0.25 reads
/// as 9:30.
class ClockValue {
  const ClockValue._(this.normalized);

  /// Clamps [value] into the sweep.
  ///
  /// A stored value can only fall outside `0..1` through a hand-edited
  /// database, and a knob pinned at its end stop reads better than a crash.
  factory ClockValue.fromNormalized(double value) {
    if (value.isNaN) {
      throw ArgumentError.value(value, 'value', 'is not a number');
    }
    return ClockValue._(value.clamp(0, 1));
  }

  /// The nearest position that can actually be read off a knob.
  factory ClockValue.snapped(double value) {
    final steps =
        (ClockValue.fromNormalized(value)._minutesIntoSweep / snapMinutes)
            .round();
    return ClockValue._(steps * snapMinutes / sweepMinutes);
  }

  /// The value for a clock reading, such as `hour: 9, minute: 30`.
  ///
  /// [hour] is a clock face hour of 1 to 12, so 5:00 is the fully clockwise end
  /// and 6:00 does not exist on the sweep.
  factory ClockValue.at({required int hour, required int minute}) {
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      throw ArgumentError('$hour:$minute is not a clock reading');
    }

    // Afternoon hours continue past 12:00, so 1:00 is later in the sweep than
    // 12:00 rather than six hours earlier.
    final minuteOfDay = (hour >= 7 ? hour : hour + 12) * 60 + minute;
    if (minuteOfDay < _startMinuteOfDay ||
        minuteOfDay > _startMinuteOfDay + sweepMinutes) {
      throw ArgumentError('$hour:$minute is outside the 7:00 to 5:00 sweep');
    }

    return ClockValue._((minuteOfDay - _startMinuteOfDay) / sweepMinutes);
  }

  /// Minutes from one end stop to the other, going forwards through 12:00.
  static const int sweepMinutes = 600;

  /// Half an hour is the finest position readable off a real knob. It is also
  /// what [ControlType.clock]'s default step of 0.05 works out to, and
  /// clock_value_test asserts the two stay in agreement.
  static const int snapMinutes = 30;

  /// 7:00, the counter-clockwise end stop.
  static const int _startMinuteOfDay = 7 * 60;

  /// Always inside `0..1`.
  final double normalized;

  double get _minutesIntoSweep => normalized * sweepMinutes;

  int get _minuteOfDay => (_startMinuteOfDay + _minutesIntoSweep).round();

  /// The hour as it is read on a clock face, 1 to 12.
  int get hour => ((_minuteOfDay ~/ 60 - 1) % 12) + 1;

  int get minute => _minuteOfDay % 60;

  /// Clock notation, such as `9:30`.
  String get label => '$hour:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ClockValue && other.normalized == normalized;

  @override
  int get hashCode => normalized.hashCode;

  @override
  String toString() => 'ClockValue($label)';
}
