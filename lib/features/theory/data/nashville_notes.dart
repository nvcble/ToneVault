/// What the number system is, in the order it makes sense in.
///
/// Prose, kept away from the widget that lays it out: this is the one part of the theory
/// browser that is written rather than worked out, and it is easier to read, correct and
/// translate as a list of paragraphs than as strings threaded through a build method.
///
/// Four notes, because a player who has read four paragraphs can already follow a chart.
/// Everything past that is what the chords, progressions and substitutions tabs show by
/// working it out, and a fifth paragraph would be teaching what the app can demonstrate.
const List<({String heading, String body})> nashvilleNotes = [
  (
    heading: 'A chord called by where it sits',
    body:
        'Every degree of a key carries a chord, and the number system calls the chord '
        'by its degree instead of its name. So a progression stops belonging to one '
        'key: 1 5 6 4 is C G Am F in C, and D A Bm G in D, and the same song in both.',
  ),
  (
    heading: 'The quality comes with the number',
    body:
        'A bare number means the chord the key already has there. In C, 2 is Dm and 6 '
        'is Am, because that is what the second and sixth chords of C are - nobody '
        'writes the m. Put a quality after the number to say otherwise: 27 is D7, and '
        '6maj is A major where the key wanted A minor.',
  ),
  (
    heading: 'A flat or a sharp goes outside the key',
    body:
        'b7 in C is Bb and b3 is Eb: a degree of the key, moved a semitone. There is no '
        'chord already sitting there to take a quality from, so an unqualified one is '
        'read as major - which is exactly what a chart means by bVII and bIII.',
  ),
  (
    heading: 'Why a band calls numbers',
    body:
        'Because the key is the one thing likely to change. A singer asks for it a tone '
        'down and a chart written in numbers is still right, while a chart written in '
        'chords has to be rewritten. Learn the numbers of a song and you have learnt it '
        'in twelve keys.',
  ),
];
