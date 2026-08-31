import '../../../app/router/routes.dart';
import 'theory_tab.dart';

/// The named things the theory browser teaches, and where each of them is.
///
/// One list, used twice: it is the row of shortcuts on the Academy dashboard and it is
/// what a search matches when a player types the name of a topic rather than the name of
/// a chord. Two lists would drift, and a topic reachable by search but not by tapping is
/// a topic a player cannot find.
class TheoryTopic {
  const TheoryTopic({
    required this.title,
    required this.blurb,
    required this.route,
    this.keywords = const [],
  });

  final String title;

  /// One line saying what the topic answers, for the dashboard tile.
  final String blurb;

  final String route;

  /// The other words a player might come looking for this by. The title is always
  /// searched, so these are only what it is not called.
  final List<String> keywords;

  /// Whether a typed query is asking for this topic. Matched loosely and in lower case,
  /// because a player searching for "roman numerals" should not have to know the app
  /// filed them under chord families.
  bool matches(String query) {
    final wanted = query.trim().toLowerCase();
    if (wanted.isEmpty) {
      return false;
    }
    return title.toLowerCase().contains(wanted) ||
        keywords.any((keyword) => keyword.contains(wanted));
  }
}

/// Keywords are lower case here so [TheoryTopic.matches] does not have to lower them on
/// every keystroke of every search.
final List<TheoryTopic> theoryTopics = [
  TheoryTopic(
    title: 'Chord families',
    blurb: 'The chords a key is built from, numbered.',
    route: Routes.academyTheoryTab(TheoryTab.chords),
    keywords: const [
      'diatonic chords',
      'roman numerals',
      'chords of a key',
      'one four five',
      'triads',
    ],
  ),
  TheoryTopic(
    title: 'CAGED shapes',
    blurb: 'One chord in the five shapes that climb the neck.',
    route: Routes.academyTheoryTab(TheoryTab.caged),
    keywords: const [
      'caged',
      'moveable shapes',
      'barre',
      'up the neck',
      'shape rotation',
    ],
  ),
  TheoryTopic(
    title: 'Nashville numbers',
    blurb: 'Chords called by where they sit, in any key.',
    route: Routes.academyTheoryNashville,
    keywords: const [
      'number system',
      'numbers',
      '1 5 6 4',
      'transpose',
      'charts',
    ],
  ),
  TheoryTopic(
    title: 'Progressions',
    blurb: 'The changes songs are made of, in three notations.',
    route: Routes.academyTheoryTab(TheoryTab.progressions),
    keywords: const ['changes', 'turnaround', 'cadence', 'twelve bar'],
  ),
  TheoryTopic(
    title: 'Modes',
    blurb: 'Every scale and mode on one root, on the neck.',
    route: Routes.academyTheoryTab(TheoryTab.scales),
    keywords: const [
      'scales',
      'modal',
      'parent scale',
      'pentatonic',
      'fretboard',
    ],
  ),
  TheoryTopic(
    title: 'Circle of fifths',
    blurb: 'Combine notes into a chord, and the way round onto it.',
    route: Routes.academyTheoryTab(TheoryTab.circle),
    keywords: const [
      'key signatures',
      'relative minor',
      'sharps',
      'flats',
      'fifths',
      'name a chord',
      'what chord is this',
    ],
  ),
  TheoryTopic(
    title: 'Substitutions',
    blurb: 'What can be played instead, and the reason it works.',
    route: Routes.academyTheoryTab(TheoryTab.substitutions),
    keywords: const [
      'tritone',
      'swap',
      'reharmonise',
      'reharmonize',
      'secondary dominant',
    ],
  ),
];
