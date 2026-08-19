/// How a single control on a pedal is edited and displayed.
///
/// Stored control values always live inside their own control's
/// `[minValue, maxValue]` domain. That is the one storage invariant in the app:
/// a percentage control stores 70 for "70", while a clock control uses a
/// normalized 0..1 domain that `ClockValue` maps onto a clock face. Comparing
/// two controls of different types therefore only needs their domain, not a
/// per-type special case.
enum ControlType {
  clock,
  percentage,
  numeric,
  toggle,
  selection;

  String get label => switch (this) {
    ControlType.clock => 'Clock knob',
    ControlType.percentage => 'Percentage',
    ControlType.numeric => 'Numeric',
    ControlType.toggle => 'Toggle',
    ControlType.selection => 'Selection',
  };

  /// Domain a newly created control of this type starts with. The user can
  /// widen or narrow it afterwards, except for [clock], which is fixed to the
  /// normalized range the clock mapping expects.
  ({double min, double max}) get defaultDomain => switch (this) {
    ControlType.clock => (min: 0, max: 1),
    ControlType.percentage => (min: 0, max: 100),
    ControlType.numeric => (min: 0, max: 10),
    ControlType.toggle => (min: 0, max: 1),
    ControlType.selection => (min: 0, max: 1),
  };

  /// Increment a control of this type snaps to, or null when continuous.
  double? get defaultStep => switch (this) {
    // 20 steps across the normalized range is one step per half hour on the
    // 7:00-5:00 sweep, which is the finest position readable off a real knob.
    ControlType.clock => 0.05,
    ControlType.percentage => 1,
    ControlType.numeric => null,
    ControlType.toggle => 1,
    ControlType.selection => 1,
  };

  /// Whether the domain is fixed by the control type rather than user-editable.
  bool get hasFixedDomain =>
      this == ControlType.clock || this == ControlType.toggle;
}
