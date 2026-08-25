import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

/// One rig in the list.
class RigCard extends StatelessWidget {
  const RigCard({
    required this.pedalboard,
    required this.onTap,
    this.blockCount,
    super.key,
  });

  final Pedalboard pedalboard;

  /// How long the rig's chain is, or null while that is still being counted.
  final int? blockCount;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(pedalboard.name),
        subtitle: switch (_subtitle()) {
          final String subtitle => Text(subtitle),
          // A rig with nothing said about it and nothing counted yet gets no
          // second line, rather than a row of placeholder text.
          _ => null,
        },
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  /// How big the rig is, after whatever the user said about it.
  String? _subtitle() {
    final count = blockCount;
    final parts = [
      ?pedalboard.description,
      if (count != null) count == 1 ? '1 block' : '$count blocks',
    ];

    return parts.isEmpty ? null : parts.join(' · ');
  }
}
