import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// File name of the on-device database, without extension.
const String databaseName = 'tone_vault';

/// Opens the app's database in the platform's documents directory.
///
/// Kept separate from [AppDatabase] so tests can supply an in-memory executor
/// without dragging in path_provider or the Flutter bindings.
DatabaseConnection openAppDatabaseConnection() {
  return driftDatabase(name: databaseName);
}
