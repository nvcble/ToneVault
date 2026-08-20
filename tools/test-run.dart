import 'dart:io';

Future<void> run(String cmd, List<String> args) async {
  final process = await Process.run(cmd, args, runInShell: true);

  stdout.write(process.stdout);
  stderr.write(process.stderr);

  if (process.exitCode != 0) {
    throw Exception('$cmd failed');
  }
}

Future<void> main() async {
  await run('flutter', ['clean']);
  await run('flutter', ['pub', 'get']);
  await run('flutter', ['doctor']);
  await run('flutter', ['run']);
}