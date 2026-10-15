/// The parameters a screen or a device profile names directly, spelled once
/// here so the two cannot drift apart over it.
///
/// Everything else is reached by whatever name its device profile gives it -
/// a knob is a row in a list, not a button somebody designed. [scene] is the
/// exception that has a control of its own, on the device control page;
/// `buildParameterMessage` looks every one of these up by exactly these
/// strings.
abstract final class MidiParameterNames {
  static const String scene = 'Scene';

  /// Listed by the MG-30 profile with no CC of its own, and reachable only if
  /// the user maps one by hand - see `nuxMg30V5AssignableParameters`.
  static const String tapTempo = 'Tap Tempo';
  static const String switchA = 'Switch A';
  static const String switchB = 'Switch B';
}
