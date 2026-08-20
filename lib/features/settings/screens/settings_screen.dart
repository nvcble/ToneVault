import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
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
                _SectionLabel('Your gear, kept safe'),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
