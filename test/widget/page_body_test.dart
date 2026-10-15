import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/shared/widgets/page_body.dart';

/// Keeping a page readable on a screen wider than the one column it was built
/// for - a phone held sideways, or a tablet.
void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageBody(child: ListTile(title: Text('A row'))),
        ),
      ),
    );
  }

  double widthOfRow(WidgetTester tester) =>
      tester.getSize(find.byType(ListTile)).width;

  testWidgets('holds the content to one column on a wide screen', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1000, 500));

    expect(widthOfRow(tester), 640);
  });

  testWidgets('leaves a phone held upright exactly as it was', (tester) async {
    await pumpAt(tester, const Size(400, 800));

    expect(widthOfRow(tester), 400);
  });
}
