import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_device_profile.dart';

/// One selectable device in the MIDI landing screen's catalog.
class MidiDeviceTile extends StatelessWidget {
  const MidiDeviceTile({required this.profile, required this.onTap, super.key});

  final MidiDeviceProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: const Icon(Icons.settings_input_component),
        title: Text(profile.displayName),
        subtitle: Text('${profile.manufacturer} · Firmware ${profile.firmwareVersion}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
