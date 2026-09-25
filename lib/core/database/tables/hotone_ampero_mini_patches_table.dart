import 'package:drift/drift.dart';

/// One Hotone Ampero Mini patch, as far as it has been synchronized -
/// independent of ToneVault's physical pedal inventory (`Pedals`/`Patches`):
/// this is device data, not gear the user logged themselves.
///
/// [rawSysEx] is kept even when [decodedJson] is null or partial, so a future
/// decoder improvement can re-run against bytes already read without
/// reconnecting to the device - see the diagnostic-capture precedent in
/// `midi_preset_captures_table.dart`, which this table deliberately does not
/// extend or share: that table is keyed by a linked pedal, this one is not.
@DataClassName('HotoneAmperoMiniPatch')
class HotoneAmperoMiniPatches extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Always `hotone_ampero_mini` today, but named rather than assumed, the
  /// same way `MidiPresetCaptures.deviceProfileId` is.
  TextColumn get deviceProfileId => text()();

  /// The pedal's own zero-based slot index (0-197): 0-98 are the user patches
  /// P01-1..P33-3, 99-197 the factory ones F01-1..F33-3. Not a Program Change
  /// value - only the first 128 of these can be expressed as one.
  IntColumn get patchNumber => integer()();

  /// The decoder's best-effort name, or null until a sync has actually
  /// decoded one. Only ever written from bytes the device sent.
  TextColumn get name => text().nullable()();

  /// The exact wire bytes of the last successful read, or null before any
  /// sync has happened for this slot.
  BlobColumn get rawSysEx => blob().nullable()();

  /// Whatever else the decoder produced, as JSON - kept as one column rather
  /// than a table per field, since which fields exist depends on how much of
  /// the protocol is understood when this row was last written.
  TextColumn get decodedJson => text().nullable()();

  /// What this patch's device reported for firmware/protocol, if anything -
  /// see the firmware-awareness requirement: behavior confirmed on one
  /// firmware is not assumed to hold on another.
  TextColumn get firmwareVersion => text().nullable()();
  TextColumn get protocolVersion => text().nullable()();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// True once a local edit has diverged from [lastSyncedAt]'s data and has
  /// not yet been sent back to the device - distinct from [syncState], which
  /// is about the device relationship, not the edit itself.
  BoolColumn get locallyModified =>
      boolean().withDefault(const Constant(false))();

  /// One of: notSynced, synced, modifiedLocally, writePending, writeFailed,
  /// verified - see `HotoneAmperoMiniSyncState`. Stored as text rather than a
  /// Drift enum column so a future state can be added without a migration.
  TextColumn get syncState => text().withDefault(const Constant('notSynced'))();

  /// Reserved, and currently unwritten.
  ///
  /// Added in v24 for hand-typed slot labels, which were then dropped: patch
  /// names are to come from the pedal, not from the user. Kept because v24 has
  /// already been applied, and an unused nullable column is cheaper than a
  /// schema downgrade. If it is ever used again it must stay separate from
  /// [name], which means "decoded from bytes the device sent".
  ///
  /// Declared last on purpose, and it must stay last: v24 adds it with ALTER
  /// TABLE ADD COLUMN, which appends, so any earlier position here would make
  /// an upgraded phone's column order differ from a fresh install's.
  TextColumn get localLabel => text().nullable()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {deviceProfileId, patchNumber},
  ];
}
