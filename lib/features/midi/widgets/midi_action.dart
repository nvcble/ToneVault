import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';

/// The way into the MIDI module, in the header of every tab - the same
/// placement as the Academy's own header action, for the same reason: reached
/// from wherever the user already is rather than a fifth destination in the
/// bottom bar.
class MidiAction extends StatelessWidget {
  const MidiAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.cable),
      tooltip: 'MIDI',
      onPressed: () => context.push(Routes.midi),
    );
  }
}
