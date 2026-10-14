/// The parameters the app has a dedicated control for, named once here so a
/// screen and a device profile cannot drift apart over a spelling.
///
/// Everything else is reached by whatever name its device profile gives it -
/// a knob is a row in a list, not a button somebody designed. These four are
/// the exceptions: each has a button of its own on the control page, and
/// `buildParameterMessage` looks them up by exactly these strings.
abstract final class MidiParameterNames {
  static const String scene = 'Scene';
  static const String tapTempo = 'Tap Tempo';
  static const String switchA = 'Switch A';
  static const String switchB = 'Switch B';

  /// The two assignable footswitches, in the order the unit prints them.
  static const List<String> switches = [switchA, switchB];
}

/// What a momentary control sends when it fires.
///
/// 127 rather than 1: a device reading a CC as a footswitch takes anything
/// over 63 as "pressed", and 127 is the value every pedalboard controller
/// sends for it. [ccOff] is its other half, for a control that latches.
const int ccOn = 127;
const int ccOff = 0;
