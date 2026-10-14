import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_version_providers.dart';

/// Which build of the app this is.
///
/// Worth a row of its own because it answers a question nothing else in the app
/// can: whether the install that was just sideloaded is the one running.
class AppVersionTile extends ConsumerWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);

    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('ToneVault'),
      // Read in microseconds, so loading is a frame rather than a wait and a
      // spinner here would only flash. A failure says so instead of showing a
      // version that might be wrong.
      subtitle: Text(
        version.when(
          loading: () => 'Reading the version...',
          error: (error, _) => 'Version unavailable',
          data: (version) => 'Version ${version.name} (build ${version.build})',
        ),
      ),
    );
  }
}
