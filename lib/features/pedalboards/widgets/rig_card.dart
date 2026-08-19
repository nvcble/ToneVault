import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

/// One rig in the list.
class RigCard extends StatelessWidget {
  const RigCard({required this.pedalboard, required this.onTap, super.key});

  final Pedalboard pedalboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final description = pedalboard.description;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(pedalboard.name),
        // A rig with nothing said about it gets no second line, rather than a
        // row of placeholder text.
        subtitle: description == null ? null : Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
