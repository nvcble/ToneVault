import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/curriculum_transfer_providers.dart';

/// Sends this one course on as a file.
///
/// In the course's own header rather than on the curriculum screen, because a course
/// is the thing a person passes on: a teacher writes one and gives it to a student,
/// and picking it out of a list of everything the app holds would be a list to read
/// before the sending starts.
class CourseExportAction extends ConsumerStatefulWidget {
  const CourseExportAction({required this.courseId, super.key});

  final int courseId;

  @override
  ConsumerState<CourseExportAction> createState() => _CourseExportActionState();
}

class _CourseExportActionState extends ConsumerState<CourseExportAction> {
  bool _isWorking = false;

  Future<void> _export() async {
    setState(() => _isWorking = true);

    try {
      final export = await ref
          .read(curriculumExporterProvider)
          .exportCourse(widget.courseId);
      await ref.read(curriculumSenderProvider)(
        export.contents,
        fileName: export.fileName,
      );
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isWorking) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SizedBox.square(
            dimension: AppSpacing.lg,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _export,
      tooltip: 'Send this course on',
      icon: const Icon(Icons.share_outlined),
    );
  }
}
