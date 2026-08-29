import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/skill_level.dart';
import '../../../shared/widgets/named_tile.dart';
import '../../../shared/widgets/section_label.dart';
import '../data/ear_drill.dart';

/// The drills, grouped by what they ask of a player.
///
/// Every one of them is here from the moment the app is installed and none of them can
/// run out, so there is nothing on this screen to create, download or set up - which is
/// the whole point of the feature. A player picks the thing they cannot hear yet and
/// starts.
class EarTrainingScreen extends StatelessWidget {
  const EarTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ear training')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          for (final level in SkillLevel.values) ...[
            SectionLabel(level.label),
            for (final drill in EarDrill.forLevel(level))
              NamedTile(
                name: drill.label,
                subtitle: drill.summary,
                onTap: () => context.push(Routes.academyEarDrill(drill)),
              ),
          ],
        ],
      ),
    );
  }
}
