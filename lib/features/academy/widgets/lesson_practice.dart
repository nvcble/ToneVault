import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/formatting/app_date_format.dart';
import '../data/practice_words.dart';
import '../providers/progress_providers.dart';

/// The practice the player has put into one lesson: how long altogether, over how
/// many sittings, and when the last one was.
///
/// It is theirs and nobody else's, which is why it says nothing until there is
/// something to say. A lesson that opens with `0 min practised` is the app asking
/// after work the player has not had a chance to do yet.
///
/// The total comes from the lesson's progress row rather than from adding the sittings
/// up. Practice was being recorded as a total before it was recorded as sittings, so
/// on a phone that upgraded into this the two do not match - and the total is the one
/// that holds all of the player's hours.
class LessonPractice extends ConsumerWidget {
  const LessonPractice({
    required this.lessonId,
    required this.practiceSeconds,
    super.key,
  });

  final int lessonId;

  final int practiceSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (practiceSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final sessions =
        ref.watch(practiceSessionProvider(lessonId)).valueOrNull ?? const [];
    final last = sessions.firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.timelapse,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              [
                practiceSummary(
                  seconds: practiceSeconds,
                  sittings: sessions.length,
                ),
                if (last != null)
                  'last on ${formatDate(last.endedAt.toLocal())}',
              ].join(', '),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
