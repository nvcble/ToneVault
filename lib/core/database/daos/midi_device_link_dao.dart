import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_device_links_table.dart';

part 'midi_device_link_dao.g.dart';

/// Typed queries over `midi_device_links`.
///
/// Seeding the linked pedal and its blocks belongs to
/// `MidiDeviceLinkRepository`; this class only reads and writes the link row
/// itself.
@DriftAccessor(tables: [MidiDeviceLinks])
class MidiDeviceLinkDao extends DatabaseAccessor<AppDatabase>
    with _$MidiDeviceLinkDaoMixin {
  MidiDeviceLinkDao(super.attachedDatabase);

  /// The first pedal linked to [deviceProfileId], or null when none is.
  ///
  /// "First" rather than "the": nothing yet stops two pedals linking to the
  /// same profile, for a player who owns two of the same unit, but nothing
  /// in the app asks for more than one either.
  Stream<MidiDeviceLink?> watchLink(String deviceProfileId) {
    return (select(midiDeviceLinks)
          ..where((row) => row.deviceProfileId.equals(deviceProfileId))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<MidiDeviceLink?> findLink(String deviceProfileId) {
    return (select(midiDeviceLinks)
          ..where((row) => row.deviceProfileId.equals(deviceProfileId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertLink(MidiDeviceLinksCompanion link) =>
      into(midiDeviceLinks).insert(link);

  /// Returns whether a row existed to remove.
  Future<bool> deleteLink(int pedalId) async {
    final deletedRows = await (delete(
      midiDeviceLinks,
    )..where((row) => row.pedalId.equals(pedalId))).go();
    return deletedRows > 0;
  }
}
