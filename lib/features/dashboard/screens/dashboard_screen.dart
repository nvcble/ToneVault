import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToneVault')),
      body: const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'Your rig at a glance',
        message:
            'Pedal counts, recent changes and quick actions appear here '
            'once there is gear to show.',
      ),
    );
  }
}
