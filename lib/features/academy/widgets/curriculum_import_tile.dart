import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/curriculum_document.dart';
import '../data/curriculum_summary.dart';
import '../providers/academy_providers.dart';
import '../providers/curriculum_transfer_providers.dart';
import 'curriculum_import_dialog.dart';

/// Reads a curriculum file and, once the user has said what to do about anything
/// already here, writes it into the Academy.
///
/// Read, described, asked about, then written - four steps, in that order. A file
/// that is not a curriculum, or is one from a newer version of the app, is refused
/// before the question is asked; and the question names the courses that would be
/// rewritten, so agreeing to it is agreeing to something specific.
///
/// This is not a course editor. The file is written by whoever wrote the curriculum,
/// and the app's part is to check it and put it in.
class CurriculumImportTile extends ConsumerStatefulWidget {
  const CurriculumImportTile({super.key});

  @override
  ConsumerState<CurriculumImportTile> createState() =>
      _CurriculumImportTileState();
}

class _CurriculumImportTileState extends ConsumerState<CurriculumImportTile> {
  bool _isWorking = false;

  Future<void> _import() async {
    try {
      final file = await ref.read(curriculumChooserProvider)();
      // Backed out of the picker: not a failure, and nothing to say about it.
      if (file == null || !mounted) {
        return;
      }

      // Decoded before anything else happens, so a photo or a half-downloaded
      // document is refused without the Academy being touched.
      final courses = decodeCurriculum(file);
      final importer = ref.read(curriculumImporterProvider);
      final alreadyStored = await importer.coursesAlreadyStored(courses);
      if (!mounted) {
        return;
      }

      final answer = await askAboutCurriculum(
        context,
        courses: courses,
        alreadyStored: alreadyStored,
      );
      if (answer == null || !mounted) {
        return;
      }

      // Only now is there anything to wait for. The picker and the question are the
      // user's own time, and a spinner behind a modal says nothing.
      setState(() => _isWorking = true);
      final result = await importer.importCourses(courses, onConflict: answer);
      if (mounted) {
        _report(describeImported(result));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted && _isWorking) {
        setState(() => _isWorking = false);
      }
    }
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download_outlined),
      title: const Text('Import a curriculum'),
      subtitle: const Text(
        'Add courses and lessons from a file somebody sent you.',
      ),
      trailing: _isWorking
          ? const SizedBox.square(
              dimension: AppSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _isWorking ? null : _import,
    );
  }
}
