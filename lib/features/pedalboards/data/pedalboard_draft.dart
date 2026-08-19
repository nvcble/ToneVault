import '../../../core/database/app_database.dart';

/// A rig's own details, before it becomes a database row.
///
/// The pedals on the rig are not part of this: they are added one at a time, so
/// naming a rig and building its signal chain are separate edits.
class PedalboardDraft {
  const PedalboardDraft({required this.name, this.description});

  factory PedalboardDraft.fromPedalboard(Pedalboard pedalboard) {
    return PedalboardDraft(
      name: pedalboard.name,
      description: pedalboard.description,
    );
  }

  final String name;
  final String? description;

  /// Trims text and turns blank optional text into null, so a rig entered as
  /// "  Home Practice " does not become a second rig alongside "Home Practice".
  PedalboardDraft normalized() {
    final trimmedDescription = description?.trim();

    return PedalboardDraft(
      name: name.trim(),
      description: trimmedDescription == null || trimmedDescription.isEmpty
          ? null
          : trimmedDescription,
    );
  }
}
