import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ear_drill.dart';
import '../data/ear_question.dart';
import '../data/ear_questions.dart';
import '../data/ear_session.dart';

/// Where the questions come from.
///
/// A provider rather than a `Random` made on the spot, so a test can override it with
/// a seed and know which chord is about to be played. Nothing else about the drills
/// needs faking: they are pure functions of this and the drill.
final Provider<Random> earRandomProvider = Provider<Random>((ref) => Random());

/// One drill being worked through.
///
/// Kept per drill and thrown away when the screen closes, which is what a sitting is.
/// Coming back later starts a fresh run rather than resuming a score from a session
/// the player has forgotten.
final AutoDisposeStateNotifierProviderFamily<
  EarSessionController,
  EarSession,
  EarDrill
>
earSessionProvider = StateNotifierProvider.autoDispose
    .family<EarSessionController, EarSession, EarDrill>(
      (ref, drill) =>
          EarSessionController(drill, random: ref.watch(earRandomProvider)),
    );

/// The drill's rules applied: answer this one, then ask another.
class EarSessionController extends StateNotifier<EarSession> {
  EarSessionController(EarDrill drill, {required Random random})
    : _random = random,
      super(_opening(drill, random));

  final Random _random;

  /// Ignored once the question has been answered, so a second tap cannot change an
  /// answer that has already been marked - or count it twice.
  void answer(int choice) {
    if (!state.answered) {
      state = state.answering(choice);
    }
  }

  void next() => state = state.asking(questionFor(state.drill, _random));

  static EarSession _opening(EarDrill drill, Random random) => EarSession(
    drill: drill,
    question: questionFor(drill, random),
    asked: 1,
    right: 0,
  );
}

/// The question on screen, for the widgets that only need that much.
final AutoDisposeProviderFamily<EarQuestion, EarDrill> earQuestionProvider =
    Provider.autoDispose.family<EarQuestion, EarDrill>(
      (ref, drill) => ref.watch(earSessionProvider(drill)).question,
    );
