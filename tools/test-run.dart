import 'dart:io';

/// Runs a command with the console handed straight through, so a long or
/// interactive step prints as it goes and `flutter run` still takes `r` and `q`.
///
/// Process.run cannot do this: it buffers output and only returns it once the
/// process exits, which for `flutter run` is never - the script looked dead.
Future<void> run(String cmd, List<String> args) async {
  stdout.writeln('\n> $cmd ${args.join(' ')}');

  final process = await Process.start(
    cmd,
    args,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  if (await process.exitCode != 0) {
    throw Exception('$cmd ${args.join(' ')} failed');
  }
}

/// Same, but reads the output back so a command that reports a failure while
/// still exiting 0 can be caught.
Future<String> capture(String cmd, List<String> args) async {
  stdout.writeln('\n> $cmd ${args.join(' ')}');

  final result = await Process.run(cmd, args, runInShell: true);
  final output = '${result.stdout}${result.stderr}';
  stdout.write(output);

  if (result.exitCode != 0) {
    throw Exception('$cmd ${args.join(' ')} failed');
  }
  return output;
}

Future<void> main() async {
  // `flutter clean` exits 0 even when it cannot delete .dart_tool, which happens
  // whenever a `flutter run` is still holding the native-asset build locks. Left
  // unchecked, pub get then runs against a half-cleaned tree.
  final cleaned = await capture('flutter', ['clean']);
  if (cleaned.contains('Failed to remove')) {
    throw Exception(
      'flutter clean could not empty .dart_tool. Close any running app or '
      'debug session (a stale `flutter run` holds it) and try again.',
    );
  }

  await run('flutter', ['pub', 'get']);
  await run('flutter', ['doctor']);
  // Android is the only platform in this project, so there is one device to
  // choose from and no prompt to answer.
  await run('flutter', ['run']);
}
