import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/pedal_status.dart';
import '../../../shared/widgets/filter_chip_menu.dart';
import '../data/pedal_filter.dart';
import '../providers/pedal_filter_providers.dart';
import 'pedal_search_field.dart';

/// Search box, category and status chips, and how much of the collection they
/// leave on screen.
///
/// Reads and writes [pedalFilterProvider] directly: there is no decision to
/// make here beyond which field changed, and the list below reads the same
/// filter.
class PedalFilterBar extends ConsumerWidget {
  const PedalFilterBar({required this.search, super.key});

  final PedalSearch search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = search.filter;
    final theme = Theme.of(context);

    void update(PedalFilter next) =>
        ref.read(pedalFilterProvider.notifier).state = next;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PedalSearchField(
            query: filter.query,
            onChanged: (query) => update((
              query: query,
              category: filter.category,
              status: filter.status,
            )),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              FilterChipMenu<PedalCategory>(
                emptyLabel: 'Category',
                clearLabel: 'Any category',
                value: filter.category,
                // Only the categories owned: the other fifteen would bury them.
                options: search.categories,
                labelOf: (category) => category.label,
                onSelected: (category) => update((
                  query: filter.query,
                  category: category,
                  status: filter.status,
                )),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilterChipMenu<PedalStatus>(
                emptyLabel: 'Status',
                clearLabel: 'Any status',
                value: filter.status,
                options: PedalStatus.values,
                labelOf: (status) => status.label,
                onSelected: (status) => update((
                  query: filter.query,
                  category: filter.category,
                  status: status,
                )),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  describeMatches(search),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
