import 'dart:convert';

/// A curriculum file, as text, with anything a test wants to break replaced.
///
/// Built from maps rather than written out as JSON strings, so a test that is about
/// one missing field says only that: `courseWithout('title')` reads as the thing it
/// is checking, where a hand-edited blob of JSON hides it.
String curriculumJson({
  int formatVersion = 1,
  List<Map<String, dynamic>>? courses,
}) {
  return json.encode({
    'formatVersion': formatVersion,
    'courses': courses ?? [courseMap()],
  });
}

Map<String, dynamic> courseMap({
  String slug = 'rhythm-beginner-first-chords',
  String path = 'rhythm',
  String level = 'beginner',
  String title = 'First Chords',
  List<Map<String, dynamic>>? modules,
}) {
  return {
    'slug': slug,
    'path': path,
    'level': level,
    'title': title,
    'summary': 'Six shapes and the changes between them.',
    'modules': modules ?? [moduleMap()],
  };
}

Map<String, dynamic> moduleMap({
  String slug = 'open-chords',
  String title = 'Open Chords',
  List<Map<String, dynamic>>? lessons,
}) {
  return {
    'slug': slug,
    'title': title,
    'summary': 'The first six.',
    'lessons': lessons ?? [lessonMap()],
  };
}

Map<String, dynamic> lessonMap({
  String slug = 'em-and-am',
  String title = 'Em and Am',
  String kind = 'technique',
  String body = 'Two fingers, moved across one string.',
  Object? genre,
  Object? objective = 'Change between Em and Am without stopping.',
  List<String> commonMistakes = const ['Placing each finger separately.'],
  List<String> practiceTips = const ['Move the pair as one block.'],
  Object? nextSkill = 'C and G',
  Object? suggestedBpm = 60,
  Object? timeSignature = 'fourFour',
  List<String> theoryKeys = const ['Em', 'Am'],
  List<Map<String, dynamic>>? exercises,
}) {
  return {
    'slug': slug,
    'title': title,
    'kind': kind,
    'body': body,
    'genre': genre,
    'objective': objective,
    'commonMistakes': commonMistakes,
    'practiceTips': practiceTips,
    'nextSkill': nextSkill,
    'estimatedMinutes': 15,
    'suggestedBpm': suggestedBpm,
    'timeSignature': timeSignature,
    'theoryKeys': theoryKeys,
    'exercises': exercises ?? [exerciseMap()],
  };
}

Map<String, dynamic> exerciseMap({
  String title = 'One chord a bar',
  Object? startBpm = 60,
  Object? targetBpm = 100,
  String timeSignature = 'fourFour',
}) {
  return {
    'title': title,
    'instructions': 'Strum on beat one and change on the next bar.',
    'startBpm': startBpm,
    'targetBpm': targetBpm,
    'timeSignature': timeSignature,
  };
}

/// The same document with one field of one thing taken out or replaced, which is
/// what most of the validation tests are.
Map<String, dynamic> without(Map<String, dynamic> source, String field) {
  return {...source}..remove(field);
}

Map<String, dynamic> replacing(
  Map<String, dynamic> source,
  String field,
  Object? value,
) {
  return {...source, field: value};
}
