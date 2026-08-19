import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';

/// Fills an empty inventory with sample pedals, for developing against.
///
/// The settings screen only builds this in debug mode, and it runs on a tap
/// rather than at startup, so a real inventory is never seeded behind the
/// owner's back.
class DevSeedTile extends ConsumerStatefulWidget {
  const DevSeedTile({super.key});

  @override
  ConsumerState<DevSeedTile> createState() => _DevSeedTileState();
}

class _DevSeedTileState extends ConsumerState<DevSeedTile> {
  bool _isSeeding = false;

  Future<void> _seed() async {
    setState(() => _isSeeding = true);

    try {
      final added = await ref.read(pedalSeederProvider).seed();
      if (mounted) {
        _report('Added $added sample pedals.');
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.science_outlined),
      title: const Text('Add sample pedals'),
      subtitle: const Text(
        'Development data. Only works while the inventory is empty.',
      ),
      trailing: _isSeeding
          ? const SizedBox.square(
              dimension: AppSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _isSeeding ? null : _seed,
    );
  }
}
