import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../widgets/midi_parameter_tile.dart';

/// Every block model, knob and named parameter of one device, each sent
/// explicitly rather than streamed live - see section 11 of the MIDI module
/// brief.
class MidiParameterListScreen extends ConsumerWidget {
  const MidiParameterListScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final parametersAsync = ref.watch(effectiveParametersProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: const Text('Parameters')),
      body: parametersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load parameters',
          message: failureMessage(error),
        ),
        data: (parameters) => ListView.builder(
          itemCount: parameters.length,
          itemBuilder: (context, index) {
            final definition = parameters[index];
            return MidiParameterTile(
              definition: definition,
              onSend: (value) async {
                try {
                  await ref
                      .read(midiParameterSenderProvider)
                      .send(
                        profile: profile,
                        effectiveParameters: parameters,
                        parameterName: definition.name,
                        value: value,
                      );
                } catch (error) {
                  if (context.mounted) showFailureSnackBar(context, error);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
