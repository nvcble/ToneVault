import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import 'empty_state.dart';
import 'failure_snack_bar.dart';

/// A watched list with one action under it: what every section of a detail
/// screen looks like.
///
/// Loading, a failure the user can read, an empty state and the rows are the
/// same four cases every time, so they are decided here rather than in each
/// section.
///
/// Kept for tracking: `ConfigurationListView` spells this out inline. It is left
/// as it is rather than changed under working, tested code; anything new uses
/// this.
class AsyncListSection<T> extends StatelessWidget {
  const AsyncListSection({
    required this.items,
    required this.errorTitle,
    required this.empty,
    required this.itemBuilder,
    this.addLabel,
    this.onAdd,
    super.key,
  });

  final AsyncValue<List<T>> items;

  /// What could not be loaded, in the user's terms. The exception itself is
  /// never shown.
  final String errorTitle;
  final Widget empty;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// The one action under the list, left out where there is nothing to add.
  final String? addLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final label = addLabel;
    final onAdd = this.onAdd;

    return Column(
      children: [
        Expanded(
          child: items.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: errorTitle,
              message: failureMessage(error),
            ),
            data: (items) => items.isEmpty
                ? empty
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        itemBuilder(context, items[index]),
                  ),
          ),
        ),
        if (label != null && onAdd != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(label),
              ),
            ),
          ),
      ],
    );
  }
}
