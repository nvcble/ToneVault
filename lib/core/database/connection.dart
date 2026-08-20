import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// File name of the on-device database, without extension.
const String databaseName = 'tone_vault';

/// Opens the app's database on whichever platform the app is running on.
///
/// Kept separate from [AppDatabase] so tests can supply an in-memory executor
/// without dragging in path_provider or the Flutter bindings.
///
/// Android is the only platform the app ships for, so this is a file in the
/// documents directory.
DatabaseConnection openAppDatabaseConnection() {
  return driftDatabase(name: databaseName);

  // Kept for tracking: what a browser build needs on top of the above. A
  // browser has no documents directory, so sqlite3 runs as WebAssembly there
  // against whichever storage the browser offers - OPFS where it exists,
  // IndexedDB otherwise - and both files have to be served from `web/`. That
  // vault belongs to the browser profile it was made in, so it is a separate
  // collection from the one on a phone. The files themselves are in the
  // "run the same vault in a browser" commit.
  //
  // return driftDatabase(
  //   name: databaseName,
  //   // Ignored on Android, which never asks for these.
  //   web: DriftWebOptions(
  //     sqlite3Wasm: Uri.parse('sqlite3.wasm'),
  //     driftWorker: Uri.parse('drift_worker.js'),
  //   ),
  // );
}
