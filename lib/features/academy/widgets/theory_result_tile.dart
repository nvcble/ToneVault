import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theory/data/theory_search.dart';
import 'theory_diagram_sheet.dart';

/// One thing the theory engine found, and the way to look at it.
///
/// A diagram opens in a sheet and a topic opens its tab, which is the same split the
/// bookmark list makes: a chord is something to glance at and put down, and the circle of
/// fifths is somewhere to go. Nothing is read from the database either way - the engine
/// draws what it found from the words it found it by.
class TheoryResultTile extends StatelessWidget {
  const TheoryResultTile({required this.found, super.key});

  final TheoryFound found;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_icon),
      title: Text(found.title),
      subtitle: Text(found.kind),
      trailing: Icon(switch (found) {
        TheoryDiagramFound() => Icons.open_in_full,
        TheoryTopicFound() => Icons.chevron_right,
      }),
      onTap: () => switch (found) {
        TheoryDiagramFound(:final title, :final theoryKeys) => _show(
          context,
          title,
          theoryKeys,
        ),
        TheoryTopicFound(:final route) => context.push<void>(route),
      },
    );
  }

  IconData get _icon => switch (found.kind) {
    'Chord' => Icons.piano_outlined,
    'Scale' => Icons.linear_scale,
    'Mode' => Icons.rotate_right,
    'Interval' => Icons.straighten,
    'Arpeggio' => Icons.stairs_outlined,
    'Progression' => Icons.timeline,
    'Substitution' => Icons.swap_horiz,
    _ => Icons.school_outlined,
  };

  Future<void> _show(
    BuildContext context,
    String title,
    List<String> theoryKeys,
  ) => showModalBottomSheet<void>(
    context: context,
    // The same height a kept shape is given: a neck needs more than nine sixteenths
    // of a screen, and one cut off at the bottom loses the frets being taught.
    isScrollControlled: true,
    builder: (context) =>
        TheoryDiagramSheet(title: title, theoryKeys: theoryKeys),
  );
}
