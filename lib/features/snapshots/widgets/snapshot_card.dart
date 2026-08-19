import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';

/// One snapshot in a rig's list.
///
/// The date carries the time of day, because two snapshots can share a name and
/// a date - two services on one Sunday - and the time is what tells them apart.
class SnapshotCard extends StatelessWidget {
  const SnapshotCard({required this.snapshot, required this.onTap, super.key});

  final RigSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final notes = snapshot.notes;

    return Card(
      child: ListTile(
        title: Text(snapshot.name),
        subtitle: Text(
          notes == null
              ? formatDateTime(snapshot.capturedAt)
              : '${formatDateTime(snapshot.capturedAt)}\n$notes',
        ),
        isThreeLine: notes != null,
        onTap: onTap,
      ),
    );
  }
}
