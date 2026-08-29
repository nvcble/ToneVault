import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import 'package:tone_vault/features/academy/data/curriculum_summary.dart';
import '../support/curriculum_document_fixture.dart';

/// What the app says about a curriculum file, before and after it is written.
///
/// Wording rather than decoration. These sentences are the whole of what the user has
/// to go on when deciding whether to let a file rewrite courses they have been
/// practising, so "2 courses left as it was" is a real fault and not a typo.
void main() {
  group('what a file holds', () {
    test('is counted in courses and lessons', () {
      final courses = decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(
                  lessons: [
                    lessonMap(slug: 'em', title: 'Em'),
                    lessonMap(slug: 'am', title: 'Am'),
                  ],
                ),
                moduleMap(slug: 'changes', title: 'Changes'),
              ],
            ),
            courseMap(slug: 'lead-beginner-first-notes', path: 'lead'),
          ],
        ),
      );

      final tally = tallyCurriculum(courses);
      expect(tally.courses, 2);
      expect(tally.modules, 3);
      expect(tally.lessons, 4);
      expect(
        describeCurriculum(courses),
        'That file holds 2 courses and 4 lessons.',
      );
    });

    test('and reads as one where there is one of each', () {
      expect(
        describeCurriculum(decodeCurriculum(curriculumJson())),
        'That file holds 1 course and 1 lesson.',
      );
    });
  });

  group('what would be replaced', () {
    test('is named, singly', () {
      final said = describeOverwrite(['First Chords']);

      expect(said, contains('"First Chords"'));
      expect(said, contains('Bringing it up to date'));
      // The reassurance belongs in the same breath as the warning: a player who has
      // put hours in wants to know they are not losing them.
      expect(said, contains('Your practice against them is kept.'));
    });

    test('and named together where there are a few', () {
      final said = describeOverwrite(['First Chords', 'First Notes']);

      expect(said, contains('"First Chords", "First Notes"'));
      expect(said, contains('Bringing them up to date'));
    });

    test('and counted past the point of naming them all', () {
      final said = describeOverwrite(['One', 'Two', 'Three', 'Four', 'Five']);

      // Three, then a count. A dialog listing twenty course titles is a dialog
      // nobody reads to the end of.
      expect(said, contains('"One", "Two", "Three" and 2 more'));
      expect(said, isNot(contains('"Four"')));
    });
  });

  group('what an import did', () {
    test('says each of the three that happened', () {
      expect(
        describeImported((added: 2, updated: 1, kept: 3)),
        '2 courses added, 1 course brought up to date, 3 courses left as they were.',
      );
    });

    test('and leaves out the ones that did not', () {
      expect(
        describeImported((added: 1, updated: 0, kept: 0)),
        '1 course added.',
      );
      expect(
        describeImported((added: 0, updated: 0, kept: 1)),
        '1 course left as it was.',
      );
    });

    test('and says so plainly where nothing happened at all', () {
      // Reachable: a file of courses this app already has, imported with "keep mine",
      // counts nothing but is not a failure.
      expect(
        describeImported((added: 0, updated: 0, kept: 0)),
        'Nothing to import.',
      );
    });
  });
}
