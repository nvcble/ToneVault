import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_status.dart';
import 'pedal_type_badge.dart';

/// One pedal in the inventory list.
class PedalCard extends StatelessWidget {
  const PedalCard({required this.pedal, required this.onTap, super.key});

  final Pedal pedal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      ?pedal.brand,
      pedal.category.label,
      // Only worth the space when it is not the obvious case, and a retired or
      // replaced pedal is exactly what someone scanning the list needs to spot.
      if (pedal.status != PedalStatus.active) pedal.status.label,
    ].join(' · ');

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(pedal.name),
        subtitle: Text(details),
        trailing: PedalTypeBadge(pedal.type),
      ),
    );
  }
}
