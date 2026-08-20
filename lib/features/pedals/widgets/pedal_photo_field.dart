import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/photo_picker.dart';
import '../providers/pedal_providers.dart';
import 'pedal_photo.dart';

/// The photo field of the pedal form: what was chosen, and how to change it.
///
/// Holds no path of its own. It reports the stored copy through [onChanged] and
/// the form keeps it with the rest of the draft, so a photo is only really the
/// pedal's once the pedal is saved.
class PedalPhotoField extends ConsumerStatefulWidget {
  const PedalPhotoField({
    required this.photoPath,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String? photoPath;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  ConsumerState<PedalPhotoField> createState() => _PedalPhotoFieldState();
}

class _PedalPhotoFieldState extends ConsumerState<PedalPhotoField> {
  /// What the pedal was saved with, if anything. Never deleted here: the pedal on
  /// screen still points at it, and the user may yet back out of the form.
  late final String? _saved = widget.photoPath;

  /// A camera or gallery is being waited on, so one tap cannot start two.
  bool _isPicking = false;

  Future<void> _choose(PhotoSource source) async {
    setState(() => _isPicking = true);
    final photos = ref.read(pedalPhotoRepositoryProvider);
    final replaced = widget.photoPath;

    try {
      final path = await photos.choose(source);
      if (path == null) {
        return;
      }
      // A shot the user took and then thought better of would otherwise sit in
      // the app's folder forever with nothing pointing at it.
      if (replaced != _saved) {
        await photos.discard(replaced);
      }
      widget.onChanged(path);
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  /// Takes the photo off the pedal. The saved file stays until the form is saved,
  /// which is the point at which the pedal stops pointing at it.
  void _remove() => widget.onChanged(null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = widget.photoPath != null;
    final enabled = widget.enabled && !_isPicking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo', style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        PedalPhoto(photoPath: widget.photoPath),
        const SizedBox(height: AppSpacing.xs),
        // Wrapped rather than a row: three buttons and a phone in a large font
        // size run out of width.
        Wrap(
          spacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final source in PhotoSource.values)
              TextButton.icon(
                icon: Icon(
                  source == PhotoSource.camera
                      ? Icons.photo_camera_outlined
                      : Icons.photo_library_outlined,
                ),
                label: Text(source.label),
                onPressed: enabled ? () => _choose(source) : null,
              ),
            if (hasPhoto)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove photo',
                onPressed: enabled ? _remove : null,
              ),
          ],
        ),
      ],
    );
  }
}
