import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metronome/providers/metronome_providers.dart';
import '../../metronome/screens/metronome_screen.dart';
import '../providers/academy_providers.dart';

/// The metronome, with the practice it counted credited to the lesson it was opened
/// from.
///
/// A wrapper rather than a change to the metronome itself, and the dependency runs
/// this way round on purpose: the metronome is a tool that knows nothing about
/// lessons, and the Academy is what has an opinion about whose practice a count is.
/// The screen underneath is the same one either way.
///
/// It stands in front of the metronome route whether or not a lesson was named,
/// because the count has to be taken either way. A player who opened the metronome
/// on its own has practised nothing in particular, and leaving their minutes in the
/// controller would credit them to whichever lesson opened it next.
///
/// What gets credited is the counting: the stretches that have finished, plus the
/// one still going up to the moment the screen is left. A metronome left clicking in
/// an empty room stops earning credit when the player walks away from the screen,
/// which is the most this can honestly claim to know.
class PracticeMetronomeScreen extends ConsumerStatefulWidget {
  const PracticeMetronomeScreen({this.lessonId, super.key});

  /// The lesson whose exercise opened it. Null where the metronome was opened as
  /// itself, which counts the time and credits it to nobody.
  final int? lessonId;

  @override
  ConsumerState<PracticeMetronomeScreen> createState() =>
      _PracticeMetronomeScreenState();
}

class _PracticeMetronomeScreenState
    extends ConsumerState<PracticeMetronomeScreen> {
  @override
  Widget build(BuildContext context) => const MetronomeScreen();

  /// Taken as the screen goes rather than in `dispose`, which runs after the
  /// element has been unmounted and is too late to read a provider from.
  @override
  void deactivate() {
    _credit();
    super.deactivate();
  }

  void _credit() {
    final seconds = ref
        .read(metronomeSettingsProvider.notifier)
        .takeCountedSeconds();
    final lessonId = widget.lessonId;
    if (seconds <= 0 || lessonId == null) {
      return;
    }

    // Not awaited, and its failure not shown. The screen is already leaving, so
    // there is nowhere to put a snack bar; and the only ways this fails are a
    // lesson an import removed while the metronome was open and a database being
    // closed, neither of which is worth stopping a player who has just practised.
    ref
        .read(progressRepositoryProvider)
        .addPracticeSeconds(lessonId, seconds)
        .catchError((Object _) {});
  }
}
