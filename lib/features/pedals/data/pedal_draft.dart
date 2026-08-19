import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/pedal_status.dart';
import '../../../core/enums/pedal_type.dart';

/// Pedal data as the user entered it, before it becomes a database row.
///
/// Keeps Drift companions out of the UI: the form builds a draft, and the
/// repository turns it into a row and owns the timestamps.
class PedalDraft {
  const PedalDraft({
    required this.name,
    required this.type,
    required this.category,
    this.brand,
    this.status = PedalStatus.active,
    this.purchaseDate,
    this.notes,
    this.photoPath,
  });

  factory PedalDraft.fromPedal(Pedal pedal) {
    return PedalDraft(
      name: pedal.name,
      type: pedal.type,
      category: pedal.category,
      brand: pedal.brand,
      status: pedal.status,
      purchaseDate: pedal.purchaseDate,
      notes: pedal.notes,
      photoPath: pedal.photoPath,
    );
  }

  final String name;
  final PedalType type;
  final PedalCategory category;
  final String? brand;
  final PedalStatus status;
  final DateTime? purchaseDate;
  final String? notes;
  final String? photoPath;

  /// Trims text and turns blank optional fields into null.
  ///
  /// A cleared text field hands back an empty string, which would be stored as
  /// a present-but-empty brand rather than "not set" - and `brand` has a
  /// minimum length of one character, so the column would reject it outright.
  PedalDraft normalized() {
    return PedalDraft(
      name: name.trim(),
      type: type,
      category: category,
      brand: _blankToNull(brand),
      status: status,
      purchaseDate: purchaseDate,
      notes: _blankToNull(notes),
      photoPath: _blankToNull(photoPath),
    );
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
