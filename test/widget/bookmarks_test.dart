import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/bookmark_target.dart';
import 'package:tone_vault/features/academy/providers/academy_providers.dart';
import 'package:tone_vault/features/academy/screens/bookmarks_screen.dart';
import 'package:tone_vault/features/theory/screens/theory_screen.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// Keeping something, and finding it again.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          curriculumSeedProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String tab) async {
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }

  Future<void> keep(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.bookmark_border).first);
    await tester.pumpAndSettle();
  }

  /// Keeps the one row named, rather than whichever happens to be at the top.
  Future<void> keepNamed(WidgetTester tester, String name) async {
    await tester.tap(
      find.descendant(
        of: find.ancestor(of: find.text(name), matching: find.byType(Card)),
        matching: find.byIcon(Icons.bookmark_border),
      ),
    );
    await tester.pumpAndSettle();
  }

  screenTest('a scale kept in the theory browser is kept as itself', (
    tester,
  ) async {
    await pump(tester, const TheoryScreen());
    await openTab(tester, 'Scales');
    await keep(tester);

    // Filled straight away, from the database rather than from a flag held in the
    // widget: the same scale reads as kept wherever it is shown next.
    expect(find.byIcon(Icons.bookmark), findsOne);

    await pump(tester, const BookmarksScreen());

    expect(find.text('C major'), findsOne);
    expect(find.text('Scale'), findsOne);
  });

  screenTest('and keeping it twice stops keeping it', (tester) async {
    await pump(tester, const TheoryScreen());
    await openTab(tester, 'Scales');
    await keep(tester);
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();

    await pump(tester, const BookmarksScreen());

    expect(find.text('Nothing kept yet'), findsOne);
  });

  screenTest('a kept progression remembers the key it was read in', (
    tester,
  ) async {
    await pump(tester, const TheoryScreen());
    await openTab(tester, 'Progressions');
    // By name: the list opens on Three chords, and Pop is the one with a chord
    // outside the three that would tell a key apart.
    await keepNamed(tester, 'Pop');

    await pump(tester, const BookmarksScreen());

    // The numbers alone are not chords, so the key is part of what was kept.
    expect(find.text('Pop in C major'), findsOne);
    expect(find.text('Progression'), findsOne);

    await tester.tap(find.text('Pop in C major'));
    await tester.pumpAndSettle();

    // Opened as the neck rather than as a screen of its own: the four chords of the
    // progression, drawn the way a lesson draws them.
    expect(find.text('On the neck'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'Am'), findsOne);
  });

  screenTest('a scale kept as a mode is listed as one', (tester) async {
    await pump(tester, const TheoryScreen());
    await openTab(tester, 'Scales');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dorian'));
    await tester.pumpAndSettle();
    await keep(tester);

    await pump(tester, const BookmarksScreen());

    // The same string as a scale, resolved the same way. What differs is the list: a
    // player working through the modes of C gets seven rows they can tell apart.
    expect(find.text('C Dorian'), findsOne);
    expect(find.text('Mode'), findsOne);
    expect(find.text('Scale'), findsNothing);
  });

  screenTest('a chord is kept as the key spells it', (tester) async {
    await pump(tester, const TheoryScreen());
    await openTab(tester, 'Substitutions');
    await keep(tester);

    await pump(tester, const BookmarksScreen());

    expect(find.text('Cmaj7'), findsOne);
    expect(find.text('Chord'), findsOne);
  });

  screenTest('a swap is kept saying what it stands in for', (tester) async {
    await pump(tester, const TheoryScreen());
    await openTab(tester, 'Substitutions');
    await keepNamed(tester, 'Am');

    await pump(tester, const BookmarksScreen());

    // `Am` on its own is a chord. The label carries the half the engine cannot work
    // out again - which chord the player was looking for something to replace.
    expect(find.text('Am for Cmaj7'), findsOne);
    expect(find.text('Substitution'), findsOne);

    await tester.tap(find.text('Am for Cmaj7'));
    await tester.pumpAndSettle();

    // Drawn as the chord that would actually be played, which is what makes the swap
    // worth keeping rather than reading.
    expect(find.text('On the neck'), findsOne);
    expect(find.text('Am'), findsOne);
  });

  screenTest('a bookmark can be dropped from the list it is in', (
    tester,
  ) async {
    await bookmarkRepository(database).addBookmark(
      target: BookmarkTarget.scale,
      targetKey: 'A dorian',
      label: 'A dorian',
    );

    await pump(tester, const BookmarksScreen());
    await tester.tap(find.byIcon(Icons.bookmark_remove_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Nothing kept yet'), findsOne);
  });

  screenTest('a lesson that is no longer in the curriculum says so', (
    tester,
  ) async {
    await bookmarkRepository(database).addBookmark(
      target: BookmarkTarget.lesson,
      targetKey: 'rhythm-beginner-gone',
      label: 'First Chords',
    );

    await pump(tester, const BookmarksScreen());
    await tester.tap(find.text('First Chords'));
    await tester.pumpAndSettle();

    // An import can drop the course a bookmark points at, and a blank course screen
    // would look like a bug rather than an answer.
    expect(find.text('That lesson is not in the curriculum now.'), findsOne);
  });
}
