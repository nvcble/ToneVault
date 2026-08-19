import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_providers.dart';
import 'change_list_view.dart';

/// The history section of one pedal: everything that happened to it and to its
/// configurations, newest first.
class PedalHistoryView extends ConsumerWidget {
  const PedalHistoryView({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChangeListView(
      changes: ref.watch(pedalHistoryProvider(pedalId)),
      emptyTitle: 'Nothing logged yet',
      emptyMessage:
          'Adding controls and saving settings for this pedal will show up '
          'here, along with the reasons you gave.',
    );
  }
}
