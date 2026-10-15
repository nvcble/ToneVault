import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/shared/widgets/orientation_lock.dart';

/// Holding a screen on one side, and handing rotation back when it closes or
/// when another page covers it.
void main() {
  const landscape = [
    'DeviceOrientation.landscapeLeft',
    'DeviceOrientation.landscapeRight',
  ];

  late List<List<String>> requests;

  setUp(() {
    requests = [];
    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            requests.add(List<String>.from(call.arguments as List));
          }
          return null;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  testWidgets('asks for landscape on the way in and for all on the way out', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: OrientationLock(child: Text('held sideways'))),
    );

    expect(requests, [landscape]);

    // Whatever replaces it is free to rotate: the lock belongs to the screen
    // that asked for it, not to the app.
    await tester.pumpWidget(const MaterialApp(home: Text('somewhere else')));

    expect(requests.last, hasLength(DeviceOrientation.values.length));
  });

  testWidgets('lets go while another page covers it, and takes it back', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: const OrientationLock(child: Text('held sideways')),
      ),
    );
    expect(requests, [landscape]);

    // A page opened from this one is laid out for a phone held upright, and
    // would otherwise come up sideways with it.
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(builder: (context) => const Text('a list')),
      ),
    );
    await tester.pumpAndSettle();

    expect(requests.last, hasLength(DeviceOrientation.values.length));

    await navigator.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(requests.last, landscape);
  });
}
