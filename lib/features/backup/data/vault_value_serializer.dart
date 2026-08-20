import 'package:drift/drift.dart';

/// How single values are written into a backup file and read back out of it.
///
/// Only dates need a say. Drift's default serializer writes a `DateTime` as a
/// unix timestamp, which is correct but unreadable, and a date written without a
/// zone on it - `2026-04-05T09:30:00.000` - is a date nobody can pin down later.
/// This database already stores its timestamps as UTC ISO-8601 text, so writing
/// them the same way makes the file a straight copy of the column.
///
/// Coming back in, a date stays UTC, which is how the database hands it over: a
/// restored row then equals the row that was backed up rather than merely naming
/// the same instant. A plain number is still read, so a file written by drift's
/// own default remains readable.
class VaultValueSerializer extends ValueSerializer {
  const VaultValueSerializer();

  static const _plain = ValueSerializer.defaults();

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    return _plain.toJson<T>(value);
  }

  @override
  T fromJson<T>(dynamic json) {
    // The same check drift makes internally: whether T is DateTime, nullable or
    // not, which a plain `T == DateTime` cannot tell.
    if (json != null && <T>[] is List<DateTime?>) {
      return _dateTime(json) as T;
    }
    return _plain.fromJson<T>(json);
  }

  DateTime _dateTime(dynamic json) => json is int
      ? DateTime.fromMillisecondsSinceEpoch(json, isUtc: true)
      : DateTime.parse(json.toString()).toUtc();
}
