import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// A fixed-size grid of [itemCount] tiles, split into swipeable pages with
/// chevrons and a "Page x of y" readout.
///
/// Knows nothing about MIDI, patches or any device: it takes a count and a
/// builder, so any list of small equal tiles can be paged this way. That is
/// what makes it shareable - `PatchNumberCarousel` predates it and keeps its
/// own copy, since changing a working device's screen to adopt this one would
/// be a refactor of that device rather than a use of this widget.
class PagedGrid extends StatefulWidget {
  const PagedGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.columns = 3,
    this.rows = 4,
    this.tileHeight = 76,
    super.key,
  });

  final int itemCount;

  /// Builds the tile for a flat index into the whole collection, not into the
  /// current page - callers should not have to know the paging arithmetic.
  final Widget Function(BuildContext context, int index) itemBuilder;

  final int columns;
  final int rows;
  final double tileHeight;

  int get perPage => columns * rows;

  @override
  State<PagedGrid> createState() => _PagedGridState();
}

class _PagedGridState extends State<PagedGrid> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PagedGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A shrinking collection - a search being typed into, in practice - can
    // leave the controller on a page that no longer exists, which renders
    // blank. Snap back rather than strand the user on nothing.
    if (_page >= _pageCount) {
      _page = _pageCount - 1;
      _controller.jumpToPage(_page);
    }
  }

  int get _pageCount => widget.itemCount == 0
      ? 1
      : (widget.itemCount + widget.perPage - 1) ~/ widget.perPage;

  @override
  Widget build(BuildContext context) {
    final gridHeight =
        widget.rows * widget.tileHeight + (widget.rows - 1) * AppSpacing.sm;
    return Column(
      children: [
        SizedBox(
          height: gridHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: _pageCount,
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
            Text('Page ${_page + 1} of $_pageCount'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _page < _pageCount - 1 ? () => _goTo(_page + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 250),
    curve: Curves.ease,
  );

  Widget _buildPage(int page) {
    final first = page * widget.perPage;
    final count = (widget.itemCount - first).clamp(0, widget.perPage);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: widget.tileHeight,
      ),
      itemCount: count,
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, first + index),
    );
  }
}
