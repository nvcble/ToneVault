import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedalboard_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedalboards/widgets/chain_slot_tile.dart';
import 'package:tone_vault/features/pedalboards/widgets/reorderable_chain_list.dart';
import 'package:tone_vault/features/pedalboards/widgets/rig_chain_view.dart';

/// A rig's chain: how it reads, and what a drag or a removal asks for.
///
/// What the repository does with either is covered by rig_chain_test.dart in
/// test/database; here the question is what the list hands it.
void main() {
  const pedalboardId = 4;
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(
    int id,
    String name, {
    String? brand,
    PedalStatus status = PedalStatus.active,
  }) {
    return Pedal(
      id: id,
      name: name,
      brand: brand,
      type: PedalType.analog,
      category: PedalCategory.overdrive,
      status: status,
      createdAt: moment,
      updatedAt: moment,
    );
  }

  ChainSlot slot(int slotId, Pedal pedal, int position) {
    return (
      slot: PedalboardSlot(
        id: slotId,
        pedalboardId: pedalboardId,
        pedalId: pedal.id,
        position: position,
      ),
      pedal: pedal,
    );
  }

  final chain = [
    slot(10, pedal(1, 'Vox Wah', brand: 'Vox'), 0),
    slot(11, pedal(2, 'Caline PureSky'), 1),
    slot(12, pedal(3, 'Spare OD', status: PedalStatus.backup), 2),
  ];

  /// The pedal names as the chain currently reads, top to bottom.
  List<String> orderOnScreen(WidgetTester tester) {
    return tester
        .widgetList<ChainSlotTile>(find.byType(ChainSlotTile))
        .map((tile) => tile.pedal.name)
        .toList();
  }

  /// Drags the row at [index] down past the one below it, by its own height so
  /// the distance holds whatever the row ends up measuring.
  Future<void> dragDownOneRow(WidgetTester tester, int index) async {
    final rowHeight = tester.getSize(find.byType(ChainSlotTile).first).height;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_handle).at(index)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // In two moves, so the list sees a drag rather than a jump.
    await gesture.moveBy(Offset(0, rowHeight * 0.7));
    await tester.pump();
    await gesture.moveBy(Offset(0, rowHeight * 0.5));
    await tester.pump();

    await gesture.up();
    await tester.pumpAndSettle();
  }

  group('RigChainView', () {
    Future<void> pumpChain(
      WidgetTester tester,
      Stream<List<ChainSlot>> chain,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rigChainProvider(pedalboardId).overrideWith((ref) => chain),
          ],
          child: const MaterialApp(
            home: Scaffold(body: RigChainView(pedalboardId: pedalboardId)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says what a chain is for when the rig is bare', (
      tester,
    ) async {
      await pumpChain(tester, Stream.value(const []));

      expect(find.text('Nothing on this rig yet'), findsOne);
      expect(find.textContaining('from your guitar'), findsOne);
      // Adding one is the only thing to do here, so the button is on screen even
      // with an empty chain.
      expect(find.widgetWithText(FilledButton, 'Add pedal'), findsOne);
    });

    testWidgets('numbers each pedal by where signal reaches it', (
      tester,
    ) async {
      await pumpChain(tester, Stream.value(chain));

      expect(orderOnScreen(tester), ['Vox Wah', 'Caline PureSky', 'Spare OD']);
      expect(find.text('1'), findsOne);
      expect(find.text('3'), findsOne);
      // Whose pedal it is, and anything worth knowing before a gig.
      expect(find.text('Vox'), findsOne);
      expect(find.text('Backup'), findsOne);
      // Every row is draggable and can be taken off.
      expect(find.byIcon(Icons.drag_handle), findsExactly(3));
      expect(find.byIcon(Icons.remove_circle_outline), findsExactly(3));
    });

    testWidgets('keeps a failure readable', (tester) async {
      await pumpChain(tester, Stream<List<ChainSlot>>.error(Exception('disk')));

      expect(find.text('Could not load the chain'), findsOne);
      expect(find.textContaining('disk'), findsNothing);
    });
  });

  group('ReorderableChainList', () {
    List<int>? reordered;
    int? removed;

    setUp(() {
      reordered = null;
      removed = null;
    });

    Future<void> pumpList(
      WidgetTester tester, {
      Future<void> Function(List<int>)? onReorder,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableChainList(
              chain: chain,
              onReorder:
                  onReorder ??
                  (slotIds) async {
                    reordered = slotIds;
                  },
              onRemove: (slotId) async {
                removed = slotId;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a drag asks for the slots in their new signal order', (
      tester,
    ) async {
      await pumpList(tester);

      await dragDownOneRow(tester, 0);

      // The wah now sits second, so the chain is asked for in that order.
      expect(reordered, [11, 10, 12]);
      expect(orderOnScreen(tester), ['Caline PureSky', 'Vox Wah', 'Spare OD']);
    });

    testWidgets('a refused reorder puts the chain back and says why', (
      tester,
    ) async {
      await pumpList(
        tester,
        onReorder: (_) async {
          throw const AppFailure('This rig changed while you were reordering.');
        },
      );

      await dragDownOneRow(tester, 0);

      expect(
        find.text('This rig changed while you were reordering.'),
        findsOne,
      );
      // The database still has the old order, so the list shows it again rather
      // than an arrangement that was never saved.
      expect(orderOnScreen(tester), ['Vox Wah', 'Caline PureSky', 'Spare OD']);
    });

    testWidgets('taking a pedal off names its slot, not the pedal', (
      tester,
    ) async {
      await pumpList(tester);

      await tester.tap(find.byIcon(Icons.remove_circle_outline).at(1));
      await tester.pumpAndSettle();

      // The slot goes; the pedal itself is untouched, which is why the slot id is
      // what gets removed.
      expect(removed, 11);
    });
  });
}
