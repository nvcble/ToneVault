import 'package:drift/drift.dart';

import '../../enums/signal_connection_type.dart';
import 'pedalboards_table.dart';
import 'signal_blocks_table.dart';

/// One cable of a rig: which block feeds which.
///
/// A rig with no rows here runs straight through in [SignalBlocks.position]
/// order, which is every rig today and is why nothing has to be written to keep
/// a plain chain working. Storing the routing as edges instead of reading it off
/// the order is what leaves room for a split feeding two paths at once.
///
/// [pedalboardId] is kept alongside the two blocks so a rig's routing can be
/// read, watched and deleted without joining through them.
@TableIndex(name: 'idx_signal_connections_board', columns: {#pedalboardId})
class SignalConnections extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedalboardId =>
      integer().references(Pedalboards, #id, onDelete: KeyAction.cascade)();

  /// Cascade both ways: a cable to a block that is gone is not a cable, so
  /// removing a block takes its connections with it rather than refusing.
  ///
  /// Both ends name the same table, so each is named for the direction it looks
  /// in; without that drift cannot tell the two apart.
  @ReferenceName('outgoingConnections')
  IntColumn get sourceBlockId =>
      integer().references(SignalBlocks, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('incomingConnections')
  IntColumn get targetBlockId =>
      integer().references(SignalBlocks, #id, onDelete: KeyAction.cascade)();

  TextColumn get connectionType => textEnum<SignalConnectionType>()();

  /// One cable per pair of ends: running a second one between the same two
  /// blocks would say nothing the first does not.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceBlockId, targetBlockId},
  ];
}
