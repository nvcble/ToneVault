import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'patch_grid_tile.dart';

/// The device's 128 Program Change slots, 20 to a page (4 columns by 5 rows),
/// sliding between pages like a carousel rather than cutting straight from
/// one set of tiles to the next.
///
/// A tap pre-selects a slot; a double tap loads it - see [PatchGridTile].
class PatchNumberCarousel extends StatefulWidget {
  const PatchNumberCarousel({
    required this.selected,
    required this.onSelected,
    required this.onLoad,
    this.loaded,
    this.patchNames = const {},
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

  static const _columns = 4;
  static const _rows = 5;
  static const _tileHeight = 80.0;
  static const perPage = _columns * _rows;
  static const totalSlots = 128;
  static const _gridHeight = _rows * _tileHeight + (_rows - 1) * AppSpacing.sm;

  static int get pageCount => (totalSlots + perPage - 1) ~/ perPage;

  @override
  State<PatchNumberCarousel> createState() => _PatchNumberCarouselState();
}

class _PatchNumberCarouselState extends State<PatchNumberCarousel> {
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.selected ~/ PatchNumberCarousel.perPage;
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = PatchNumberCarousel.pageCount;
    return Column(
      children: [
        SizedBox(
          height: PatchNumberCarousel._gridHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: pageCount,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, page) => _buildPage(page),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
            ),
            Text('Page ${_page + 1} of $pageCount'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _page < pageCount - 1 ? () => _goTo(_page + 1) : null,
            ),
          ],
        ),
        Text(_labelFor(widget.selected), style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  String _labelFor(int number) => widget.patchNames[number] ?? 'Patch ${number + 1}';

  // A carousel slide rather than a jump cut - the transition the brief asks
  // for when the page changes, whether by chevron or by swipe.
  void _goTo(int page) =>
      _controller.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.ease);

  Widget _buildPage(int page) {
    final first = page * PatchNumberCarousel.perPage;
    final count = (PatchNumberCarousel.totalSlots - first).clamp(0, PatchNumberCarousel.perPage);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: PatchNumberCarousel._columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: PatchNumberCarousel._tileHeight,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final number = first + index; // 0-based Program Change value
        return PatchGridTile(
          number: number + 1,
          label: _labelFor(number),
          selected: number == widget.selected,
          loaded: number == widget.loaded,
          onTap: () => widget.onSelected(number),
          onDoubleTap: () => widget.onLoad(number),
        );
      },
    );
  }
}
