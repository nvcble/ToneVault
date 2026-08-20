import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// File name of the on-device database, without extension.
const String databaseName = 'tone_vault';

/// Opens the app's database on whichever platform the app is running on.
///
/// Kept separate from [AppDatabase] so tests can supply an in-memory executor
/// without dragging in path_provider or the Flutter bindings.
///
/// On Android this is a file in the documents directory. In a browser there is
/// no such directory, so sqlite3 runs as WebAssembly against whichever storage
/// the browser offers — OPFS where it exists, IndexedDB otherwise — and both
/// files are served from `web/`. That vault belongs to the browser profile it
/// was made in: it is a separate collection from the one on a phone, and a
/// backup file is the only way to carry gear between them.
DatabaseConnection openAppDatabaseConnection() {
  return driftDatabase(
    name: databaseName,
    // Ignored on Android, which never asks for these.
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
