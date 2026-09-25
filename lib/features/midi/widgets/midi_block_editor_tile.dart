import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../patches/providers/patch_providers.dart';

/// One block of the signal chain: on or off in this scene, and - only while
/// on - the knobs it holds.
///
/// Every slider here writes straight to the scene's stored value through the
/// same `SceneValueRepository` the Pedals tab's own scene screen uses. Only
/// the "Send to device" button on the editor screen actually sends anything
/// over MIDI - see section 11 of the MIDI module brief on representing
/// changes locally first.
class MidiBlockEditorTile extends ConsumerWidget {
  const MidiBlockEditorTile({
    required this.sceneId,
    required this.block,
    required this.isEnabled,
    required this.controls,
    required this.values,
    super.key,
  });

  final int sceneId;
  final Pedal block;
  final bool isEnabled;
  final List<PedalControl> controls;
  final Map<int, double> values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: Text(block.name),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) async {
          try {
            final repository = ref.read(scenePedalRepositoryProvider);
            if (value) {
              await repository.addPedal(sceneId: sceneId, pedalId: block.id);
            } else {
              await repository.removePedal(sceneId: sceneId, pedalId: block.id);
            }
          } catch (error) {
            if (context.mounted) showFailureSnackBar(context, error);
          }
        },
      ),
      children: isEnabled
          ? [
              for (final control in controls)
                _ControlValueSlider(
                  sceneId: sceneId,
                  control: control,
                  value:
                      values[control.id] ??
                      control.defaultValue ??
                      control.minValue,
                ),
            ]
          : const [],
    );
  }
}

class _ControlValueSlider extends ConsumerStatefulWidget {
  const _ControlValueSlider({
    required this.sceneId,
    required this.control,
    required this.value,
  });

  final int sceneId;
  final PedalControl control;
  final double value;

  @override
  ConsumerState<_ControlValueSlider> createState() =>
      _ControlValueSliderState();
}

class _ControlValueSliderState extends ConsumerState<_ControlValueSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(_ControlValueSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.control;
    final divisions = (control.maxValue - control.minValue).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(control.name)),
          Expanded(
            flex: 3,
            child: Slider(
              value: _value.clamp(control.minValue, control.maxValue),
              min: control.minValue,
              max: control.maxValue,
              divisions: divisions > 0 ? divisions : null,
              label: _value.round().toString(),
              onChanged: (value) => setState(() => _value = value),
              onChangeEnd: (value) async {
                try {
                  await ref
                      .read(sceneValueRepositoryProvider)
                      .setValue(
                        sceneId: widget.sceneId,
                        controlId: control.id,
                        value: value,
                      );
                } catch (error) {
                  if (context.mounted) showFailureSnackBar(context, error);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
