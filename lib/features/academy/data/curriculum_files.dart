import 'dart:convert';

import 'package:file_selector/file_selector.dart' show XTypeGroup, openFile;
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;

import '../../../core/errors/app_failure.dart';

/// Hands a finished curriculum to whatever the user wants to keep or send it in.
typedef CurriculumSender =
    Future<void> Function(String contents, {required String fileName});

/// Asks for a curriculum file and returns what is in it, or null if the user backed
/// out of choosing one.
typedef CurriculumChooser = Future<String?> Function();

/// Passes the curriculum to the system share sheet.
///
/// The same reasoning as a backup: the user picks Drive, email, Files or a message to
/// the student they wrote the course for, so the app needs no storage permission and
/// no folder of its own. A curriculum is more often sent to somebody than saved, which
/// the share sheet handles and a file picker would not.
Future<void> shareCurriculumFile(
  String contents, {
  required String fileName,
}) async {
  try {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(utf8.encode(contents), mimeType: 'application/json'),
        ],
        // The bytes carry no name of their own, so the one the user sees when
        // saving or sending is set here.
        fileNameOverrides: [fileName],
        subject: fileName,
      ),
    );
  } catch (error) {
    throw AppFailure(
      'Could not pass the curriculum on to be saved.',
      cause: error,
    );
  }
}

/// Asks the user for a curriculum file and reads it.
///
/// Nothing is checked here beyond being readable text. Whether it is a curriculum at
/// all, and one this app can read, is the document layer's answer to give - and it
/// gives it before anything is written.
Future<String?> chooseCurriculumFile() async {
  try {
    final chosen = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'ToneVault curriculum',
          extensions: ['json'],
          // Android filters on the mime type rather than the extension.
          mimeTypes: ['application/json'],
        ),
      ],
    );

    return chosen == null ? null : await chosen.readAsString();
  } catch (error) {
    throw AppFailure('Could not open that file.', cause: error);
  }
}
