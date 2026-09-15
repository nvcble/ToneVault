import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/midi/widgets/patch_grid_tile.dart';
import 'package:tone_vault/features/midi/widgets/patch_number_carousel.dart';

/// The grid a patch is picked from on the redesigned control landing page -
/// 20 slots a page, sliding rather than cutting between pages.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    int selected = 0,
    Map<int, String> names = const {},
    ValueChanged<int>? onSelected,
    ValueChanged<int>? onLoad,
  }) async {
    tester.view.physicalSize = const Size(500, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatchNumberCarousel(
            selected: selected,
            patchNames: names,
            onSelected: onSelected ?? (_) {},
            onLoad: onLoad ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows 20 tiles a page, numbered from 1', (tester) async {
    await pump(tester);

    expect(find.byType(PatchGridTile), findsNWidgets(20));
    expect(find.text('01'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Page 1 of 7'), findsOneWidget);
  });

  testWidgets('a known patch name replaces the generic slot label', (tester) async {
    await pump(tester, names: {0: 'Core Lead'});

    expect(find.text('Core Lead'), findsOneWidget);
    expect(find.text('Patch 1'), findsNothing);
    // Every other slot on the page still falls back to the generic label.
    expect(find.text('Patch 2'), findsOneWidget);
  });

  testWidgets('the chevrons slide to the next and previous page', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 of 7'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 7'), findsOneWidget);
  });

  testWidgets('the last page holds only the slots left over', (tester) async {
    await pump(tester);

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }

    expect(find.text('Page 7 of 7'), findsOneWidget);
    // 120 full pages of 20 leaves 8 slots: 121-128.
    expect(find.byType(PatchGridTile), findsNWidgets(8));
    expect(find.text('128'), findsOneWidget);
    // Nothing left to page forward to.
    expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right)).onPressed, isNull);
  });

  testWidgets('opens on the page holding the selected slot', (tester) async {
    await pump(tester, selected: 25); // 0-based -> display 26, on page 2

    expect(find.text('Page 2 of 7'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
  });

  testWidgets('a single tap only pre-selects, reporting its 0-based number', (tester) async {
    int? selected;
    int? loaded;
    await pump(tester, onSelected: (number) => selected = number, onLoad: (number) => loaded = number);

    await tester.tap(find.text('05'));
    // Nothing else tapped within the double-tap window, so it resolves to a
    // single tap rather than staying undecided.
    await tester.pumpAndSettle(kDoubleTapTimeout);

    expect(selected, 4);
    expect(loaded, isNull);
  });

  testWidgets('a double tap loads the tile, not just pre-selects it', (tester) async {
    int? loaded;
    await pump(tester, onLoad: (number) => loaded = number);

    await tester.tap(find.text('05'));
    await tester.pump(kDoubleTapTimeout ~/ 2);
    await tester.tap(find.text('05'));
    await tester.pumpAndSettle();

    expect(loaded, 4);
  });
}
