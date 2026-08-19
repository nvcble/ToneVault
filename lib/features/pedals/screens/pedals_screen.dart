import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class PedalsScreen extends StatelessWidget {
  const PedalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedals')),
      body: const EmptyState(
        icon: Icons.tune,
        title: 'No pedals yet',
        message: 'Add the gear you own to start documenting its controls and '
            'settings.',
      ),
    );
  }
}
