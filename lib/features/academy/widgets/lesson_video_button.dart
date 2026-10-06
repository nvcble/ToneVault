import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/values/lesson_media.dart';
import '../../../shared/widgets/failure_snack_bar.dart';

/// The way out of the app to somebody teaching this lesson on video.
///
/// Every lesson has one, whether or not the curriculum named a video: a lesson that
/// names none opens a YouTube search for its own title, which is what a player who
/// learns by watching would have typed themselves. The one place in the app that
/// opens a link, so the lesson screen and its banner both go through here.
class LessonVideoButton extends StatelessWidget {
  const LessonVideoButton({required this.lesson, super.key});

  final AcademyLesson lesson;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => watchLesson(context, lesson),
      icon: const Icon(Icons.play_circle_outline),
      // Named for where it goes rather than for what it is: a player is about to
      // leave ToneVault, and the button is what tells them so beforehand.
      label: const Text('Watch on YouTube'),
    );
  }
}

/// Opens the lesson's video, or says why it could not.
///
/// A failure here is worth a snack bar and nothing else. A phone with no browser and
/// no YouTube is unusual rather than impossible, and the lesson is still there to be
/// read either way.
Future<void> watchLesson(BuildContext context, AcademyLesson lesson) async {
  final url = lessonVideoUrl(title: lesson.title, videoUrl: lesson.videoUrl);
  try {
    // Externally rather than in a web view: YouTube is an app on most phones, and a
    // video is watched better there than in a panel inside another app.
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      throw const AppFailure('Nothing on this phone could open that video.');
    }
  } catch (error) {
    if (context.mounted) {
      showFailureSnackBar(context, error);
    }
  }
}
