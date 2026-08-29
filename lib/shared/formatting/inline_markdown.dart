import 'package:flutter/painting.dart';

/// The one piece of markdown the app renders inside a line: `**bold**`.
///
/// A lesson is written as markdown because that is how prose with emphasis in it is
/// written, and a chord name or a fret number that has to stand out in the middle of
/// a sentence needs marking somehow. Bold is all of it - no links, no images, no
/// nested emphasis - so a hand-rolled split is honest here where a markdown
/// dependency would bring a parser for a language the curriculum does not use.
///
/// An unclosed `**` is left as text. A lesson with a typo in it should read slightly
/// wrong, not disappear.
List<TextSpan> inlineMarkdown(String text) {
  final parts = text.split('**');

  // An even number of pieces means an odd number of markers, so the last one was
  // never closed. Joining the tail back on with its marker keeps every character the
  // author wrote and leaves it unemphasised.
  if (parts.length.isEven) {
    final unclosed = parts.removeLast();
    parts[parts.length - 1] = '${parts.last}**$unclosed';
  }

  return [
    for (final (index, part) in parts.indexed)
      if (part.isNotEmpty)
        TextSpan(
          text: part,
          style: index.isOdd
              ? const TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
  ];
}
