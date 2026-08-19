import '../../../core/database/app_database.dart';

/// A configuration's own details, before it becomes a database row.
///
/// The values a configuration holds are not part of this: they are stored one
/// control at a time, so naming a configuration and setting a knob on it are
/// separate edits. [ConfigurationDraft.values] carries only the positions a
/// brand new configuration starts out with.
class ConfigurationDraft {
  const ConfigurationDraft({
    required this.name,
    this.notes,
    this.values = const {},
  });

  factory ConfigurationDraft.fromConfiguration(Configuration configuration) {
    return ConfigurationDraft(
      name: configuration.name,
      notes: configuration.notes,
    );
  }

  final String name;
  final String? notes;

  /// Control id to stored value, each in that control's own domain.
  ///
  /// Only read when the configuration is created.
  final Map<int, double> values;

  /// Trims text and turns blank optional text into null, so a name entered as
  /// "  Worship Lead " does not become a second configuration alongside
  /// "Worship Lead".
  ConfigurationDraft normalized() {
    final trimmedNotes = notes?.trim();

    return ConfigurationDraft(
      name: name.trim(),
      notes: trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
      values: values,
    );
  }
}
