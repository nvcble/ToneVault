import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A widget test that ends by taking the tree down.
///
/// Screens that watch real drift streams leave one behind: drift closes a
/// cancelled stream on a zero-duration timer, and the binding refuses to end a
/// test with a timer outstanding. A `tearDown` runs too late to let it fire, so
/// the tree comes down inside the test instead and the last `pumpAndSettle`
/// drains it.
///
/// Used by the tests that watch the Academy's own tables. Anything that pumps a
/// screen backed by a live database wants it.
void screenTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
