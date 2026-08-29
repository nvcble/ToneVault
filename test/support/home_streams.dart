import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';

/// The two streams the home tab reads, as plain values.
///
/// The app opens on the home tab, so any test that pumps the whole app has to
/// stand these in or it reaches for the database file on disk, which never
/// resolves under the test binding. They are the same providers the Pedals and
/// History tabs use, so pass whatever those tabs need through here rather than
/// overriding them twice.
List<Override> homeStreamOverrides({
  List<Pedal> pedals = const [],
  List<PedalChange> changes = const [],
}) => [
  pedalListProvider.overrideWith((ref) => Stream.value(pedals)),
  recentHistoryProvider.overrideWith((ref) => Stream.value(changes)),
];
