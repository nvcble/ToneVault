/// The picture and the video a lesson shows, worked out rather than stored.
///
/// A lesson may name either in the curriculum file, and almost none do. What is here
/// is what the app shows instead: a YouTube search a player can actually watch
/// something on, and - where a lesson does name a video - the still YouTube already
/// keeps of it, so a curated lesson gets a real photograph for free rather than
/// needing a second URL written beside the first.
library;

/// The video to open for a lesson: the one it names, or a YouTube search for it.
///
/// A search rather than nothing, because "no video was curated for this lesson" is a
/// fact about the curriculum and not about the player, who learns by watching either
/// way. A search always resolves, which a guessed video id does not.
String lessonVideoUrl({required String title, String? videoUrl}) =>
    videoUrl ?? youTubeSearchUrl('$title guitar lesson');

String youTubeSearchUrl(String query) =>
    'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(query)}';

/// The still YouTube keeps of a video, or null where the link is not a video - a
/// search URL, or a page on another site.
///
/// `hqdefault` rather than `maxresdefault`: every video has one, where the largest
/// size is only there for videos uploaded in high definition and 404s for the rest.
String? youTubeThumbnailUrl(String? videoUrl) {
  final id = youTubeVideoId(videoUrl);
  return id == null ? null : 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}

/// The id out of a YouTube link, in the three shapes one is written in: a watch URL,
/// a `youtu.be` short link, and an embed. Null for anything else.
String? youTubeVideoId(String? videoUrl) {
  final url = videoUrl == null ? null : Uri.tryParse(videoUrl);
  if (url == null || !url.host.contains('youtu')) {
    return null;
  }

  final id = url.queryParameters['v'] ?? url.pathSegments.lastOrNull;
  // 11 characters of the URL alphabet is what a video id is. Checked so that the
  // last segment of `/results` or `/playlist` is not taken for one.
  return id != null && RegExp(r'^[\w-]{11}$').hasMatch(id) ? id : null;
}
