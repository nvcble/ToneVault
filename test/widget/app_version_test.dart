import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/settings/data/app_version.dart';
import 'package:tone_vault/features/settings/providers/app_version_providers.dart';
import 'package:tone_vault/features/settings/screens/settings_screen.dart';
import 'package:tone_vault/features/settings/widgets/app_version_tile.dart';

import '../support/themed_app.dart';

/// What the app says about which build it is.
void main() {
  Future<void> pumpTile(WidgetTester tester, AppVersionReader reader) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appVersionReaderProvider.overrideWithValue(reader)],
        child: themedApp(const AppVersionTile()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the version names the build as well as the release', (
    tester,
  ) async {
    await pumpTile(tester, () async => (name: '1.0.1', build: '2'));

    // The build number too: two sideloads of 1.0.1 are told apart by nothing
    // else.
    expect(find.text('Version 1.0.1 (build 2)'), findsOne);
  });

  testWidgets('a version that cannot be read says so rather than guessing', (
    tester,
  ) async {
    await pumpTile(
      tester,
      () async => throw const AppFailure('No platform to ask.'),
    );

    expect(find.text('Version unavailable'), findsOne);
    expect(find.textContaining('Version 1.'), findsNothing);
  });

  testWidgets('settings shows it, under About', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appVersionReaderProvider.overrideWithValue(
            () async => (name: '2.3.4', build: '11'),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOne);
    expect(find.text('Version 2.3.4 (build 11)'), findsOne);
  });
}
