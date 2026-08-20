import 'dart:io';

import '../../../core/errors/app_failure.dart';
import 'photo_picker.dart';

/// Where the app keeps the photos it owns. Given from outside so a test can hand
/// over a temporary directory instead of the real one.
typedef PhotoFolder = Future<Directory> Function();

/// Getting a photo of a pedal and keeping it.
///
/// The picked file belongs to the camera or the gallery, and both are free to
/// clear it out: a cache shot is gone by the next reboot, and a gallery photo can
/// be deleted by the user. So the file is copied into the app's own folder and it
/// is that copy the pedal's `photoPath` points at.
///
/// Only the app's own copies are ever deleted, which is why [discard] checks the
/// folder first. A path that came out of a restored backup and belongs to another
/// device is left where it is.
class PedalPhotoRepository {
  const PedalPhotoRepository(this._picker, this._folder);

  final PhotoPicker _picker;
  final PhotoFolder _folder;

  /// Picks a photo and returns the path of the app's copy, or null if the user
  /// backed out.
  Future<String?> choose(PhotoSource source) async {
    final picked = await _picker.pick(source);
    if (picked == null) {
      return null;
    }

    try {
      final folder = await _folder();
      await folder.create(recursive: true);
      // Named for the moment it was taken, so two photos of the same pedal cannot
      // land on one name.
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final copy = '${folder.path}/pedal_$stamp${_extensionOf(picked)}';

      await File(picked).copy(copy);
      return copy;
    } catch (error) {
      throw AppFailure('Could not save this photo.', cause: error);
    }
  }

  /// Deletes a copy this app made, if it is still there.
  ///
  /// Used when a photo is replaced before it was ever saved against a pedal.
  /// Missing files are not a problem the user can act on, so they pass quietly.
  Future<void> discard(String? photoPath) async {
    if (photoPath == null) {
      return;
    }

    try {
      final folder = await _folder();
      if (!photoPath.startsWith(folder.path)) {
        return;
      }
      final file = File(photoPath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (error) {
      throw AppFailure('Could not remove this photo.', cause: error);
    }
  }

  /// `.jpg` from `IMG_0042.jpg`, and nothing at all when the source has no
  /// extension: a name ending in a bare dot would be worse than none.
  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    final slash = path.lastIndexOf(RegExp(r'[/\\]'));
    if (dot <= slash + 1 || dot == path.length - 1) {
      return '';
    }
    return path.substring(dot).toLowerCase();
  }
}
