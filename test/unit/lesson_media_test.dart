import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/values/lesson_media.dart';

/// The video and the picture a lesson hands the player, worked out from what the
/// lesson already says rather than stored beside it.
void main() {
  group('the video to open', () {
    test('a lesson that names one opens that one', () {
      expect(
        lessonVideoUrl(
          title: 'Em and Am',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
    });

    test('and one that names none searches for itself', () {
      // A search rather than no button at all: a player who learns by watching is
      // one tap from the same thing they would have typed themselves.
      expect(
        lessonVideoUrl(title: 'Em and Am'),
        'https://www.youtube.com/results?search_query=Em+and+Am+guitar+lesson',
      );
    });

    test('a title with punctuation in it still makes a usable link', () {
      expect(
        lessonVideoUrl(title: 'Barre chords: F & B'),
        'https://www.youtube.com/results'
        '?search_query=Barre+chords%3A+F+%26+B+guitar+lesson',
      );
    });
  });

  group('the still to show', () {
    test('a watch link carries the picture YouTube already keeps', () {
      expect(
        youTubeThumbnailUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      );
    });

    test('a short link and an embed are the same video', () {
      expect(youTubeVideoId('https://youtu.be/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(
        youTubeVideoId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('a search is not a video and gets no picture', () {
      // The last segment of a search URL is the word `results`, and a still built
      // from it would be a banner that 404s on every uncurated lesson.
      expect(youTubeThumbnailUrl(lessonVideoUrl(title: 'Em and Am')), isNull);
      expect(
        youTubeVideoId('https://www.youtube.com/playlist?list=PL1234567890a'),
        isNull,
      );
    });

    test('and neither does a link to somewhere else, or no link at all', () {
      expect(youTubeThumbnailUrl('https://example.com/dQw4w9WgXcQ'), isNull);
      expect(youTubeThumbnailUrl(null), isNull);
      expect(youTubeThumbnailUrl('not a url at all'), isNull);
    });
  });
}
