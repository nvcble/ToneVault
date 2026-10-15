import 'package:flutter/material.dart';

import '../../../shared/widgets/paged_grid.dart';
import 'patch_grid_tile.dart';

/// The device's 128 Program Change slots, [columns] by [rows] to a page,
/// sliding between pages like a carousel rather than cutting from one set of
/// tiles to the next.
///
/// A handful of big slots a page rather than many small ones: this is the
/// control a player hits mid-song. Each tile takes an equal share of whatever
/// height the page has going spare, so the grid fills the screen instead of
/// leaving a gap under itself, and a tile is wide enough to read a patch name
/// off.
///
/// A tap pre-selects a slot; a double tap loads it - see [PatchGridTile]. The
/// paging itself is the generic [PagedGrid].
class PatchNumberCarousel extends StatelessWidget {
  const PatchNumberCarousel({
    required this.selected,
    required this.onSelected,
    required this.onLoad,
    this.loaded,
    this.patchNames = const {},
    this.columns = 4,
    this.rows = 2,
    super.key,
  });

  /// The Program Change number selected (pre-selected, bordered), 0-127.
  final int selected;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onLoad;

  /// The number last actually loaded (double-tapped), if any - filled rather
  /// than bordered. Null before anything has been loaded.
  final int? loaded;

  /// Program number to patch name, for the slots a real patch has been given.
  final Map<int, String> patchNames;

  final int columns;
  final int rows;

  static const int totalSlots = 128;

  int get perPage => columns * rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The grid takes the height left over once the name line below has
        // had its own, and shares it out between its rows - see
        // `PagedGrid.tileHeight`.
        Expanded(
          child: PagedGrid(
            itemCount: totalSlots,
            columns: columns,
            rows: rows,
            selectedPage: selected ~/ perPage,
            // No indent of its own: the grid is the widest thing on the page
            // and the page's padding already holds it off the edge.
            padding: EdgeInsets.zero,
            itemBuilder: _buildTile,
          ),
        ),
        // The full name of the selection, which a tile can only show the
        // start of.
        Text(
          _labelFor(selected),
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, int number) => PatchGridTile(
    number: number + 1, // 0-based Program Change value, 1-based on the unit
    label: _labelFor(number),
    selected: number == selected,
    loaded: number == loaded,
    onTap: () => onSelected(number),
    onDoubleTap: () => onLoad(number),
  );

  String _labelFor(int number) => patchNames[number] ?? 'Patch ${number + 1}';
}
