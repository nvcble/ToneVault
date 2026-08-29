import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/data/theory_search.dart';

/// Searching the theory the browser derives, rather than a table of it.
///
/// Everything here is worked out from the query and the key, so there is nothing to seed
/// and nothing to stub: what a test sets up is the words and the key they are read in.
void main() {
  final c = Scale(PitchClass(0), ScaleType.major);
  final eb = Scale(PitchClass(3), ScaleType.major);
  final aMinor = Scale(PitchClass(9), ScaleType.minor);

  List<String> titles(String query, {Scale? key}) => [
    for (final found in searchTheory(query, key: key ?? c)) found.title,
  ];

  List<String> kinds(String query, {Scale? key}) => [
    for (final found in searchTheory(query, key: key ?? c)) found.kind,
  ];

  group('what is not a search yet', () {
    test('a single letter answers with nothing', () {
      // Otherwise the first keystroke fills the screen, and `a` is the name of a key.
      expect(searchTheory('a', key: c), isEmpty);
      expect(searchTheory('', key: c), isEmpty);
      expect(searchTheory('   ', key: c), isEmpty);
    });

    test('and a word nothing is called finds nothing', () {
      expect(searchTheory('zzzz', key: c), isEmpty);
    });
  });

  group('a scale by name', () {
    test('is offered on the key being read in', () {
      expect(titles('minor pentatonic'), ['C minor pentatonic']);
      expect(titles('minor pentatonic', key: eb), ['Eb minor pentatonic']);
    });

    test('by a name a player uses for it rather than its own', () {
      // The resolver's own aliases, so a search and a lesson agree what aeolian is.
      expect(titles('aeolian'), ['C minor']);
      expect(titles('octatonic'), ['C diminished']);
    });

    test('and a mode says it is one', () {
      expect(kinds('dorian'), ['Mode']);
      expect(kinds('harmonic minor'), contains('Scale'));
    });
  });

  group('a chord', () {
    test('written with its own root is read as itself', () {
      // First, and on the root it names: a player who typed F#m7b5 meant that chord and
      // not the one the browser's key happens to build.
      expect(titles('F#m7b5').first, 'F#m7b5');
    });

    test('written as a quality is built on the key', () {
      expect(titles('m7b5', key: eb), contains('Ebm7b5'));
      expect(titles('m7b5', key: eb), isNot(contains('Cm7b5')));
    });

    test('is found by what it is called as well as how it is written', () {
      expect(titles('half diminished'), contains('Cm7b5'));
      expect(kinds('half diminished'), contains('Chord'));
    });

    test('and a bare root is the chord of that root', () {
      expect(titles('Bb').first, 'Bb');
      expect(kinds('Bb').first, 'Chord');
    });
  });

  group('an interval', () {
    test('is offered by its name, on the key being read in', () {
      expect(titles('perfect 5th'), contains('C perfect 5th'));
      expect(titles('perfect 5th', key: eb), contains('Eb perfect 5th'));
      expect(kinds('perfect 5th'), contains('Interval'));
    });

    test('by the other words players use for the same distance', () {
      // Found by what it was typed as and offered under what the engine calls it,
      // which is how a player learns that those are the same distance.
      expect(titles('flat 5th'), contains('C tritone'));
      expect(titles('whole step'), contains('C major 2nd'));
    });

    test('and once, however many names it has', () {
      expect(
        titles('tritone').where((title) => title == 'C tritone'),
        hasLength(1),
      );
    });

    test('written with its own note is read as itself', () {
      // The note the player named, not the one the browser's key would build.
      expect(titles('A perfect 5th').first, 'A perfect 5th');
    });
  });

  group('an arpeggio', () {
    test('is asked for by the word, and answered with the key', () {
      // The chords of the key, which are the arpeggios a player practising them works
      // through rather than every quality the engine knows.
      expect(titles('arpeggio'), contains('C arpeggio'));
      expect(titles('arp'), contains('Dm arpeggio'));
      expect(kinds('arpeggio'), contains('Arpeggio'));
    });

    test('or by a quality with the word after it', () {
      expect(titles('m7 arp', key: eb), contains('Ebm7 arpeggio'));
      expect(titles('half diminished arpeggio'), contains('Cm7b5 arpeggio'));
    });

    test('and a chord written out with it is read as itself', () {
      expect(titles('F#m7 arpeggio').first, 'F#m7 arpeggio');
    });

    test('a chord search on its own is not answered with arpeggios as well', () {
      // Every quality is also an arpeggio, and offering both would double a list whose
      // job is to be short enough to read.
      expect(titles('m7b5'), everyElement(isNot(contains('arpeggio'))));
    });
  });

  group('a progression', () {
    test('is found by its name, in the key it would be played in', () {
      expect(titles('pop'), contains('Pop in C major'));
      expect(titles('pop', key: eb), contains('Pop in Eb major'));
    });

    test('and by the numbers it is written with', () {
      expect(titles('1 5 6 4'), contains('Pop in C major'));
      expect(kinds('1 5 6 4'), contains('Progression'));
    });

    test('which carries the key, because numbers alone are not chords', () {
      final found = searchTheory(
        '1 5 6 4',
        key: eb,
      ).whereType<TheoryDiagramFound>();
      expect(found.first.theoryKeys, containsAll(<String>['Eb major']));
    });
  });

  group('a substitution', () {
    test('is found by the reason it works', () {
      expect(titles('tritone'), contains('Db7 for G7'));
      expect(kinds('tritone'), contains('Substitution'));
    });

    test('and reads the key it is being made in', () {
      // Eb major's dominant is Bb7, and a tritone away from that is E7. A minor is
      // deliberately not the example: G7 is the seventh chord of A minor as well, so
      // the swap there is the same one C major offers.
      expect(titles('tritone', key: eb), contains('E7 for Bb7'));
      expect(titles('tritone', key: eb), isNot(contains('Db7 for G7')));
    });
  });

  group('a topic of the browser', () {
    test('is found by what a player would call it', () {
      expect(titles('circle'), contains('Circle of fifths'));
      expect(titles('roman numerals'), contains('Chord families'));
      expect(kinds('circle'), contains('Theory'));
    });

    test('and comes with the route that opens the tab it is on', () {
      final found = searchTheory(
        'circle',
        key: c,
      ).whereType<TheoryTopicFound>().first;

      expect(found.route, contains('tab=circle'));
    });
  });

  group('the shape of an answer', () {
    test('nothing is offered twice', () {
      // `Am` is a chord the resolver reads and a chord the qualities would offer again.
      final found = titles('am', key: aMinor);

      expect(found.toSet().length, found.length);
    });

    test('and a word half the engine answers to is still a list to read', () {
      // `minor` names most of the qualities and half the reasons a swap gives.
      expect(titles('minor').length, lessThan(30));
      expect(titles('minor'), isNotEmpty);
    });
  });
}
