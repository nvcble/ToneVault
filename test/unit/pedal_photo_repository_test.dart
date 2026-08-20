import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedals/data/pedal_photo_repository.dart';
import 'package:tone_vault/features/pedals/data/photo_picker.dart';
import '../support/fake_photo_picker.dart';

/// Keeping a photo the device handed over.
///
/// The point of the copy is that the app's picture survives the camera clearing
/// its cache, so what these tests watch is where the file ends up.
void main() {
  late Directory temporary;
  late Directory folder;
  late FakePhotoPicker picker;
  late PedalPhotoRepository photos;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('tone_vault_photos');
    // Not created here: the app's folder does not exist until the first photo.
    folder = Directory('${temporary.path}/pedal_photos');
    picker = FakePhotoPicker();
    photos = PedalPhotoRepository(picker, () async => folder);
  });

  tearDown(() => temporary.delete(recursive: true));

  /// Stands for the file the camera or the gallery hands over.
  Future<File> deviceFile([String name = 'IMG_0042.JPG']) async {
    final file = File('${temporary.path}/$name');
    await file.writeAsBytes([1, 2, 3]);
    return file;
  }

  test('copies the picked file into the app\'s own folder', () async {
    picker.picked = await deviceFile();

    final stored = await photos.choose(PhotoSource.camera);

    expect(stored, startsWith(folder.path));
    expect(File(stored!).readAsBytesSync(), [1, 2, 3]);
    // The original is the device's to keep or clear; we only ever read it.
    expect(picker.picked!.existsSync(), isTrue);
    expect(picker.asked, [PhotoSource.camera]);
  });

  test('keeps the extension so the file is still recognisable', () async {
    picker.picked = await deviceFile('board.png');

    expect(await photos.choose(PhotoSource.gallery), endsWith('.png'));
  });

  test('stores a file with no extension under a name without one', () async {
    picker.picked = await deviceFile('scan');

    // A name ending in a bare dot would be worse than none at all.
    expect(await photos.choose(PhotoSource.gallery), isNot(endsWith('.')));
  });

  test('two photos of one pedal do not land on the same name', () async {
    picker.picked = await deviceFile();

    final first = await photos.choose(PhotoSource.camera);
    final second = await photos.choose(PhotoSource.camera);

    expect(first, isNot(second));
    expect(folder.listSync(), hasLength(2));
  });

  test('reports nothing when the user backs out', () async {
    picker.picked = null;

    expect(await photos.choose(PhotoSource.camera), isNull);
    expect(folder.existsSync(), isFalse);
  });

  test('lets a refused camera through as it was worded', () async {
    picker.failure = const AppFailure('Could not open the camera.');

    await expectLater(
      photos.choose(PhotoSource.camera),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'Could not open the camera.',
        ),
      ),
    );
  });

  test('says so plainly when the copy itself cannot be made', () async {
    picker.picked = File('${temporary.path}/never_written.jpg');

    // Whatever the driver said about the missing file is not the user's problem.
    await expectLater(
      photos.choose(PhotoSource.gallery),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'Could not save this photo.',
        ),
      ),
    );
  });

  test('discards a copy of its own', () async {
    picker.picked = await deviceFile();
    final stored = await photos.choose(PhotoSource.camera);

    await photos.discard(stored);

    expect(File(stored!).existsSync(), isFalse);
  });

  test('leaves alone a path that is not one of its copies', () async {
    final elsewhere = await deviceFile('somebody_elses.jpg');

    // A path out of a backup taken on another phone points at a file this app
    // never made, and deleting whatever is there would be inexcusable.
    await photos.discard(elsewhere.path);
    await photos.discard(null);

    expect(elsewhere.existsSync(), isTrue);
  });

  test('a photo that is already gone is not a problem', () async {
    picker.picked = await deviceFile();
    final stored = await photos.choose(PhotoSource.camera);
    await photos.discard(stored);

    // Nothing the user can act on, and nothing left to remove either.
    await expectLater(photos.discard(stored), completes);
  });
}
