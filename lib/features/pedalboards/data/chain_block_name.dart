import '../../../core/database/daos/signal_chain_dao.dart';

/// What one block is called on screen.
///
/// What the user named it, else what is in it, else what it is for. Shared so a
/// block is called the same thing on its card, in its menu and in the list of
/// cables it feeds, instead of three files agreeing by accident.
extension ChainBlockName on ChainBlock {
  String get displayName => block.label ?? pedal?.name ?? block.blockType.label;
}
