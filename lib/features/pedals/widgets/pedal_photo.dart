import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// The photo a pedal was given, read from the file it was stored in.
///
/// A stored path can outlive its file: a backup restored onto another phone brings
/// the path with it and not the picture. That reads as a placeholder rather than
/// as a crash or a red box, because the pedal itself is still perfectly usable.
class PedalPhoto extends StatelessWidget {
  const PedalPhoto({required this.photoPath, this.height = 180, super.key});

  /// Null on a pedal that was never given one, which shows the placeholder too:
  /// the form needs something to tap.
  final String? photoPath;

  final double height;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: path == null
            ? const _MissingPhoto(Icons.photo_camera_outlined)
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _MissingPhoto(Icons.broken_image_outlined),
              ),
      ),
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(child: Icon(icon, color: colors.onSurfaceVariant)),
    );
  }
}
