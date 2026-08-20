import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../configurations/providers/configuration_providers.dart';
import '../../patches/data/scene_label.dart';
import '../../patches/providers/patch_providers.dart';

/// Which of a pedal's sounds it was on when the snapshot was taken.
///
/// An ordinary pedal is asked about its configurations. A multi-effects unit has
/// none of its own, so it is asked which scene it was on instead - "Worship Clean
/// · Verse", the patch and the scene, since a scene name alone would not say.
///
/// "Not recorded" is a real answer and the one it starts on: a wah has no preset
/// worth naming, and a pedal whose settings nobody wrote down should not be given
/// some other day's readings by default.
class PedalSettingChoice extends ConsumerWidget {
  const PedalSettingChoice({
    required this.pedal,
    required this.position,
    required this.settingId,
    required this.onChanged,
    super.key,
  });

  final Pedal pedal;

  /// Zero-based place in the chain, shown one-based.
  final int position;

  /// The configuration chosen for an ordinary pedal, or the scene chosen for a
  /// unit. Which of the two [pedal] answers for.
  final int? settingId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnit = !pedal.category.hasOwnControls;
    final settings = isUnit ? _scenes(ref) : _configurations(ref);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<int?>(
        // A sound deleted while this screen sat open is no longer a choice, so
        // the field falls back to "Not recorded" rather than holding an id the
        // dropdown cannot show.
        initialValue: settings.any((one) => one.id == settingId)
            ? settingId
            : null,
        decoration: InputDecoration(
          labelText: '${position + 1}. ${pedal.name}',
          // Named after what is missing, so the way to fill the gap is obvious:
          // a unit is short of scenes, an ordinary pedal of configurations.
          helperText: settings.isNotEmpty
              ? null
              : isUnit
              ? 'This unit has no scenes to record'
              : 'This pedal has no configurations to record',
        ),
        items: [
          const DropdownMenuItem<int?>(child: Text('Not recorded')),
          for (final setting in settings)
            DropdownMenuItem<int?>(
              value: setting.id,
              child: Text(setting.name, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: settings.isEmpty ? null : onChanged,
      ),
    );
  }

  List<_Setting> _configurations(WidgetRef ref) {
    final configurations =
        ref.watch(configurationListProvider(pedal.id)).valueOrNull ?? const [];
    return [
      for (final configuration in configurations)
        (id: configuration.id, name: configuration.name),
    ];
  }

  List<_Setting> _scenes(WidgetRef ref) {
    final scenes =
        ref.watch(unitSceneListProvider(pedal.id)).valueOrNull ?? const [];
    return [
      for (final found in scenes)
        (
          id: found.scene.id,
          name: sceneLabel(found.patch.name, found.scene.name),
        ),
    ];
  }
}

/// One choice on offer, so the dropdown is built once rather than per kind.
typedef _Setting = ({int id, String name});
