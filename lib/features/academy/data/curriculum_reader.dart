import '../../../core/errors/app_failure.dart';
import '../../../core/values/tempo_range.dart';

/// One object of a curriculum file, read field by field.
///
/// Every read either gives back a value of the right type or throws an
/// [AppFailure] naming the field and where in the file it is. The alternative is a
/// cast that fails somewhere deep in a decoder and reaches the user as "type
/// 'String' is not a subtype of type 'int'", which tells them nothing about the
/// file they are trying to import.
///
/// Trimming happens here too. A curriculum is a hand-written file, and a title with
/// a trailing space is not a different title.
class CurriculumReader {
  const CurriculumReader._(this._fields, this._what);

  /// Refuses anything that is not an object at all, which is what a list of
  /// courses containing a bare string arrives as.
  factory CurriculumReader.of(Object? value, String what) {
    if (value is! Map<String, dynamic>) {
      throw AppFailure('That curriculum has a $what that is not filled in.');
    }
    return CurriculumReader._(value, what);
  }

  final Map<String, dynamic> _fields;
  final String _what;

  /// A name to find something again by. Lower case, and no spaces: a slug goes in
  /// a URL and in a file, and a course whose slug differs from another's only by
  /// case would be two courses on one phone and one on another.
  String slug(String field, {required int max}) {
    final value = text(field, at: _what, max: max);
    if (value != value.toLowerCase() || value.contains(' ')) {
      throw AppFailure(
        'The $field "$value" in that curriculum has to be lower case with no '
        'spaces in it.',
      );
    }
    return value;
  }

  String text(String field, {required String at, int? max}) {
    final value = _fields[field];
    if (value is! String || value.trim().isEmpty) {
      throw AppFailure('The $at in that curriculum has no $field.');
    }

    final trimmed = value.trim();
    if (max != null && trimmed.length > max) {
      throw AppFailure(
        'The $field of the $at in that curriculum is too long. The most it can '
        'be is $max characters.',
      );
    }
    return trimmed;
  }

  /// Absent and null are the same answer: this was not said. An empty string is
  /// not - something was written and it says nothing, which is a mistake worth
  /// pointing at.
  String? optionalText(String field, {required String at, int? max}) =>
      _fields[field] == null ? null : text(field, at: at, max: max);

  /// An enum by its own name, so a file reads as the app does: `fourFour`, not a
  /// number nobody can check.
  T oneOf<T extends Enum>(String field, List<T> values, {required String at}) {
    final value = optionalOneOf(field, values, at: at);
    if (value == null) {
      throw AppFailure('The $at in that curriculum has no $field.');
    }
    return value;
  }

  T? optionalOneOf<T extends Enum>(
    String field,
    List<T> values, {
    required String at,
  }) {
    final value = _fields[field];
    if (value == null) {
      return null;
    }
    for (final candidate in values) {
      if (candidate.name == value) {
        return candidate;
      }
    }
    throw AppFailure(
      'The $at in that curriculum has a $field of "$value", which is not one '
      'this app knows.',
      cause: 'expected one of ${values.map((one) => one.name).join(', ')}',
    );
  }

  int bpm(String field, {required String at}) {
    final value = optionalBpm(field, at: at);
    if (value == null) {
      throw AppFailure('The $at in that curriculum has no $field.');
    }
    return value;
  }

  int? optionalBpm(String field, {required String at}) {
    final value = optionalCount(field, at: at);
    if (value != null && !isPlayableBpm(value)) {
      throw AppFailure(
        'The $at in that curriculum asks for $value BPM. The metronome plays '
        '$minBpm to $maxBpm.',
      );
    }
    return value;
  }

  /// A whole number of something there cannot be none of: minutes, beats, a tempo.
  ///
  /// The upper bound is optional because a tempo has one that is worth explaining:
  /// it is what the metronome can play, and [optionalBpm] says so in those words
  /// rather than leaving the reader to guess at a bare range.
  int? optionalCount(String field, {required String at, int? max}) {
    final value = _fields[field];
    if (value == null) {
      return null;
    }
    if (value is! int || value <= 0 || (max != null && value > max)) {
      throw AppFailure(
        'The $field of the $at in that curriculum has to be a whole number '
        '${max == null ? 'of one or more' : 'between 1 and $max'}.',
      );
    }
    return value;
  }

  /// A list of objects to read further. Missing is empty where nothing is
  /// required, and refused where [minimum] says there has to be something: a
  /// course with no modules in it is a course with nothing to teach.
  List<Object?> list(String field, {required String at, int minimum = 0}) {
    final value = _fields[field] ?? const <Object?>[];
    if (value is! List) {
      throw AppFailure(
        'The $at in that curriculum has a $field that is not a '
        'list of them.',
      );
    }
    if (value.length < minimum) {
      throw AppFailure('The $at in that curriculum has no $field.');
    }
    return value;
  }

  /// A list of plain strings, each trimmed and none of them empty.
  List<String> textList(String field, {required String at, required int max}) {
    final entries = list(field, at: at);
    final values = <String>[];

    for (final entry in entries) {
      if (entry is! String || entry.trim().isEmpty) {
        throw AppFailure(
          'The $field of the $at in that curriculum has something in it that is '
          'not text.',
        );
      }
      final trimmed = entry.trim();
      if (trimmed.length > max) {
        throw AppFailure(
          'The $field of the $at in that curriculum has an entry longer than '
          '$max characters.',
        );
      }
      values.add(trimmed);
    }
    return values;
  }
}
