import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedals/data/pedal_photo_repository.dart';
import 'package:tone_vault/features/pedals/data/photo_picker.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import 'package:tone_vault/features/pedals/widgets/pedal_photo_field.dart';
import '../support/fake_photo_picker.dart';

/// A photo store with no device and no disk behind it.
///
/// The copying itself is `pedal_photo_repository_test`; what matters here is which
/// source the field asks for, what it reports back, and what it cleans up.
class _FakePhotos extends PedalPhotoRepository {
  _FakePhotos() : super(FakePhotoPicker(), _noFolder);

  /// What the next pick returns. Null stands for the user backing out.
  String? next = '/photos/pedal_1.jpg';
  AppFailure? failure;

  final List<PhotoSource> asked = <PhotoSource>[];
  final List<String?> discarded = <String?>[];

  @override
  Future<String?> choose(PhotoSource source) async {
    asked.add(source);
    final refusal = failure;
    if (refusal != null) {
      throw refusal;
    }
    return next;
  }

  @override
  Future<void> discard(String? photoPath) async => discarded.add(photoPath);
}

Future<Never> _noFolder() async => throw StateError('not used');

void main() {
  late _FakePhotos photos;

  setUp(() => photos = _FakePhotos());

  /// The field as the form holds it: the path lives outside and comes back in,
  /// which is what makes a replaced photo visible to it.
  Future<void> pumpField(WidgetTester tester, {String? photoPath}) async {
    var path = photoPath;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pedalPhotoRepositoryProvider.overrideWithValue(photos)],
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PedalPhotoField(
                photoPath: path,
                onChanged: (chosen) => setState(() => path = chosen),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// What the field is showing, read from the widget the form gave the path to.
  String? shownPath(WidgetTester tester) =>
      tester.widget<PedalPhotoField>(find.byType(PedalPhotoField)).photoPath;

  testWidgets('takes a photo and reports the copy that was kept', (
    tester,
  ) async {
    await pumpField(tester);

    await tap(tester, 'Take photo');

    expect(photos.asked, [PhotoSource.camera]);
    expect(shownPath(tester), '/photos/pedal_1.jpg');
  });

  testWidgets('asks the gallery when that is what was tapped', (tester) async {
    await pumpField(tester);

    await tap(tester, 'Choose photo');

    expect(photos.asked, [PhotoSource.gallery]);
  });

  testWidgets('backing out of the camera leaves the pedal as it was', (
    tester,
  ) async {
    await pumpField(tester, photoPath: '/photos/saved.jpg');
    photos.next = null;

    await tap(tester, 'Take photo');

    // Nothing was chosen, so nothing is reported and nothing is deleted either.
    expect(shownPath(tester), '/photos/saved.jpg');
    expect(photos.discarded, isEmpty);
  });

  testWidgets('a camera that cannot be opened says so and changes nothing', (
    tester,
  ) async {
    await pumpField(tester);
    photos.failure = const AppFailure('Could not open the camera.');

    await tap(tester, 'Take photo');

    expect(find.text('Could not open the camera.'), findsOne);
    expect(shownPath(tester), isNull);
  });

  testWidgets('removing a photo takes it off the pedal', (tester) async {
    await pumpField(tester, photoPath: '/photos/saved.jpg');

    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pumpAndSettle();

    expect(shownPath(tester), isNull);
    // The saved file is not touched: the pedal on screen still points at it, and
    // the form may yet be backed out of.
    expect(photos.discarded, isEmpty);
  });

  testWidgets('there is nothing to remove until there is a photo', (
    tester,
  ) async {
    await pumpField(tester);

    expect(find.byTooltip('Remove photo'), findsNothing);
  });

  testWidgets('a shot thought better of is cleaned up when replaced', (
    tester,
  ) async {
    await pumpField(tester);

    await tap(tester, 'Take photo');
    photos.next = '/photos/pedal_2.jpg';
    await tap(tester, 'Take photo');

    // The first shot was never the pedal's, so leaving it in the app's folder
    // with nothing pointing at it would be a file nobody can ever reach.
    expect(photos.discarded, ['/photos/pedal_1.jpg']);
    expect(shownPath(tester), '/photos/pedal_2.jpg');
  });

  testWidgets('the photo the pedal was saved with is never deleted here', (
    tester,
  ) async {
    await pumpField(tester, photoPath: '/photos/saved.jpg');

    await tap(tester, 'Take photo');

    // Replacing it in the form is not the same as saving the form. Until then the
    // pedal still points at the old file.
    expect(photos.discarded, isEmpty);
    expect(shownPath(tester), '/photos/pedal_1.jpg');
  });
}
