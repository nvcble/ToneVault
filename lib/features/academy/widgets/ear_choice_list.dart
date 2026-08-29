import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/ear_session.dart';

/// What may be answered, as one button each.
///
/// Buttons rather than a radio list and a submit: an answer is a single tap, because a
/// player is doing this between other things and every extra tap is a reason to stop.
///
/// Once answered the buttons stay on screen and colour themselves - the right one green
/// whether or not it was chosen, a wrong choice red - so the player sees what they
/// picked against what it was, which is the moment the learning happens.
class EarChoiceList extends StatelessWidget {
  const EarChoiceList({
    required this.session,
    required this.onChoose,
    super.key,
  });

  final EarSession session;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final question = session.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < question.choices.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _Choice(
              label: question.choices[index],
              state: _stateOf(index),
              onPressed: () => onChoose(index),
            ),
          ),
      ],
    );
  }

  _ChoiceState _stateOf(int index) {
    if (!session.answered) {
      return _ChoiceState.open;
    }
    if (index == session.question.answer) {
      return _ChoiceState.right;
    }
    return index == session.chosen ? _ChoiceState.wrong : _ChoiceState.spent;
  }
}

enum _ChoiceState { open, right, wrong, spent }

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.state,
    required this.onPressed,
  });

  final String label;
  final _ChoiceState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colour = switch (state) {
      _ChoiceState.open => null,
      _ChoiceState.right => Colors.green,
      _ChoiceState.wrong => scheme.error,
      // Not wrong, just not what was asked about - so it recedes rather than accuses.
      _ChoiceState.spent => scheme.outline,
    };

    return OutlinedButton(
      // Answering twice cannot change a marked answer, so the button says so by
      // going dead rather than by looking live and doing nothing.
      onPressed: state == _ChoiceState.open ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
        disabledForegroundColor: colour,
        side: colour == null ? null : BorderSide(color: colour),
      ),
      child: Text(label),
    );
  }
}
