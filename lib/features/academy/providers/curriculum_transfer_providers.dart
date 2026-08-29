import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_exporter.dart';
import '../data/curriculum_files.dart';
import 'academy_providers.dart';

/// Getting a curriculum out of the app and one back in.
///
/// Apart from `academy_providers.dart` because these are the only Academy providers
/// that reach outside the app at all: a share sheet and a file picker, neither of
/// which exists under a test binding.
final Provider<CurriculumExporter> curriculumExporterProvider =
    Provider<CurriculumExporter>(
      (ref) => CurriculumExporter(ref.watch(academyCourseDaoProvider)),
    );

/// The share sheet and the file picker, behind providers so a test can send a
/// curriculum to a variable and choose a file that only exists in the test.
///
/// The same seam as backup, and for the same reason: nothing else about importing
/// needs one, because the importer runs happily against an in-memory database.
final Provider<CurriculumSender> curriculumSenderProvider =
    Provider<CurriculumSender>((ref) => shareCurriculumFile);

final Provider<CurriculumChooser> curriculumChooserProvider =
    Provider<CurriculumChooser>((ref) => chooseCurriculumFile);
