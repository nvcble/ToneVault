import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../shared/widgets/section_label.dart';
import '../widgets/backup_tile.dart';
import '../widgets/dev_seed_tile.dart';
import '../widgets/restore_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                SectionLabel('Your gear, kept safe'),
                BackupTile(),
                RestoreTile(),
              ],
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
