import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// A fixed-size grid of [itemCount] tiles, split into swipeable pages with
/// chevrons and a "Page x of y" readout.
///
/// Knows nothing about MIDI, patches or any device: it takes a count and a
/// builder, so any list of small equal tiles can be paged this way.
class PagedGrid extends StatefulWidget {
  const PagedGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.columns = 3,
    this.rows = 4,
    this.tileHeight = 76,
    this.initialPage = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    super.key,
  });

  final int itemCount;

  /// Builds the tile for a flat index into the whole collection, not into the
  /// current page - callers should not have to know the paging arithmetic.
  final Widget Function(BuildContext context, int index) itemBuilder;

  final int columns;
  final int rows;
  final double tileHeight;

  /// Around the tiles themselves, inside the pager. Zero where the grid is the
  /// widest thing on its page and the page's own padding already holds it off
  /// the edge.
  final EdgeInsets padding;

  /// The page open on first build - so a grid holding a current selection can
  /// start where that selection is rather than at the beginning. Only read
  /// once: after that the page is the user's to change.
  final int initialPage;

  int get perPage => columns * rows;

  @override
  State<PagedGrid> createState() => _PagedGridState();
}

class _PagedGridState extends State<PagedGrid> {
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _controller = PageController(initialPage: _page);
  }

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
    final pages = PageView.builder(
      controller: _controller,
      itemCount: _pageCount,
      onPageChanged: (page) => setState(() => _page = page),
      itemBuilder: (context, page) => _buildPage(page),
    );
    return Column(
      children: [
        SizedBox(height: _gridHeight, child: pages),
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

  double get _gridHeight =>
      widget.rows * widget.tileHeight +
      (widget.rows - 1) * AppSpacing.sm +
      widget.padding.vertical;

  Widget _buildPage(int page) {
    final first = page * widget.perPage;
    final count = (widget.itemCount - first).clamp(0, widget.perPage);
    return GridView.builder(
      padding: widget.padding,
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
