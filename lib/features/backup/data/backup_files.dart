import 'dart:convert';

import 'package:file_selector/file_selector.dart' show XTypeGroup, openFile;
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;

import '../../../core/errors/app_failure.dart';

/// Hands a finished backup to whatever the user wants to keep it in.
typedef BackupSender =
    Future<void> Function(String contents, {required String fileName});

/// Asks for a backup file and returns what is in it, or null if the user backed
/// out of choosing one.
typedef BackupChooser = Future<String?> Function();

/// Passes the backup to the system share sheet.
///
/// The user picks Drive, email, Files or anything else installed, which is why
/// the app needs no storage permission, no folder of its own, and no opinion
/// about where a backup belongs. share_plus writes the temporary file itself.
Future<void> shareBackupFile(
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
        // saving is set here.
        fileNameOverrides: [fileName],
        subject: fileName,
      ),
    );
  } catch (error) {
    throw AppFailure('Could not pass the backup on to be saved.', cause: error);
  }
}

/// Asks the user for a backup file and reads it.
///
/// Nothing is checked here beyond being readable text: whether it is a backup at
/// all is the document layer's answer to give.
Future<String?> chooseBackupFile() async {
  try {
    final chosen = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'ToneVault backup',
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
