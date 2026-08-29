import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/audio/tone_player.dart';
import '../../../core/audio/tone_player_provider.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/ear_drill.dart';
import '../providers/ear_training_providers.dart';
import '../widgets/ear_answer_card.dart';
import '../widgets/ear_choice_list.dart';

/// One drill, one question at a time.
///
/// The sound plays itself on the way in and again after every question, because the
/// player came here to listen and asking them to press play first would put a tap
/// between them and the thing they are training. It can be replayed as often as they
/// like: hearing it four times is practice, not cheating.
class EarDrillScreen extends ConsumerStatefulWidget {
  const EarDrillScreen({required this.drill, super.key});

  final EarDrill drill;

  @override
  ConsumerState<EarDrillScreen> createState() => _EarDrillScreenState();
}

class _EarDrillScreenState extends ConsumerState<EarDrillScreen> {
  /// Held rather than read on demand, so leaving the screen can silence it from
  /// `dispose`, where reading a provider is no longer safe.
  late final TonePlayer _player;

  @override
  void initState() {
    super.initState();
    _player = ref.read(tonePlayerProvider);
    // After the first frame: a failure here wants a snack bar, and there is no
    // Scaffold to hang one on until the screen has been laid out once.
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(earSessionProvider(widget.drill));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drill.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(session.score, style: theme.textTheme.titleMedium),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(session.question.prompt, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _play,
            icon: const Icon(Icons.volume_up_outlined),
            label: const Text('Play it again'),
          ),
          const SizedBox(height: AppSpacing.lg),
          EarChoiceList(session: session, onChoose: _answer),
          if (session.answered) ...[
            const SizedBox(height: AppSpacing.sm),
            EarAnswerCard(session: session, onNext: _next),
          ],
        ],
      ),
    );
  }

  void _answer(int choice) =>
      ref.read(earSessionProvider(widget.drill).notifier).answer(choice);

  void _next() {
    ref.read(earSessionProvider(widget.drill).notifier).next();
    _play();
  }

  /// A failure here is worth a snack bar and nothing else. A device with no sound
  /// output still shows the question, and a player who knows what a G sounds like can
  /// answer it from the explanation afterwards.
  Future<void> _play() async {
    try {
      await ref
          .read(earSessionProvider(widget.drill))
          .question
          .sound
          .playOn(_player);
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
