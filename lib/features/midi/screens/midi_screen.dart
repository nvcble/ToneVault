import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/midi_device_catalog_provider.dart';
import '../widgets/midi_device_tile.dart';

/// Where the MIDI module opens: which compatible device to control.
class MidiScreen extends ConsumerWidget {
  const MidiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(midiDeviceCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MIDI')),
      body: ListView(
        children: [
          const SectionLabel('Compatible devices'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                for (final profile in profiles)
                  MidiDeviceTile(
                    profile: profile,
                    onTap: () => context.push(Routes.midiConnect(profile.id)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
