/// The curriculum the app ships with, as the files it is stored in.
///
/// One file per path and level. A course's position comes from where it is written
/// in its file, so courses that share a level have to share a file to be ordered
/// against each other - and courses that do not share a level have no reason to be
/// numbered together. Splitting this way also keeps each file to something a person
/// can read in one sitting, which is what a level of teaching material is.
///
/// The order they are read in only decides which is written first. A file that is
/// added by a later version of the app can go anywhere in this list: the seeder adds
/// what is missing and leaves the rest alone.
const List<String> curriculumAssets = <String>[
  'assets/curriculum/rhythm_beginner.json',
  'assets/curriculum/rhythm_intermediate.json',
  'assets/curriculum/rhythm_advanced.json',
  'assets/curriculum/rhythm_professional.json',
  'assets/curriculum/lead_beginner.json',
  'assets/curriculum/lead_intermediate.json',
  'assets/curriculum/lead_advanced.json',
  'assets/curriculum/lead_professional.json',
];
