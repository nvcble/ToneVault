import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class RigsScreen extends StatelessWidget {
  const RigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rigs')),
      body: const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'No rigs yet',
        message: 'A rig is an ordered signal chain built from pedals you own.',
      ),
    );
  }
}
