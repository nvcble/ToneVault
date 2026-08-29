import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';
import '../../../shared/widgets/section_label.dart';
import '../widgets/level_tile.dart';

/// One path, as its four levels.
///
/// The levels are the enum rather than rows from the database. They are the shape
/// of the path and not a thing the user or a course file can add to, so there is
/// nothing to read: a course arrives already saying which of the four it belongs
/// to. What is inside a level is read from the database by the level screen.
///
/// What the levels *have* on them is read, though. Each one carries how far through
/// it the player is, which is the one thing this screen can say that the enum
/// cannot: it is what turns a list of four names into a place to pick up from.
class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({required this.path, super.key});

  final LearningPath path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(path.label)),
      body: ListView(
        children: [
          const SectionLabel('Levels'),
          for (final level in SkillLevel.values)
            LevelTile(
              path: path,
              level: level,
              onTap: () => context.push(Routes.academyLevel(path, level)),
            ),
        ],
      ),
    );
  }
}
