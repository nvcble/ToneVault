import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tone_vault/features/academy/data/curriculum_files.dart';
import 'package:tone_vault/features/academy/providers/curriculum_transfer_providers.dart';

/// One file the app tried to send.
typedef SentCurriculum = ({String contents, String fileName});

/// The share sheet and the file picker, as things a test can read and set.
///
/// Neither exists under a test binding, and neither is the app's own code: what is
/// worth testing is that a curriculum leaves as the right file and that whatever
/// arrives is checked before it is written.
class FakeCurriculumFiles {
  /// What the picker hands back. Null stands for the user backing out of it, which
  /// is not a failure and has to change nothing.
  String? offers;

  /// Set to throw instead, standing for a file that cannot be read at all.
  Object? refuses;

  final List<SentCurriculum> sent = <SentCurriculum>[];

  SentCurriculum? get last => sent.isEmpty ? null : sent.last;

  CurriculumSender get sender => _send;

  CurriculumChooser get chooser => _choose;

  Future<void> _send(String contents, {required String fileName}) async {
    sent.add((contents: contents, fileName: fileName));
  }

  Future<String?> _choose() async {
    final refusal = refuses;
    if (refusal != null) {
      throw refusal;
    }
    return offers;
  }
}

List<Override> curriculumFileOverrides(FakeCurriculumFiles files) => [
  curriculumSenderProvider.overrideWithValue(files.sender),
  curriculumChooserProvider.overrideWithValue(files.chooser),
];
