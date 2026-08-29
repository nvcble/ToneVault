import '../../../core/music/scale_type.dart';

/// What a guitarist actually does with each scale.
///
/// The one part of a scale that cannot be derived from its formula. Everything else in
/// the browser is arithmetic on twelve semitones; this is the sentence a teacher says
/// when a player asks what a scale is for, and there is nowhere to calculate it from.
///
/// Kept to a couple of sentences each, and written as playing rather than as history: a
/// player wants to know which chord to put it over and what to lean on, not which century
/// it comes from.
String scaleUse(ScaleType type) => switch (type) {
  ScaleType.major =>
    'The sound of most pop, country and folk. Play it across the chords of its own '
        'key rather than over one chord - the notes belong to the key, so it is the '
        'phrasing that has to say which chord is underneath.',
  ScaleType.dorian =>
    'Minor with a bright sixth, and the sound of a great deal of funk, rock and '
        'jazz. It suits a minor chord that sits still: over a im7 to IV7 vamp it fits '
        'both chords without a note having to change.',
  ScaleType.phrygian =>
    'Minor with a flat second, which is Spanish flamenco and heavy metal in one '
        'scale. Over Em with an F leaning on it, that second is the whole sound.',
  ScaleType.lydian =>
    'Major with a raised fourth: the floating, film-score major sound. Play it over '
        'a maj7 chord that is not the key\'s home chord, where the raised fourth has '
        'nothing pulling it back down.',
  ScaleType.mixolydian =>
    'Major with a flat seventh, so it is the scale of a dominant chord that is not '
        'going anywhere. Rock and blues riffs live here, and so does every jam over '
        'a single 7 chord.',
  ScaleType.minor =>
    'The natural minor, and the first minor sound most players learn. Play it across '
        'a minor key the way the major scale is played across a major one.',
  ScaleType.locrian =>
    'The scale for a m7b5 chord, which in practice means the ii of a minor key on '
        'its way to the five. Rarely a place to stay - it has no perfect fifth to '
        'settle on.',
  ScaleType.harmonicMinor =>
    'Minor with the seventh raised, so the five chord of a minor key becomes a real '
        'dominant. The step and a half between the flat sixth and that seventh is the '
        'classical and neo-classical sound, and it is worth landing on.',
  ScaleType.melodicMinor =>
    'Minor that can walk up to its own tonic without the flat sixth getting in the '
        'way. Play it over a minor chord with a major seventh in it, and over a minor '
        'tonic in a jazz standard.',
  ScaleType.lydianDominant =>
    'A dominant scale with a raised fourth, for a 7 chord that is not the five of '
        'anywhere - a blues one chord, or a 7#11. The raised fourth is what stops it '
        'sounding like it must resolve.',
  ScaleType.altered =>
    'Every note that argues with a dominant chord, over a V7 that has to resolve. '
        'Use it on the last beat or two before the resolution: it is tension, and '
        'tension needs somewhere to go.',
  ScaleType.majorPentatonic =>
    'Five notes with no semitone between any of them, so nothing can sound wrong. '
        'Country, southern rock and most singable solos are this scale, played over '
        'the major chords of a key.',
  ScaleType.minorPentatonic =>
    'The first scale nearly every guitarist learns, and the one most solos are still '
        'made of. Blues, rock and hard rock, over a minor chord or over a whole blues '
        'in the key of its root.',
  ScaleType.blues =>
    'The minor pentatonic with the flat five put back in, as a note to pass through '
        'rather than to sit on. Bend into it, slide off it, and it is the blues; land '
        'on it and hold it, and it is a mistake.',
  ScaleType.wholeTone =>
    'Nothing but whole steps, which is why it has no home note. It is the scale of a '
        '7#5 chord, and because every step is the same the shape moves up the neck in '
        'whole tones without changing.',
  ScaleType.diminished =>
    'A tone and a semitone repeating, over a dim7 chord. The repeat is the point: '
        'anything played in one place can be moved up a minor third, three times '
        'over, and still fits.',
  ScaleType.chromatic =>
    'Not a key and not a sound, but the notes between the notes. Use it to approach '
        'a target note from a semitone away, or to run between two notes of a scale '
        'when the rhythm has room for it.',
};
