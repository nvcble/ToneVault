import '../../../core/music/chord.dart';
import '../../../core/music/chord_family.dart';
import '../../../core/music/chord_type.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_names.dart';
import '../../../core/music/scale_type.dart';
import '../../../core/music/substitution.dart';
import '../../../core/music/theory_query.dart';
import 'progression_chart.dart';
import 'theory_search_shapes.dart';
import 'theory_topics.dart';

/// Something the theory side of the Academy can show, found by a typed word.
///
/// Sealed and two-branched, because there are only two things a result can be: a diagram
/// the engine draws on the spot, or a screen to go to. A search for `Am7` should not have
/// to open a screen to see a chord, and a search for the circle of fifths cannot be
/// answered with a chord box.
sealed class TheoryFound {
  const TheoryFound();

  String get title;

  /// `Chord`, `Scale`, `Mode`, `Progression`, `Substitution`, `Theory`. What the result is,
  /// so a list of them can be read without opening any.
  String get kind;
}

/// A chord, scale, progression or substitution, as the keys that draw it. The same strings
/// a bookmark stores, so a result opens exactly the way a kept one does.
final class TheoryDiagramFound extends TheoryFound {
  const TheoryDiagramFound({
    required this.title,
    required this.kind,
    required this.theoryKeys,
  });

  @override
  final String title;

  @override
  final String kind;

  final List<String> theoryKeys;
}

/// A topic of the browser, with the route that opens it on the right tab.
final class TheoryTopicFound extends TheoryFound {
  const TheoryTopicFound(this.topic);

  final TheoryTopic topic;

  @override
  String get title => topic.title;

  @override
  String get kind => 'Theory';

  String get route => topic.route;
}

/// Enough of one kind to show what the browser has, and not so many that the lessons are
/// pushed off the bottom of the screen.
///
/// A word like `minor` matches most of the chord qualities and half the reasons a
/// substitution gives, and a search that answered it with sixty rows would be hiding the
/// lesson the player was looking for behind the engine showing off.
const int _perKind = 6;

/// What the engine can offer for a typed query, read in [key].
///
/// [key] is the key the browser is on, which is what a bare quality is built on: a player
/// who searches `m7b5` while in Eb is shown Ebm7b5, because that is the chord the tab they
/// came from would show them. A query that names its own root - `F#m7b5` - is read as
/// itself and comes first.
List<TheoryFound> searchTheory(String query, {required Scale key}) {
  final wanted = query.trim().toLowerCase();
  if (wanted.length < 2) {
    return const [];
  }

  final found = <TheoryFound>[];
  final seen = <String>{};

  void add(TheoryFound result) {
    if (seen.add('${result.kind}/${result.title}')) {
      found.add(result);
    }
  }

  final asWritten = resolveTheoryKey(query.trim(), key: key);
  if (asWritten != null) {
    add(
      TheoryDiagramFound(
        title: asWritten.label,
        kind: switch (asWritten) {
          ChordReference() => 'Chord',
          ScaleReference(:final scale) => _scaleKind(scale.type),
          IntervalReference() => 'Interval',
          ArpeggioReference() => 'Arpeggio',
          ProgressionReference() => 'Progression',
        },
        theoryKeys: switch (asWritten) {
          ProgressionReference(:final written) => [key.label, written],
          _ => [asWritten.label],
        },
      ),
    );
  }

  for (final topic in theoryTopics) {
    if (topic.matches(wanted)) {
      add(TheoryTopicFound(topic));
    }
  }

  _addScales(add, wanted, key);
  _addChords(add, wanted, key);
  addIntervals(add, wanted, key, limit: _perKind);
  addArpeggios(add, wanted, key, limit: _perKind);
  _addProgressions(add, wanted, key);
  _addSubstitutions(add, wanted, key);

  return found;
}

String _scaleKind(ScaleType type) => type.isMode ? 'Mode' : 'Scale';

/// Every scale whose name - its own or one a player uses for it - has the query in it,
/// built on the key's root.
void _addScales(void Function(TheoryFound) add, String wanted, Scale key) {
  final names = scaleTypeNames;
  var offered = 0;
  for (final type in ScaleType.values) {
    if (offered == _perKind) {
      return;
    }
    final named = names.entries.any(
      (entry) => entry.value == type && entry.key.contains(wanted),
    );
    if (named) {
      offered++;
      final scale = Scale(key.root, type);
      add(
        TheoryDiagramFound(
          title: scale.label,
          kind: _scaleKind(type),
          theoryKeys: [scale.label],
        ),
      );
    }
  }
}

/// Chord qualities matched by what they are called and by what they are written as, so
/// both `half diminished` and `m7b5` find the same chord.
void _addChords(void Function(TheoryFound) add, String wanted, Scale key) {
  var offered = 0;
  for (final type in ChordType.values) {
    if (offered == _perKind) {
      return;
    }
    final named =
        type.label.contains(wanted) ||
        (type.symbol.isNotEmpty && type.symbol.toLowerCase().contains(wanted));
    if (named) {
      offered++;
      final chord = Chord(key.root, type);
      add(
        TheoryDiagramFound(
          title: chord.symbol,
          kind: 'Chord',
          theoryKeys: [chord.symbol],
        ),
      );
    }
  }
}

/// Progressions matched by name and by any of the three ways they are written down, which
/// is how a player who half remembers one looks for it.
void _addProgressions(
  void Function(TheoryFound) add,
  String wanted,
  Scale key,
) {
  var offered = 0;
  for (final chart in chartsIn(key)) {
    if (offered == _perKind) {
      return;
    }
    final named =
        chart.name.toLowerCase().contains(wanted) ||
        chart.numerals.toLowerCase().contains(wanted) ||
        chart.numbers.contains(wanted) ||
        chart.symbols.toLowerCase().contains(wanted);
    if (named) {
      offered++;
      add(
        TheoryDiagramFound(
          title: '${chart.name} in ${chart.key.label}',
          kind: 'Progression',
          // The key and the numbers, because numbers without a key are not chords.
          theoryKeys: [chart.key.label, chart.numerals],
        ),
      );
    }
  }
}

/// The swaps available in the key, matched by the substitute's own symbol and by the
/// reason it works - a player looking for the tritone substitute is looking for a reason.
void _addSubstitutions(
  void Function(TheoryFound) add,
  String wanted,
  Scale key,
) {
  final family = ChordFamily(key);
  var offered = 0;
  for (var degree = 1; degree <= 7; degree++) {
    final chord = family.chordOn(degree)?.seventh;
    if (chord == null) {
      return;
    }
    for (final substitution in substitutionsFor(chord, key)) {
      if (offered == _perKind) {
        return;
      }
      final named =
          substitution.chord.symbol.toLowerCase().contains(wanted) ||
          substitution.reason.toLowerCase().contains(wanted);
      if (named) {
        offered++;
        add(
          TheoryDiagramFound(
            title: '${substitution.chord.symbol} for ${chord.symbol}',
            kind: 'Substitution',
            theoryKeys: [substitution.chord.symbol],
          ),
        );
      }
    }
  }
}
