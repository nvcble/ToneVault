import '../../../core/music/chord.dart';
import '../../../core/music/chord_family.dart';
import '../../../core/music/chord_type.dart';
import '../../../core/music/interval.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/theory_query.dart';
import 'theory_search.dart';

/// The two shapes a player looks for by name rather than by writing one down: an interval
/// and an arpeggio.
///
/// Their own file, and not because `theory_search.dart` was getting long. These two are
/// asked for differently from everything else in there. A chord or a scale is found by a
/// word that names it; an interval is a distance whose names are in the theory engine
/// rather than in any enum, and an arpeggio is a chord with a word after it, so a query
/// naming one has to be taken apart before it names anything.
///
/// Both build on the key the browser is on, which is the same rule the rest of the search
/// follows: a player who searches `minor 3rd` in Eb is shown the one in Eb.
void addIntervals(
  void Function(TheoryFound) add,
  String wanted,
  Scale key, {
  required int limit,
}) {
  final names = intervalNames;
  var offered = 0;

  // From the semitone up to the octave, rather than over the names, because several
  // names mean the same distance and a player asking for a flat 5th is asking for one
  // diagram, not for the tritone three times.
  for (var semitones = minorSecond; semitones <= octave; semitones++) {
    if (offered == limit) {
      return;
    }
    final named = names.entries.any(
      (entry) => entry.value == semitones && entry.key.contains(wanted),
    );
    if (named) {
      offered++;
      add(_found(IntervalReference(key.root, semitones), 'Interval'));
    }
  }
}

/// Arpeggios, for a query with the word in it.
///
/// Only for those queries. Every chord quality is also an arpeggio, and offering both for
/// every chord search would double a list whose whole job is to be short - so the word is
/// what asks for them, and what is left of the query after it says which ones.
///
/// The word on its own is answered with the chords of the key, because that is what a
/// player practising arpeggios works through: the ones the songs they are playing are
/// built from.
void addArpeggios(
  void Function(TheoryFound) add,
  String wanted,
  Scale key, {
  required int limit,
}) {
  final asked = _withoutTheWord(wanted);
  if (asked == null) {
    return;
  }

  final chords = asked.isEmpty
      ? _chordsOf(key)
      : [
          for (final type in ChordType.values)
            if (_isCalled(type, asked)) Chord(key.root, type),
        ];

  for (final chord in chords.take(limit)) {
    add(_found(ArpeggioReference(chord), 'Arpeggio'));
  }
}

/// The query with the word `arpeggio` taken out of it, or null where it had none.
///
/// Any beginning of the word from three letters up, because a player who means arpeggios
/// has usually stopped typing by `arp` and the list is being rebuilt on every letter.
String? _withoutTheWord(String wanted) {
  final words = wanted.split(RegExp(r'\s+'));
  final index = words.indexWhere(
    (word) => word.length >= 3 && 'arpeggio'.startsWith(word),
  );
  if (index < 0) {
    return null;
  }

  return (words..removeAt(index)).join(' ').trim();
}

/// The seven chords of the key, as triads: the first arpeggio of every degree.
List<Chord> _chordsOf(Scale key) {
  final family = ChordFamily(key);
  return [
    for (var degree = 1; degree <= 7; degree++) ?family.chordOn(degree)?.triad,
  ];
}

/// Matched by what the quality is called and by what it is written as, so both
/// `minor 7th arpeggio` and `m7 arp` find the same one.
bool _isCalled(ChordType type, String wanted) =>
    type.label.contains(wanted) ||
    (type.symbol.isNotEmpty && type.symbol.toLowerCase().contains(wanted));

/// A result that opens by being read again: the label the reference gives itself is a
/// label the engine can resolve, so a kept one draws the same diagram it was found as.
TheoryFound _found(TheoryReference reference, String kind) =>
    TheoryDiagramFound(
      title: reference.label,
      kind: kind,
      theoryKeys: [reference.label],
    );
