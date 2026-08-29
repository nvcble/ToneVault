import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';
import '../data/lesson_tally.dart';
import '../providers/progress_providers.dart';
import 'tally_bar.dart';

/// One of the four levels of a path, with how far through it the player is.
///
/// Not a `NamedTile`: a level needs its progress under the line about it, and the
/// shared tile has one slot for a subtitle and one for buttons. Rather than widen
/// that for the one screen that wants it, this is the row that screen needs.
class LevelTile extends ConsumerWidget {
  const LevelTile({
    required this.path,
    required this.level,
    required this.onTap,
    super.key,
  });

  final LearningPath path;
  final SkillLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tally = ref.watch(levelTallyProvider((path: path, level: level)));

    return ListTile(
      title: Text(level.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(level.summary),
          TallyBar(tally: tally),
        ],
      ),
      // Never centred: a tile whose subtitle grew a bar would put the chevron
      // halfway down it.
      isThreeLine: tally != null && !tally.isEmpty,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
