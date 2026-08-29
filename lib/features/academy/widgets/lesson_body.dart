import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatting/inline_markdown.dart';

/// The text of a lesson, as paragraphs and lists.
///
/// A lesson is stored as markdown and rendered here by hand, because the markdown it
/// uses is three things: blank lines between paragraphs, lines beginning `- ` or `1.`
/// for a list, and `**bold**` inside a line. Everything else in a lesson is words.
///
/// What arrives with something outside that is shown as it was written rather than
/// hidden. A stray character in a curriculum file is a blemish; a lesson that will
/// not display is a lesson that cannot be learned.
class LessonBody extends StatelessWidget {
  const LessonBody({required this.lesson, super.key});

  final AcademyLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = lesson.body.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          if (block.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _block(block.trim(), theme.textTheme.bodyMedium),
            ),
      ],
    );
  }

  /// A block is a list if any of its lines opens like one. Mixed blocks are rare and
  /// come out as a list of one-line items, which reads the same either way.
  Widget _block(String block, TextStyle? style) {
    final lines = block.split('\n');
    if (!lines.any(_opensAList)) {
      return Text.rich(TextSpan(children: inlineMarkdown(block)), style: style);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text.rich(
              TextSpan(children: inlineMarkdown(_bulleted(line.trim()))),
              style: style,
            ),
          ),
      ],
    );
  }

  /// A dash or a number and a dot, which is how both kinds of list are written.
  static bool _opensAList(String line) {
    final trimmed = line.trimLeft();
    return trimmed.startsWith('- ') || RegExp(r'^\d+\.\s').hasMatch(trimmed);
  }

  /// The dash becomes a real bullet. A numbered line keeps its number, because the
  /// numbers in a lesson mean the order the steps are done in.
  static String _bulleted(String line) =>
      line.startsWith('- ') ? '• ${line.substring(2)}' : line;
}
