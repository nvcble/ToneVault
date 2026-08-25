import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/enums/signal_source.dart';

/// Rows of a rig's chain, built by hand.
///
/// The widgets are given a chain rather than a database, so every test that draws
/// one would otherwise spell out two full rows of columns it does not care about.
final DateTime chainMoment = DateTime.utc(2026, 8, 19, 12);

Pedal chainPedal(
  int id,
  String name, {
  String? brand,
  PedalCategory category = PedalCategory.overdrive,
  PedalStatus status = PedalStatus.active,
}) {
  return Pedal(
    id: id,
    name: name,
    brand: brand,
    type: PedalType.analog,
    category: category,
    status: status,
    createdAt: chainMoment,
    updatedAt: chainMoment,
  );
}

/// One cable of a chain, from [source] to [target].
SignalConnection chainCable(
  int id, {
  required int source,
  required int target,
  int pedalboardId = 4,
  SignalConnectionType type = SignalConnectionType.series,
}) {
  return SignalConnection(
    id: id,
    pedalboardId: pedalboardId,
    sourceBlockId: source,
    targetBlockId: target,
    connectionType: type,
  );
}

/// What one edge of a rig reaches, and what it is paired with.
SignalEndpoint chainEndpoint(
  int id, {
  required int blockId,
  SignalDestination? destination,
  SignalSource? source,
  int? pairedBlockId,
  String? gear,
  String? notes,
}) {
  return SignalEndpoint(
    id: id,
    blockId: blockId,
    destination: destination,
    source: source,
    pairedBlockId: pairedBlockId,
    gear: gear,
    notes: notes,
  );
}

/// One block of a chain, holding [pedal] or nothing at all.
ChainBlock chainBlock(
  int id, {
  int pedalboardId = 4,
  SignalBlockType type = SignalBlockType.overdrive,
  int position = 0,
  String? label,
  bool isEnabled = true,
  String? notes,
  Pedal? pedal,
}) {
  return (
    block: SignalBlock(
      id: id,
      pedalboardId: pedalboardId,
      pedalId: pedal?.id,
      blockType: type,
      label: label,
      position: position,
      isEnabled: isEnabled,
      notes: notes,
    ),
    pedal: pedal,
  );
}
