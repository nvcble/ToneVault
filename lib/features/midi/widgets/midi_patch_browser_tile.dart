import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';

/// One patch in the Patch Browser: its number, its name, a favorite star,
/// and a spinner while it is the one being loaded.
class MidiPatchBrowserTile extends StatelessWidget {
  const MidiPatchBrowserTile({
    required this.patch,
    required this.isFavorite,
    required this.isSelecting,
    required this.onTap,
    required this.onToggleFavorite,
    super.key,
  });

  final NumberedPatch patch;
  final bool isFavorite;
  final bool isSelecting;
  final VoidCallback? onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        child: Text('${patch.programNumber}', textAlign: TextAlign.center),
      ),
      title: Text(patch.patch.name),
      onTap: isSelecting ? null : onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelecting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}
