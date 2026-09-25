import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/midi_mapping_providers.dart';
import '../widgets/midi_mapping_tile.dart';

/// Every parameter's CC assignment, editable the way NUX's own QuickTone app
/// lets a user remap the MG-30 itself.
class MidiMappingScreen extends ConsumerWidget {
  const MidiMappingScreen({required this.profileId, super.key});

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
    final overriddenAsync = ref.watch(
      overriddenParameterNamesProvider(profileId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('CC mapping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset all to defaults',
            onPressed: () async {
              try {
                await ref
                    .read(midiParameterMappingRepositoryProvider)
                    .resetAllOverrides(profileId);
              } catch (error) {
                if (context.mounted) showFailureSnackBar(context, error);
              }
            },
          ),
        ],
      ),
      body: parametersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load the mapping',
          message: failureMessage(error),
        ),
        data: (parameters) {
          final overridden = overriddenAsync.valueOrNull ?? const <String>{};
          return ListView.builder(
            itemCount: parameters.length,
            itemBuilder: (context, index) {
              final definition = parameters[index];
              return MidiMappingTile(
                definition: definition,
                isOverridden: overridden.contains(definition.name),
                onChanged: (cc) async {
                  try {
                    await ref
                        .read(midiParameterMappingRepositoryProvider)
                        .setOverride(
                          profile: profile,
                          parameterName: definition.name,
                          ccNumber: cc,
                        );
                  } catch (error) {
                    if (context.mounted) showFailureSnackBar(context, error);
                  }
                },
                onReset: () async {
                  try {
                    await ref
                        .read(midiParameterMappingRepositoryProvider)
                        .resetOverride(
                          deviceProfileId: profileId,
                          parameterName: definition.name,
                        );
                  } catch (error) {
                    if (context.mounted) showFailureSnackBar(context, error);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
