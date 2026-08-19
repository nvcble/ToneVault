import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';
import '../widgets/dev_seed_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          const Expanded(
            child: EmptyState(
              icon: Icons.settings_outlined,
              title: 'No settings yet',
              message: 'Appearance, backup and export options will live here.',
            ),
          ),
          // Development tooling sits apart from real settings, and is compiled
          // out of release builds rather than merely hidden.
          if (kDebugMode) ...[const Divider(height: 0), const DevSeedTile()],
        ],
      ),
    );
  }
}
