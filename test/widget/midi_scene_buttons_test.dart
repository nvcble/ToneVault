import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/midi/widgets/midi_scene_buttons.dart';

/// The scene last sent has to look different from the other two, which is
/// the whole reason [MidiSceneButtons] takes a selected scene at all.
void main() {
  Future<void> pump(WidgetTester tester, int? selectedScene) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MidiSceneButtons(
            selectedScene: selectedScene,
            onSelect: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('the selected scene is filled, the other two are outlined', (
    tester,
  ) async {
    await pump(tester, 2);

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(2));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).child,
      isA<Text>().having((text) => text.data, 'data', 'Scene 2'),
    );
  });

  testWidgets('none filled until a scene has been sent', (tester) async {
    await pump(tester, null);

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNWidgets(3));
  });

  testWidgets('a null onSelect disables every button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MidiSceneButtons(selectedScene: 1, onSelect: null),
        ),
      ),
    );

    for (final button in tester.widgetList<FilledButton>(
      find.byType(FilledButton),
    )) {
      expect(button.onPressed, isNull);
    }
    for (final button in tester.widgetList<OutlinedButton>(
      find.byType(OutlinedButton),
    )) {
      expect(button.onPressed, isNull);
    }
  });
}
