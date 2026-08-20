import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_failure.dart';

/// Where a photo of a pedal comes from.
enum PhotoSource {
  camera('Take photo'),
  gallery('Choose photo');

  const PhotoSource(this.label);

  /// What the button offering it says.
  final String label;
}

/// Asks the device for a photo and returns where it landed.
///
/// An interface because the device is the one thing a test cannot have: the form
/// is driven through a stand-in that returns a file prepared by the test, and
/// nothing but [ImagePickerPhotos] ever touches the plugin.
abstract class PhotoPicker {
  /// The path of the picked file, or null if the user backed out.
  ///
  /// The file belongs to the camera or the gallery, not to us: whoever wants to
  /// keep it copies it somewhere of their own.
  Future<String?> pick(PhotoSource source);
}

/// The real one, over `image_picker`.
class ImagePickerPhotos implements PhotoPicker {
  ImagePickerPhotos({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// A pedal photo is a reference shot on a phone screen, so it is taken down to
  /// something a list can scroll rather than kept at full sensor size.
  static const double _maxEdge = 1600;
  static const int _quality = 85;

  @override
  Future<String?> pick(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _maxEdge,
        maxHeight: _maxEdge,
        imageQuality: _quality,
      );
      return file?.path;
    } catch (error) {
      // A refused permission and a missing camera both arrive as a
      // PlatformException, which is not something to show anyone.
      throw AppFailure(
        source == PhotoSource.camera
            ? 'Could not open the camera. Check ToneVault is allowed to use it.'
            : 'Could not open your photos.',
        cause: error,
      );
    }
  }
}
