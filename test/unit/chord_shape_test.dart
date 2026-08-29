import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_shape.dart';
import 'package:tone_vault/core/music/chord_shape_library.dart';
import 'package:tone_vault/core/music/chord_type.dart';
import 'package:tone_vault/core/music/chord_voicing.dart';
import 'package:tone_vault/core/music/fretboard.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// Every shape in the library, checked against the chord it claims to be.
///
/// This is the test the shape table exists to be held to. A fret typed one out in a
/// fingering is not something a reader will spot and not something the app could notice:
/// it is a chord box that tells a player to hold the wrong note, in a screen whose whole
/// job is to be trusted. So each shape is placed on a real neck and asked what it sounds.
void main() {
  /// A shape placed high enough that even the ones reaching below their root fit, so the
  /// same check can be run over all of them.
  ChordVoicing place(ChordShape shape, PitchClass root) {
    final voicing = voicingsFor(
      Chord(root, shape.type),
      fretboard: const Fretboard(fretCount: 15),
    ).where((found) => found.shape == shape);
    return voicing.single;
  }

  group('every shape', () {
    for (final shape in chordShapes) {
      final chord = Chord(PitchClass(0), shape.type);

      test(
        '${shape.name} ${shape.type.symbol.isEmpty ? 'major' : shape.type.symbol} '
        'sounds only notes of the chord',
        () {
          // Two roots, because a shape that happened to be right in one key would be a
          // shape that is right by accident.
          for (final root in [PitchClass(0), PitchClass(9)]) {
            final voicing = place(shape, root);
            final wanted = Chord(root, shape.type).notes.toSet();

            for (final note in voicing.notes) {
              expect(
                note.note,
                isIn(wanted),
                reason:
                    '${shape.name} ${shape.type.name} on ${root.name()} '
                    'sounds ${note.note.name()}, which is not in the chord',
              );
            }
          }
        },
      );

      test('and the root, and enough of the rest to be the chord', () {
        final voicing = place(shape, PitchClass(0));
        final sounded = {for (final note in voicing.notes) note.note};

        // The root always, because a chord box without it is a chord box for something
        // else. Then three notes, or all of them where the chord has fewer than three:
        // a ninth held without its fifth and an eleventh without its third are what a
        // player actually holds, and a rule that refused them would refuse the shapes
        // this app most needs.
        expect(voicing.notes.first.note, chord.root);
        expect(sounded, contains(chord.root));
        expect(
          sounded.intersection(chord.notes.toSet()).length,
          greaterThanOrEqualTo(chord.notes.length < 3 ? chord.notes.length : 3),
        );
      });

      test('and says which finger holds each of its frets', () {
        expect(shape.frets, hasLength(6));
        expect(shape.fingers, hasLength(6));

        for (var string = 0; string < 6; string++) {
          // A string not played has no finger on it, and one that is has one - anything
          // else is a diagram a player cannot follow.
          expect(
            shape.fingers[string] == null,
            shape.frets[string] == null,
            reason: '${shape.name} ${shape.type.name}, string $string',
          );
        }
      });
    }
  });

  test('and every quality has one', () {
    // A quality with no shape is a chord the browser can name and spell but never show a
    // player how to hold, which is the one thing they came for.
    for (final type in ChordType.values) {
      expect(
        shapesFor(type),
        isNotEmpty,
        reason: 'no shape spells ${type.name}',
      );
    }
  });

  group('a shape that reaches below its root', () {
    test('says how far', () {
      final cShape = shapesFor(
        ChordType.major,
      ).firstWhere((shape) => shape.name == 'C shape');

      // Three frets down, which is why the open C chord is at the third fret and not at
      // the nut: the shape has nowhere lower to go.
      expect(cShape.reachBelowRoot, 3);
    });

    test('and one that does not says nought', () {
      final eShape = shapesFor(
        ChordType.major,
      ).firstWhere((shape) => shape.name == 'E shape');

      expect(eShape.reachBelowRoot, 0);
    });
  });
}
