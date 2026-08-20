import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../patches/widgets/patch_list_view.dart';
import 'component_pedal_list.dart';

/// What a multi-effects unit holds, in place of the configurations an ordinary
/// pedal keeps.
///
/// Two lists behind one tab, because they answer two halves of the same
/// question: the unit's pedals are entered once and belong to it, and a scene of
/// one of its patches then picks from them. Patches come first - the pedals are
/// gear the user enters once and rarely returns to.
class MultiEffectsView extends StatefulWidget {
  const MultiEffectsView({required this.pedalId, super.key});

  final int pedalId;

  @override
  State<MultiEffectsView> createState() => _MultiEffectsViewState();
}

class _MultiEffectsViewState extends State<MultiEffectsView> {
  bool _showingPedals = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: false, label: Text('Patches')),
              ButtonSegment<bool>(value: true, label: Text('Pedals')),
            ],
            selected: {_showingPedals},
            onSelectionChanged: (selection) =>
                setState(() => _showingPedals = selection.first),
          ),
        ),
        Expanded(
          child: _showingPedals
              ? ComponentPedalList(
                  hostPedalId: widget.pedalId,
                  addLabel: 'Add pedal',
                  emptyMessage:
                      'Add the pedals this unit holds. A scene of a patch then '
                      'says which of them it uses and where their controls sit.',
                )
              : PatchListView(pedalId: widget.pedalId),
        ),
      ],
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
