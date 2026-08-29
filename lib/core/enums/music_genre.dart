/// A style of playing a lesson teaches.
///
/// Style is a property of a lesson rather than a path of its own. What makes a
/// blues rhythm player is not the same knowledge as what makes a blues lead
/// player, and neither of them learns it all at once: the style turns up again at
/// each level, saying more each time. So a lesson names the genre it is about and
/// sits at the level it belongs to, and there is no one lesson called "Blues".
enum MusicGenre {
  blues,
  rock,
  pop,
  worship,
  funk,
  country,
  reggae,
  soul,
  rnb,
  jazz,
  gospel;

  String get label => switch (this) {
    MusicGenre.blues => 'Blues',
    MusicGenre.rock => 'Rock',
    MusicGenre.pop => 'Pop',
    MusicGenre.worship => 'Worship',
    MusicGenre.funk => 'Funk',
    MusicGenre.country => 'Country',
    MusicGenre.reggae => 'Reggae',
    MusicGenre.soul => 'Soul',
    MusicGenre.rnb => 'R&B',
    MusicGenre.jazz => 'Jazz',
    MusicGenre.gospel => 'Gospel',
  };
}
