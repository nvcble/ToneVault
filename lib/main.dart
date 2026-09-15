import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // Flutter's default release-mode error widget renders a plain, unstyled
  // box with no message - on a dark theme that is indistinguishable from an
  // empty screen. Showing the real error everywhere, in every build mode, is
  // what actually lets a blank-looking screen be diagnosed instead of
  // guessed at.
  ErrorWidget.builder = (details) => Material(
    color: Colors.red.shade900,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          details.exceptionAsString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );

  runApp(const ProviderScope(child: ToneVaultApp()));
}
