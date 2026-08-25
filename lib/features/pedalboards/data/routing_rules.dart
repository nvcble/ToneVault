import '../../../core/database/app_database.dart';
import '../../../core/enums/signal_block_type.dart';
import 'signal_graph.dart';

/// Why one block cannot be cabled to another.
///
/// `SignalGraph` already refuses the shapes a chain cannot have - a block feeding
/// itself, a cable already run, a loop - and knows nothing about what the blocks
/// are. These are the rules that need the block types: an output is the end of the
/// rig, and an input is the start of it, so a cable at the wrong end of either is
/// not a routing mistake but a statement about the signal that is not true.
///
/// A `String?` per rule, worded for the user, so the sheet that offers a cable and
/// the repository that writes it refuse the same things in the same words.
abstract final class RoutingRules {
  /// Why [source] cannot feed [target] on the rig [graph] describes, or null if
  /// it can.
  static String? refusalFor({
    required SignalBlock source,
    required SignalBlock target,
    required SignalGraph graph,
  }) {
    return leaving(source.blockType) ??
        arriving(target.blockType) ??
        graph.refusalFor(source: source.id, target: target.id);
  }

  /// Why nothing can be cabled out of a block of this type.
  static String? leaving(SignalBlockType type) => switch (type) {
    SignalBlockType.output =>
      'Signal leaves the rig at an output, so nothing on the rig follows it.',
    // The next thing that happens to it is an amplifier or a rack unit the app
    // has never seen. What brings it back is the return this is paired with.
    SignalBlockType.send =>
      'A send is where signal leaves the rig, so pair it with a return rather '
          'than cabling it on.',
    _ => null,
  };

  /// Why nothing can be cabled into a block of this type.
  static String? arriving(SignalBlockType type) => switch (type) {
    SignalBlockType.input =>
      'An input is where signal starts, so nothing on the rig feeds it.',
    SignalBlockType.fxReturn =>
      'A return brings signal back from outside the rig, so nothing on the rig '
          'feeds it.',
    _ => null,
  };
}
