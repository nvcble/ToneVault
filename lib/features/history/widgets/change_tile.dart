import 'package:flutter/material.dart';

import '../../../core/database/daos/change_log_dao.dart';
import '../../../core/enums/change_type.dart';
import '../data/change_summary.dart';

/// One event on the timeline: what changed, what it belonged to, and the reason
/// the user gave for it.
class ChangeTile extends StatelessWidget {
  const ChangeTile({
    required this.change,
    this.showPedalName = false,
    this.onTap,
    super.key,
  });

  final PedalChange change;

  /// True on the collection-wide timeline, where the rows mix pedals together.
  final bool showPedalName;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = change.entry;
    final reason = entry.reason;

    return ListTile(
      leading: Icon(
        _iconFor(entry.changeType),
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(changeHeadline(entry, control: change.control)),
      isThreeLine: reason != null,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            changeContext(
              entry,
              pedalName: showPedalName ? change.pedalName : null,
            ),
          ),
          // The reason is the user's own words, so it is set apart from the
          // sentence the app wrote about the change.
          if (reason != null)
            Text(
              reason,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

IconData _iconFor(ChangeType type) => switch (type) {
  ChangeType.controlValueChanged => Icons.tune,
  ChangeType.configurationCreated => Icons.bookmark_add_outlined,
  ChangeType.configurationRenamed => Icons.drive_file_rename_outline,
  ChangeType.configurationDeleted => Icons.bookmark_remove_outlined,
  ChangeType.controlAdded => Icons.add_circle_outline,
  ChangeType.controlRemoved => Icons.remove_circle_outline,
  ChangeType.pedalStatusChanged => Icons.flag_outlined,
  ChangeType.pedalReplaced => Icons.swap_horiz,
};
