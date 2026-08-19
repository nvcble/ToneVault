import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/history/screens/history_screen.dart';
import 'package:tone_vault/features/history/widgets/pedal_history_view.dart';

/// The timeline as the user reads it. What gets recorded is covered by
/// change_history_test.dart, and how an entry reads by change_summary_test.dart.
void main() {
  const int pedalId = 7;

  final volume = PedalControl(
    id: 3,
    pedalId: pedalId,
    name: 'Volume',
    controlType: ControlType.clock,
    minValue: 0,
    maxValue: 1,
    displayOrder: 0,
  );

  PedalChange change({
    int id = 1,
    String pedalName = 'Caline PureSky',
    String? reason,
  }) {
    return (
      entry: ChangeLog(
        id: id,
        pedalId: pedalId,
        configurationName: 'Worship Lead',
        controlName: 'Volume',
        changeType: ChangeType.controlValueChanged,
        oldValue: 0.25,
        newValue: 0.75,
        reason: reason,
        createdAt: DateTime(2026, 8, 19, 14, 5),
      ),
      pedalName: pedalName,
      control: volume,
    );
  }

  Future<void> pump(WidgetTester tester, Widget screen, Override override) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [override],
        child: MaterialApp(home: screen),
      ),
    );
  }

  /// The whole collection's timeline.
  Future<void> pumpHistoryTab(
    WidgetTester tester,
    List<PedalChange> changes,
  ) async {
    await pump(
      tester,
      const HistoryScreen(),
      recentHistoryProvider.overrideWith((ref) => Stream.value(changes)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('says nothing has been logged when the timeline is empty', (
    tester,
  ) async {
    await pumpHistoryTab(tester, []);

    expect(find.text('Nothing logged yet'), findsOne);
  });

  testWidgets('reads out a change with its pedal, setting and reason', (
    tester,
  ) async {
    await pumpHistoryTab(tester, [
      change(reason: 'needed more saturation for lead'),
    ]);

    expect(find.text('Volume moved from 9:30 to 2:30'), findsOne);
    expect(
      find.text('Caline PureSky · Worship Lead · 2026-08-19 14:05'),
      findsOne,
    );
    expect(find.text('needed more saturation for lead'), findsOne);
  });

  testWidgets('admits when there is older history than it is showing', (
    tester,
  ) async {
    await pumpHistoryTab(tester, [
      for (var index = 0; index < historyPageSize; index++)
        change(id: index + 1),
    ]);

    // The note sits at the end of a full page, so it has to be scrolled to.
    await tester.scrollUntilVisible(
      find.text('Showing the $historyPageSize most recent changes.'),
      300,
    );
    expect(
      find.text('Showing the $historyPageSize most recent changes.'),
      findsOne,
    );
  });

  testWidgets('leaves the pedal name off a single pedal\'s own history', (
    tester,
  ) async {
    await pump(
      tester,
      // The real one is a tab inside the pedal's own scaffold.
      const Scaffold(body: PedalHistoryView(pedalId: pedalId)),
      pedalHistoryProvider(
        pedalId,
      ).overrideWith((ref) => Stream.value([change()])),
    );
    await tester.pumpAndSettle();

    // The pedal is named in the app bar above this tab already.
    expect(find.text('Worship Lead · 2026-08-19 14:05'), findsOne);
    expect(find.textContaining('Caline PureSky'), findsNothing);
  });
}
