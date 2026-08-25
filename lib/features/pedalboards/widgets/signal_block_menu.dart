import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_block_type.dart';
import '../data/chain_block_name.dart';

/// What can be done with one block, offered when it is tapped.
///
/// A sheet rather than a screen, and rather than a row of small buttons on the
/// card: a block has several quite different things that can happen to it, and a
/// card crowded with icons is a card that is hard to drag.
///
/// Nothing is written here. The chosen action goes back to the caller, which is
/// what keeps this widget testable and the writes in one place.
enum SignalBlockAction {
  viewSettings,
  assignPedal,
  editBlock,
  endpoint,
  pairReturn,
  cables,
  toggleBypass,
  remove,
}

/// Shows the menu for [entry] and returns what the user chose, or null.
Future<SignalBlockAction?> showSignalBlockMenu(
  BuildContext context,
  ChainBlock entry,
) {
  return showModalBottomSheet<SignalBlockAction>(
    context: context,
    builder: (sheetContext) => _SignalBlockMenu(entry: entry),
  );
}

class _SignalBlockMenu extends StatelessWidget {
  const _SignalBlockMenu({required this.entry});

  final ChainBlock entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final block = entry.block;
    final pedal = entry.pedal;

    // Scrollable because a sheet is only given part of the screen, and five
    // actions plus a title do not fit a phone held sideways.
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                entry.displayName,
                style: theme.textTheme.titleMedium,
              ),
            ),
            // Settings are the pedal's own, so they are only offered where there is
            // a pedal to read them off. This opens the pedal rather than repeating
            // it: a rig says what is on it, and how a pedal is dialled in belongs
            // to the pedal.
            if (pedal != null)
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('View settings'),
                subtitle: Text(pedal.name, overflow: TextOverflow.ellipsis),
                onTap: () =>
                    Navigator.pop(context, SignalBlockAction.viewSettings),
              ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(pedal == null ? 'Put a pedal here' : 'Change pedal'),
              onTap: () =>
                  Navigator.pop(context, SignalBlockAction.assignPedal),
            ),
            // What the block itself is: its type, what it is called, and anything
            // noted about it. Bypass is here too, and offered below as one tap,
            // because it is the one thing about a block changed mid-rehearsal.
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit block'),
              onTap: () => Navigator.pop(context, SignalBlockAction.editBlock),
            ),
            // An edge of the rig is described by where it reaches rather than by
            // which pedal fills it, and usually no pedal does.
            if (block.blockType.isBoundary)
              ListTile(
                leading: Icon(
                  block.blockType.carriesDestination
                      ? Icons.logout
                      : Icons.login,
                ),
                title: Text(
                  block.blockType.carriesDestination
                      ? 'Where this goes'
                      : 'Where this comes from',
                ),
                onTap: () => Navigator.pop(context, SignalBlockAction.endpoint),
              ),
            // Only a send: the return is the far half of the same answer, and being
            // asked the same thing from both ends is how the two get muddled.
            if (block.blockType == SignalBlockType.send)
              ListTile(
                leading: const Icon(Icons.loop),
                title: const Text('Comes back through'),
                subtitle: const Text('The return that brings signal back in'),
                onTap: () =>
                    Navigator.pop(context, SignalBlockAction.pairReturn),
              ),
            // Only needed once a rig stops being a straight line, so it is worded
            // as what it does rather than as "routing". Left out where signal has
            // already left the rig, because nothing on the board follows it.
            if (!block.blockType.carriesDestination)
              ListTile(
                leading: const Icon(Icons.call_split),
                title: const Text('Cables'),
                subtitle: const Text('What this block feeds next'),
                onTap: () => Navigator.pop(context, SignalBlockAction.cables),
              ),
            ListTile(
              leading: Icon(
                block.isEnabled ? Icons.flash_off_outlined : Icons.flash_on,
              ),
              title: Text(block.isEnabled ? 'Bypass' : 'Bring back in'),
              onTap: () =>
                  Navigator.pop(context, SignalBlockAction.toggleBypass),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from chain'),
              subtitle: pedal == null
                  ? null
                  : const Text('The pedal stays in your inventory'),
              onTap: () => Navigator.pop(context, SignalBlockAction.remove),
            ),
          ],
        ),
      ),
    );
  }
}
