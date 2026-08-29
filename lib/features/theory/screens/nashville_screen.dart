import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/nashville_notes.dart';
import '../widgets/nashville_translator.dart';

/// The Nashville Number System, explained and then usable.
///
/// A screen of its own rather than a seventh tab: the other six are six views of one key
/// that all change together, and this is the thing that explains what their numbers mean.
/// It is reached from the browser's header, which is where a player is when the question
/// occurs to them.
///
/// The reading and writing at the bottom is the same engine the progressions tab and every
/// lesson's theory keys go through, so nothing here can teach a system the rest of the app
/// does not use.
class NashvilleScreen extends StatelessWidget {
  const NashvilleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The number system')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final note in nashvilleNotes) _Note(note: note),
          const Divider(height: AppSpacing.xl),
          const NashvilleTranslator(),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.note});

  final ({String heading, String body}) note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note.heading, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(note.body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
