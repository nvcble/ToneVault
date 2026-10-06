import 'package:drift/drift.dart';

import 'patches_table.dart';

/// The exact MG-30 V5 bytes one library patch was decoded from.
///
/// Kept because the decoder is young: `Mg30V5SceneLayout` reads the patch name,
/// the amp model and the signal chain today, and the rest of a scene's 142 bytes
/// are understood well enough to store but not to interpret. Holding the record
/// whole means a later decoder reads more out of patches already imported,
/// without the device or the export file being needed again - and a write can
/// put back the bytes it came from with only the fields the user changed over
/// them.
///
/// One row per patch, replaced on re-import: this is what the patch currently
/// is, not a history of what it was. [source] says where the bytes came from,
/// since a file export and a device read are not equally direct evidence.
@TableIndex(name: 'idx_mg30_patch_payloads_slot', columns: {#slot})
@DataClassName('Mg30PatchPayload')
class Mg30PatchPayloads extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patchId => integer()
      .references(Patches, #id, onDelete: KeyAction.cascade)
      .unique()();

  /// 0-127, as the device numbers its slots.
  IntColumn get slot => integer()();

  /// `quicktone_file` for a `.mg30patch` export, `device_sysex` for bytes read
  /// off the unit - never conflated, because only one of them is the device
  /// answering.
  TextColumn get source => text().withLength(min: 1, max: 20)();

  /// The firmware this is believed to be from, as a label rather than a parsed
  /// version: null when nothing identified the device.
  TextColumn get firmwareLabel => text().nullable()();

  BlobColumn get rawRecord => blob()();

  DateTimeColumn get importedAt => dateTime()();
}
