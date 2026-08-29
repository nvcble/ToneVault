import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/audio/metronome_provider.dart';
import 'package:tone_vault/core/enums/time_signature.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/metronome/screens/metronome_screen.dart';
import '../support/recording_metronome.dart';

/// The metronome as the player sets it: a tempo, a meter, and a click that follows.
///
/// The metronome itself is a recorder, so what is asserted is what the screen asked to
/// be counted rather than what came out of a speaker.
void main() {
  late RecordingMetronome metronome;

  setUp(() => metronome = RecordingMetronome());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [metronomeProvider.overrideWithValue(metronome)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const MetronomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('opens at a tempo somebody can play at, and counts nothing yet', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('90'), findsOne);
    expect(find.text('4/4'), findsOne);
    expect(find.text('Start'), findsOne);
    expect(metronome.counted, isEmpty);
  });

  testWidgets('starting it counts the bar that is set', (tester) async {
    await pump(tester);

    await tap(tester, find.text('Start'));

    expect(find.text('Stop'), findsOne);
    expect(metronome.last?.bpm, 90);
    expect(metronome.last?.signature, TimeSignature.fourFour);
    expect(metronome.last?.accentFirst, isTrue);
  });

  testWidgets('and stopping it stops the sound', (tester) async {
    await pump(tester);
    await tap(tester, find.text('Start'));

    await tap(tester, find.text('Stop'));

    expect(find.text('Start'), findsOne);
    expect(metronome.stops, 1);
  });

  testWidgets('a nudge moves the tempo a beat at a time', (tester) async {
    await pump(tester);

    await tap(tester, find.byTooltip('A beat faster'));
    await tap(tester, find.byTooltip('A beat faster'));
    await tap(tester, find.byTooltip('A beat slower'));

    expect(find.text('91'), findsOne);
  });

  testWidgets('a change while it is counting is heard at once', (tester) async {
    await pump(tester);
    await tap(tester, find.text('Start'));

    await tap(tester, find.byTooltip('A beat faster'));
    await tap(tester, find.text('3/4'));
    await tap(tester, find.text('Accent the first beat'));

    expect(metronome.counted, hasLength(4));
    expect(metronome.last?.bpm, 91);
    expect(metronome.last?.signature, TimeSignature.threeFour);
    expect(metronome.last?.accentFirst, isFalse);
  });

  testWidgets('and a change while it is silent is only remembered', (
    tester,
  ) async {
    await pump(tester);

    await tap(tester, find.text('5/4'));
    await tap(tester, find.byTooltip('A beat faster'));

    // Nothing counted, because nothing was counting.
    expect(metronome.counted, isEmpty);

    await tap(tester, find.text('Start'));

    expect(metronome.last?.signature, TimeSignature.fiveFour);
    expect(metronome.last?.bpm, 91);
  });

  testWidgets('the meter is drawn as the clicks it will play', (tester) async {
    await pump(tester);

    await tap(tester, find.text('12/8'));

    // Twelve, counted as written: a player learning 12/8 hears all twelve.
    expect(find.byType(Container), findsExactly(12));
  });

  testWidgets('the volume changes without putting the beat back to the top', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, find.text('Start'));

    await tester.drag(find.byType(Slider).last, const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(metronome.volumes, isNotEmpty);
    expect(metronome.volumes.last, lessThan(0.8));
    // Still one bar: the tempo did not change, so nothing was re-rendered.
    expect(metronome.counted, hasLength(1));
  });

  testWidgets('dragging the tempo shows it, and sets it when it is let go', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, find.text('Start'));

    final slider = find.byType(Slider).first;
    final centre = tester.getCenter(slider);
    final gesture = await tester.startGesture(centre);
    await gesture.moveBy(const Offset(60, 0));
    await tester.pumpAndSettle();

    // The number has followed the finger, and nothing has been rendered for it.
    expect(find.text('90'), findsNothing);
    expect(metronome.counted, hasLength(1));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(metronome.counted, hasLength(2));
    expect(metronome.last!.bpm, greaterThan(90));
  });

  testWidgets('a device that will not count says so', (tester) async {
    metronome.failure = const AppFailure('No sound on this device.');
    await pump(tester);

    await tap(tester, find.text('Start'));

    expect(find.text('No sound on this device.'), findsOne);
    // Left stopped, because it is not counting.
    expect(find.text('Start'), findsOne);
  });
}
