import 'dart:io';

import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedals/data/photo_picker.dart';

/// A camera and a gallery a test can have.
///
/// Hands back a file the test prepared, or nothing at all to stand for the user
/// backing out, or a failure to stand for a refused permission. Which source was
/// asked for is recorded, since that is the only thing the form decides.
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker({this.picked, this.failure});

  /// The file the device would return, or null if the user backed out.
  File? picked;

  /// Thrown instead of returning, the way a refused camera arrives.
  AppFailure? failure;

  final List<PhotoSource> asked = <PhotoSource>[];

  @override
  Future<String?> pick(PhotoSource source) async {
    asked.add(source);
    final refusal = failure;
    if (refusal != null) {
      throw refusal;
    }
    return picked?.path;
  }
}
