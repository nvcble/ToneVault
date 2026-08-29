import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/metronome/providers/metronome_providers.dart';
import '../support/recording_metronome.dart';

/// The practice the metronome counted, and the taking of it.
///
/// A clock is handed in, because the alternative is a test that practises for real.
void main() {
  late MetronomeController controller;
  var now = DateTime.utc(2026, 8, 20, 10);

  setUp(() {
    now = DateTime.utc(2026, 8, 20, 10);
    controller = MetronomeController(RecordingMetronome(), clock: () => now);
  });

  tearDown(() => controller.dispose());

  test('a metronome nobody started counted nothing', () {
    now = now.add(const Duration(minutes: 5));

    // Five minutes of the screen being open is not five minutes of practice.
    expect(controller.takeCountedSeconds(), 0);
  });

  test('a stretch is counted once it is stopped', () async {
    await controller.start();
    now = now.add(const Duration(minutes: 3));
    await controller.stop();

    expect(controller.takeCountedSeconds(), 180);
  });

  test('and the stretches of one sitting add up', () async {
    await controller.start();
    now = now.add(const Duration(seconds: 40));
    await controller.stop();

    // The gap between them is the player working something out in silence, which is
    // not the metronome's to claim.
    now = now.add(const Duration(minutes: 2));

    await controller.start();
    now = now.add(const Duration(seconds: 20));
    await controller.stop();

    expect(controller.takeCountedSeconds(), 60);
  });

  test('a count still going is counted up to now', () async {
    await controller.start();
    now = now.add(const Duration(seconds: 90));

    // Without stopping it: a player who leaves the metronome running and walks back
    // to the lesson has still practised the ninety seconds.
    expect(controller.takeCountedSeconds(), 90);
    expect(controller.state.playing, isTrue);
  });

  test('and carries on from where the taking left it', () async {
    await controller.start();
    now = now.add(const Duration(seconds: 90));
    controller.takeCountedSeconds();

    now = now.add(const Duration(seconds: 30));

    // Thirty, not a hundred and twenty: whoever took the first ninety owns them.
    expect(controller.takeCountedSeconds(), 30);
  });

  test('taking it twice does not count it twice', () async {
    await controller.start();
    now = now.add(const Duration(minutes: 1));
    await controller.stop();

    expect(controller.takeCountedSeconds(), 60);
    expect(controller.takeCountedSeconds(), 0);
  });

  test('a stretch too short to be a second is not a second', () async {
    await controller.start();
    now = now.add(const Duration(milliseconds: 1900));
    await controller.stop();

    // Truncated rather than rounded. Practice is a running total, and a total that
    // rounded every stretch up would drift upwards a click at a time.
    expect(controller.takeCountedSeconds(), 1);
  });

  test('changing the tempo mid-count does not restart the counting', () async {
    await controller.start();
    now = now.add(const Duration(seconds: 30));
    await controller.setBpm(140);
    now = now.add(const Duration(seconds: 30));

    // The bar is rendered again and the loop replaced, which is a beat of
    // interruption rather than a new practice session.
    expect(controller.takeCountedSeconds(), 60);
  });
}
