/// The most a stored label can be, which is what
/// `change_logs.configuration_name` holds.
const int sceneLabelMaxLength = 80;

/// What a scene is called away from its own patch: the patch and the scene
/// together.
///
/// Two patches on one unit may each have a "Verse", and the history is read a
/// unit at a time, so a scene's own name would not say which sound it was.
///
/// Clipped to [maxLength] because a patch name and a scene name are 80 characters
/// each: the two together overflow a column that neither of them would, and
/// losing the tail of a long name reads better than a refusal - the alternative
/// is a history entry the app declines to write over a label.
String sceneLabel(
  String patchName,
  String sceneName, {
  int maxLength = sceneLabelMaxLength,
}) {
  final label = '$patchName · $sceneName';
  if (label.length <= maxLength) {
    return label;
  }
  return '${label.substring(0, maxLength - 1).trimRight()}…';
}
