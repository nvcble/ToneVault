import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';

/// One configuration in a pedal's list.
class ConfigurationTile extends StatelessWidget {
  const ConfigurationTile({
    required this.configuration,
    required this.onTap,
    this.onEdit,
    super.key,
  });

  final Configuration configuration;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final notes = configuration.notes;

    return ListTile(
      title: Text(configuration.name),
      // Notes are what the user wrote about this setting; the date is the
      // fallback, so a row always says something about when it was last touched.
      subtitle: Text(
        notes ?? 'Changed ${formatDate(configuration.updatedAt)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onEdit == null
          ? null
          : IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Rename',
              onPressed: onEdit,
            ),
      onTap: onTap,
    );
  }
}
