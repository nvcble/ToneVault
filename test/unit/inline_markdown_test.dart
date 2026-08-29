import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/shared/formatting/inline_markdown.dart';

/// The one piece of markdown a lesson is rendered with.
void main() {
  /// What the spans say, and which of them are bold, as one readable expectation.
  List<(String, bool)> spansOf(String text) => inlineMarkdown(text)
      .map(
        (span) => (span.text ?? '', span.style?.fontWeight == FontWeight.bold),
      )
      .toList();

  test('plain text comes back as one span', () {
    expect(spansOf('Two fingers, moved across one string.'), [
      ('Two fingers, moved across one string.', false),
    ]);
  });

  test('a bold run is bold and the words around it are not', () {
    expect(spansOf('The chords are **A7, D7 and E7** in the blues.'), [
      ('The chords are ', false),
      ('A7, D7 and E7', true),
      (' in the blues.', false),
    ]);
  });

  test('a line that is nothing but a bold run has no empty spans in it', () {
    expect(spansOf('**Em**'), [('Em', true)]);
  });

  test('two bold runs in one line are both bold', () {
    expect(spansOf('**Em** then **Am**'), [
      ('Em', true),
      (' then ', false),
      ('Am', true),
    ]);
  });

  test('an unclosed marker is shown as it was typed', () {
    // A typo in a lesson should look slightly wrong, not swallow the rest of the
    // sentence or throw on the way to the screen.
    expect(spansOf('Start on the **fifth fret'), [
      ('Start on the **fifth fret', false),
    ]);
  });

  test('empty text comes back with nothing in it', () {
    expect(inlineMarkdown(''), isEmpty);
  });
}
