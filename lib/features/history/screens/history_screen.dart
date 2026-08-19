import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../providers/history_providers.dart';
import '../widgets/change_list_view.dart';

/// Everything that has happened across the whole collection, newest first.
///
/// Rows name their pedal here, since the timeline mixes pedals together, and
/// tapping one opens that pedal.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ChangeListView(
        changes: ref.watch(recentHistoryProvider),
        showPedalNames: true,
        onOpenPedal: (pedalId) => context.go(Routes.pedalDetail(pedalId)),
        emptyTitle: 'Nothing logged yet',
        emptyMessage:
            'Every setting change you make is recorded here with the '
            'reason you gave for it.',
      ),
    );
  }
}
