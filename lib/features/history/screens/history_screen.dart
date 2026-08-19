import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const EmptyState(
        icon: Icons.history,
        title: 'Nothing logged yet',
        message:
            'Every setting change you make is recorded here with the '
            'reason you gave for it.',
      ),
    );
  }
}
