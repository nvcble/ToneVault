import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_version.dart';

/// The reader itself, overridden in tests to a fixed version.
final Provider<AppVersionReader> appVersionReaderProvider =
    Provider<AppVersionReader>((ref) => readAppVersion);

/// What this build is, asked once per launch.
///
/// A build cannot change while it is running, so Riverpod holding the one answer
/// for every listener is the whole of the caching this needs.
final FutureProvider<AppVersion> appVersionProvider =
    FutureProvider<AppVersion>((ref) => ref.watch(appVersionReaderProvider)());
