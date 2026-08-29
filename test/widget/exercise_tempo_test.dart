import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tone_vault/app/router/routes.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/audio/metronome_provider.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/time_signature.dart';
import 'package:tone_vault/features/academy/widgets/exercise_tempo.dart';
import 'package:tone_vault/features/metronome/screens/metronome_screen.dart';
import '../support/recording_metronome.dart';

/// An exercise handing its tempo to the metronome.
///
/// Two screens rather than one, because the point of the button is that the metronome
/// is already on the exercise's tempo by the time the player sees it.
void main() {
  late RecordingMetronome metronome;

  setUp(() => metronome = RecordingMetronome());

  AcademyExercise exercise({
    int startBpm = 60,
    int targetBpm = 100,
    TimeSignature signature = TimeSignature.threeFour,
  }) {
    final now = DateTime(2026);
    return AcademyExercise(
      id: 1,
      lessonId: 1,
      title: 'One chord a bar',
      instructions: 'Strum on beat one and change on the next bar.',
      startBpm: startBpm,
      targetBpm: targetBpm,
      timeSignature: signature,
      position: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pump(WidgetTester tester, AcademyExercise played) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [metronomeProvider.overrideWithValue(metronome)],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    Scaffold(body: ExerciseTempo(exercise: played)),
              ),
              GoRoute(
                path: Routes.metronome,
                builder: (context, state) => const MetronomeScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an exercise says both of its tempos and its meter', (
    tester,
  ) async {
    await pump(tester, exercise());

    expect(find.textContaining('60 to 100 BPM'), findsOne);
    expect(find.textContaining('3/4'), findsOne);
  });

  testWidgets('and one tempo when that is all it asks for', (tester) async {
    await pump(tester, exercise(startBpm: 80, targetBpm: 80));

    expect(find.textContaining('80 BPM'), findsOne);
    expect(find.textContaining('80 to'), findsNothing);
  });

  testWidgets('counting it opens the metronome already set to it', (
    tester,
  ) async {
    await pump(tester, exercise());

    await tester.tap(find.text('Count 60'));
    await tester.pumpAndSettle();

    // The tempo to start from, not the one to work towards.
    expect(find.widgetWithText(AppBar, 'Metronome'), findsOne);
    expect(find.text('60'), findsOne);
    expect(find.text('3/4'), findsOne);
  });

  testWidgets('and leaves it to the player to start it', (tester) async {
    await pump(tester, exercise());

    await tester.tap(find.text('Count 60'));
    await tester.pumpAndSettle();

    // Arriving to a click already going would be startling, and the player may still
    // want to change the meter or the volume first.
    expect(find.text('Start'), findsOne);
    expect(metronome.counted, isEmpty);
  });

  testWidgets('a change of exercise is heard while it is counting', (
    tester,
  ) async {
    await pump(tester, exercise());
    await tester.tap(find.text('Count 60'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Count 60'));
    await tester.pumpAndSettle();

    // Still counting, because leaving the metronome does not stop it, and presetting
    // a tempo it is already on re-renders the bar rather than pretending nothing
    // happened.
    expect(find.text('Stop'), findsOne);
    expect(metronome.last?.bpm, 60);
    expect(metronome.last?.signature, TimeSignature.threeFour);
  });
}
