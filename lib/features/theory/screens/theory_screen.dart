import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../data/theory_tab.dart';
import '../widgets/chord_family_table.dart';
import '../widgets/chord_library.dart';
import '../widgets/circle_of_fifths_wheel.dart';
import '../widgets/key_picker.dart';
import '../widgets/progression_list.dart';
import '../widgets/scale_explorer.dart';
import '../widgets/substitution_list.dart';

/// The theory browser: one key, looked at six ways.
///
/// The key picker sits above the tabs rather than inside one of them, because the six
/// views are six answers to the same question and a player moving between them is
/// asking about the key they are already in. Changing key changes all six at once.
///
/// Nothing here is stored. Every list on every tab is worked out from the key by the
/// engine in `lib/core/music`, so there is no theory content to keep up to date and no
/// chance of the browser disagreeing with what the lessons teach.
class TheoryScreen extends StatelessWidget {
  const TheoryScreen({this.tab = TheoryTab.chords, super.key});

  /// The tab to arrive on. Chords by default, which is where a player who opened the
  /// browser without saying what for is most often going.
  final TheoryTab tab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TheoryTab.values.length,
      initialIndex: tab.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theory'),
          actions: [
            // In the header, because "what does 1 5 6 4 mean" is a question a player has
            // while looking at one of the tabs rather than a topic they go looking for.
            IconButton(
              onPressed: () => context.push(Routes.academyTheoryNashville),
              tooltip: 'The number system',
              icon: const Icon(Icons.pin_outlined),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final tab in TheoryTab.values) Tab(text: tab.label)],
          ),
        ),
        body: Column(
          children: [
            const KeyPicker(),
            const Divider(height: 1),
            // In the order [TheoryTab] declares, which is what makes a tab nameable
            // from outside this screen.
            const Expanded(
              child: TabBarView(
                children: [
                  ChordFamilyTable(),
                  ChordLibrary(),
                  ScaleExplorer(),
                  ProgressionList(),
                  SubstitutionList(),
                  CircleOfFifthsWheel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
