import 'package:flutter/material.dart';

import 'component_pedal_list.dart';

/// What a multi-effects unit holds, in place of the configurations an ordinary
/// pedal keeps.
///
/// The pedals inside the unit are entered once and belong to the unit; a scene of
/// one of its patches then picks from them. Each is an ordinary pedal row, so the
/// list is the one the rest of the app already uses.
class MultiEffectsView extends StatelessWidget {
  const MultiEffectsView({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context) {
    return ComponentPedalList(
      hostPedalId: pedalId,
      addLabel: 'Add pedal',
      emptyMessage:
          'Add the pedals this unit holds. A scene of a patch then says which '
          'of them it uses and where their controls sit.',
    );
  }
}

// Kept for tracking: this view used to branch on a stomp/scene mode and, in
// scene mode, offer the unit's own configurations as its scenes. Both went with
// the mode: a unit's sounds are patches, a patch's are scenes, and a scene's are
// the pedals in it, so a configuration on the unit was never the right shape.
//
//   final MultiEffectsMode? mode;
//   if (mode == null) return _PickModeFirst(pedalId: widget.pedalId);
//   if (mode == MultiEffectsMode.stomp) return components;
//   SegmentedButton<bool>(segments: [...mode.componentsLabel, 'Scenes'])
//   _showingScenes ? ConfigurationListView(pedalId: widget.pedalId) : components
