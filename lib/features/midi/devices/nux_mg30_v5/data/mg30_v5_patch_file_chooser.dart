import 'dart:typed_data';

import 'package:file_selector/file_selector.dart' show XTypeGroup, openFile;

import '../../../../../core/errors/app_failure.dart';

/// Asks the user for a `.mg30patch` file and returns its bytes, or null when they
/// backed out of choosing one.
///
/// Nothing is checked here beyond being readable. Whether the bytes are an MG-30
/// V5 export is `readMg30V5PatchFile`'s answer to give, and it gives it before
/// anything is written to the library.
typedef Mg30PatchFileChooser = Future<Uint8List?> Function();

Future<Uint8List?> chooseMg30PatchFile() async {
  try {
    final chosen = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'NUX MG-30 patch export',
          extensions: ['mg30patch'],
          // Android filters on the mime type, and QuickTone's own extension is
          // not one the system knows, so anything is offered and the decode is
          // what rejects a wrong file.
          mimeTypes: ['application/octet-stream'],
        ),
      ],
    );

    return chosen == null ? null : await chosen.readAsBytes();
  } catch (error) {
    throw AppFailure('Could not open that file.', cause: error);
  }
}
