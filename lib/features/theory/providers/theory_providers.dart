import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/music/caged.dart';
import '../../../core/music/chord.dart';
import '../../../core/music/chord_family.dart';
import '../../../core/music/chord_naming.dart';
import '../../../core/music/chord_type.dart';
import '../../../core/music/chord_voicing.dart';
import '../../../core/music/circle_of_fifths.dart';
import '../../../core/music/fretboard_diagram.dart';
import '../../../core/music/pitch_class.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_type.dart';
import '../../../core/music/substitution.dart';
import '../data/key_facts.dart';
import '../data/progression_chart.dart';
import '../data/scale_facts.dart';

/// The theory browser, worked out from one key.
///
/// Every list on it is derived rather than stored: change the key and the chords, the
/// numbers, the progressions and the substitutions all follow, because each is a
/// function of the key and nothing is written down twice. That is also why the theory
/// lives here rather than in the widgets - a screen asks what the chords of the key are
/// and draws the answer.

/// The key the whole browser is read in.
///
/// Not auto-disposed: a player working in Eb comes back to Eb, and the tabs are five
/// views of one key rather than five screens each with an idea of what key it is in.
final StateProvider<Scale> theoryKeyProvider = StateProvider<Scale>(
  (ref) => Scale(PitchClass(0), ScaleType.major),
);

/// Which scale is being looked at on the neck, on the key's root. Browsing the modes is
/// not changing key, so this is separate from [theoryKeyProvider].
final StateProvider<ScaleType> theoryScaleTypeProvider =
    StateProvider<ScaleType>((ref) => ScaleType.major);

/// Which chord of the key is being asked about, as a degree from 1 to 7.
final StateProvider<int> theoryDegreeProvider = StateProvider<int>((ref) => 1);

/// The seven chords the key is built from, in scale order.
final Provider<List<DiatonicChord>> diatonicChordsProvider =
    Provider<List<DiatonicChord>>(
      (ref) => ChordFamily(ref.watch(theoryKeyProvider)).chords,
    );

final Provider<Scale> theoryScaleProvider = Provider<Scale>(
  (ref) => Scale(
    ref.watch(theoryKeyProvider).root,
    ref.watch(theoryScaleTypeProvider),
  ),
);

final Provider<FretboardDiagram> theoryScaleDiagramProvider =
    Provider<FretboardDiagram>(
      (ref) => diagramOfScale(ref.watch(theoryScaleProvider)),
    );

/// The scale's notes, each with the degree a player counts it as.
final Provider<List<({String degree, String note})>> theoryScaleNotesProvider =
    Provider<List<({String degree, String note})>>((ref) {
      final diagram = ref.watch(theoryScaleDiagramProvider);
      return [
        for (final note in diagram.notes)
          (degree: diagram.degrees[note]!, note: diagram.nameOf(note)),
      ];
    });

/// What the scale is made of, where it came from and what it is played over.
final Provider<ScaleFacts> theoryScaleFactsProvider = Provider<ScaleFacts>(
  (ref) => ScaleFacts.of(ref.watch(theoryScaleProvider)),
);

final Provider<List<ProgressionChart>> theoryProgressionsProvider =
    Provider<List<ProgressionChart>>(
      (ref) => chartsIn(ref.watch(theoryKeyProvider)),
    );

/// The chord substitutions are being asked about: the seventh chord on the chosen
/// degree.
///
/// The seventh rather than the triad, because the quality of the seventh is what most
/// of the reasoning turns on - the five chord of a key only offers a tritone substitute
/// once it is a dominant seventh, which on a stand it always is.
final Provider<Chord?> theoryChordProvider = Provider<Chord?>(
  (ref) => ChordFamily(
    ref.watch(theoryKeyProvider),
  ).chordOn(ref.watch(theoryDegreeProvider))?.seventh,
);

final Provider<List<Substitution>> theorySubstitutionsProvider =
    Provider<List<Substitution>>((ref) {
      final chord = ref.watch(theoryChordProvider);
      return chord == null
          ? const []
          : substitutionsFor(chord, ref.watch(theoryKeyProvider));
    });

/// Every quality the engine can spell, all on the key's root: the chord library.
///
/// One root and every quality, rather than a list of chords, for the same reason the
/// scales are shown one root and every formula - what a player is comparing is the
/// qualities, and moving the root between them hides the thing being taught.
final Provider<List<Chord>> chordLibraryProvider = Provider<List<Chord>>((ref) {
  final root = ref.watch(theoryKeyProvider).root;
  return [for (final type in ChordType.values) Chord(root, type)];
});

/// Every way the app knows to hold a chord of the key's root, lowest on the neck first.
///
/// A family rather than a list on the library, because a chord's fingerings are only
/// worked out when a player opens that chord: twenty-six qualities' worth of placement
/// arithmetic on every key change would be work done for a screen nobody has opened.
final ProviderFamily<List<ChordVoicing>, ChordType> chordVoicingsProvider =
    Provider.family<List<ChordVoicing>, ChordType>(
      (ref, type) =>
          voicingsFor(Chord(ref.watch(theoryKeyProvider).root, type)),
    );

final Provider<KeyFacts> theoryKeyFactsProvider = Provider<KeyFacts>(
  (ref) => KeyFacts.of(ref.watch(theoryKeyProvider)),
);

/// The chord the CAGED tab is holding: the triad on the chosen degree of the key.
///
/// The triad rather than the seventh, because CAGED is taught on triads - and the same
/// degree the substitutions tab is asking about, so a player who was thinking about the
/// five chord is still thinking about it when they go looking for its shapes.
final Provider<Chord?> theoryTriadProvider = Provider<Chord?>(
  (ref) => ChordFamily(
    ref.watch(theoryKeyProvider),
  ).chordOn(ref.watch(theoryDegreeProvider))?.triad,
);

/// That chord in each of the five shapes, lowest on the neck first.
final Provider<List<ChordVoicing>> cagedVoicingsProvider =
    Provider<List<ChordVoicing>>((ref) {
      final chord = ref.watch(theoryTriadProvider);
      return chord == null ? const [] : cagedVoicings(chord);
    });

/// The notes a player has pressed together on the circle, in the order they pressed them.
///
/// A list rather than a set, because the order is what says which note is underneath: C E
/// A pressed from the C is a player building on C, and the same three pressed from the A
/// is a player building A minor. Empty is the resting state - the wheel is a circle of
/// keys until somebody combines notes on it.
final StateProvider<List<PitchClass>> combinedNotesProvider =
    StateProvider<List<PitchClass>>((ref) => const []);

/// What those notes spell, the one built on the first note pressed first, or empty where
/// they spell nothing with a name.
final Provider<List<Chord>> combinedChordsProvider = Provider<List<Chord>>(
  (ref) => chordsOfNotes(ref.watch(combinedNotesProvider)),
);

/// The way round the circle onto the chord they spell.
final Provider<List<Chord>> combinedProgressionProvider =
    Provider<List<Chord>>((ref) {
      final chords = ref.watch(combinedChordsProvider);
      return chords.isEmpty ? const [] : circleOnto(chords.first);
    });
