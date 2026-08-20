import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/multi_effects_mode.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../configurations/widgets/configuration_list_view.dart';
import 'component_pedal_list.dart';

/// What a multi-effects unit holds, which depends on how it is used.
///
/// In stomp mode the unit is a floor of pedals, so that is all this shows. In
/// scene mode the unit is one patch: the pedals on it, and a scene for each
/// sound they make together. Both halves are the lists an ordinary pedal already
/// uses, picked between rather than rebuilt.
class MultiEffectsView extends StatefulWidget {
  const MultiEffectsView({
    required this.pedalId,
    required this.mode,
    super.key,
  });

  final int pedalId;

  /// Null until the unit says how it is organised, which is the one thing that
  /// has to be answered before any of this can be shown.
  final MultiEffectsMode? mode;

  @override
  State<MultiEffectsView> createState() => _MultiEffectsViewState();
}

class _MultiEffectsViewState extends State<MultiEffectsView> {
  /// Scene mode has two lists to show; the pedals come first because a scene has
  /// nothing to set until they exist.
  bool _showingScenes = false;

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    if (mode == null) {
      return _PickModeFirst(pedalId: widget.pedalId);
    }

    final components = ComponentPedalList(
      hostPedalId: widget.pedalId,
      addLabel: mode.addComponentLabel,
      emptyMessage: mode.emptyComponentsMessage,
    );

    if (mode == MultiEffectsMode.stomp) {
      return components;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: false,
                label: Text(mode.componentsLabel),
              ),
              const ButtonSegment<bool>(value: true, label: Text('Scenes')),
            ],
            selected: {_showingScenes},
            onSelectionChanged: (selection) =>
                setState(() => _showingScenes = selection.single),
          ),
        ),
        // The scenes of a patch are the unit's own configurations: one saved set
        // of positions across every pedal on the patch.
        Expanded(
          child: _showingScenes
              ? ConfigurationListView(pedalId: widget.pedalId)
              : components,
        ),
      ],
    );
  }
}

/// Shown while the unit has no mode, which is the state a unit added before this
/// existed is in.
class _PickModeFirst extends StatelessWidget {
  const _PickModeFirst({required this.pedalId});

  final int pedalId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EmptyState(
          icon: Icons.tune,
          title: 'Say how this unit is used',
          message:
              'A unit in stomp mode is a floor of pedals. One in scene mode is '
              'a patch of pedals with a scene for each sound. Pick a mode and '
              'what belongs here shows up.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: FilledButton.icon(
            onPressed: () => context.go(Routes.pedalEdit(pedalId)),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Pick a mode'),
          ),
        ),
      ],
    );
  }
}
