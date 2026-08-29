import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../providers/academy_providers.dart';

/// What the lesson leads to, at the bottom of it.
///
/// Named rather than linked, and looked up rather than followed: tapping it searches
/// the Academy for those words. A stored slug would break the moment a course was
/// re-ordered or imported again, and searching finds the skill wherever it now lives -
/// including in the theory browser, which is where half of them are taught.
class LessonNextSkill extends ConsumerWidget {
  const LessonNextSkill({required this.nextSkill, super.key});

  final String? nextSkill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skill = nextSkill;
    if (skill == null || skill.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: InkWell(
        onTap: () => _find(context, ref, skill),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                Icons.arrow_forward,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Next: $skill',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _find(BuildContext context, WidgetRef ref, String skill) {
    ref.read(lessonSearchQueryProvider.notifier).state = skill;
    context.push<void>(Routes.academySearch);
  }
}
