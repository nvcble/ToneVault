import 'package:package_info_plus/package_info_plus.dart';

/// The version this build was stamped with, in its two halves.
///
/// Kept apart rather than as one string: `name` is what a player quotes when
/// something is wrong, and `build` is the only thing that tells two uploads of
/// the same name apart - a sideloaded APK from the one already on the phone.
typedef AppVersion = ({String name, String build});

/// Where the version comes from, behind a typedef so a test can say what the
/// build is without a platform channel to answer for the plugin.
typedef AppVersionReader = Future<AppVersion> Function();

/// Asks the platform what this build was stamped with.
///
/// Both halves come from `version:` in `pubspec.yaml` by way of the Android
/// manifest, so there is nothing here to keep in step with a release.
Future<AppVersion> readAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return (name: info.version, build: info.buildNumber);
}
