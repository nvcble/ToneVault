import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// A grid of [itemCount] tiles, split into swipeable pages with chevrons and a
/// "Page x of y" readout.
///
/// Knows nothing about MIDI, patches or any device: it takes a count and a
/// builder, so any list of small equal tiles can be paged this way.
class PagedGrid extends StatefulWidget {
  const PagedGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.columns = 3,
    this.rows = 4,
    this.tileHeight,
    this.selectedPage = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    super.key,
  });

  final int itemCount;

  /// Builds the tile for a flat index into the whole collection, not into the
  /// current page - callers should not have to know the paging arithmetic.
  final Widget Function(BuildContext context, int index) itemBuilder;

  final int columns;
  final int rows;

  /// A fixed height per tile, or null - the default - to share out the height
  /// the grid is handed between its rows. Sharing it out is what lets a page
  /// of tiles fill the screen it is on and never need scrolling: the grid
  /// takes exactly the room it is given, whatever that is.
  ///
  /// Where nothing bounds the height at all - inside a scroll view - there is
  /// nothing to share, so a null height falls back to [_unboundedTileHeight].
  final double? tileHeight;

  /// Around the tiles themselves, inside the pager. Zero where the grid is the
  /// widest thing on its page and the page's own padding already holds it off
  /// the edge.
  final EdgeInsets padding;

  /// The page holding whatever the caller counts as selected: the grid opens
  /// there rather than at the beginning, and goes there again whenever it
  /// changes - which is how picking a tile out of a search lands on it.
  ///
  /// Swiping is still the user's own: a caller only moves this when the
  /// selection itself moves, and a selection the user tapped is on the page
  /// they are already looking at.
  final int selectedPage;

  int get perPage => columns * rows;

  /// The pager row under the tiles, which comes out of the height before the
  /// rows share what is left.
  static const double _pagerHeight = AppSpacing.minTouchTarget;

  /// What a tile gets where the height is unbounded and there is nothing to
  /// share out - big enough to read a label off and to hit.
  static const double _unboundedTileHeight = 76;

  @override
  State<PagedGrid> createState() => _PagedGridState();
}

class _PagedGridState extends State<PagedGrid> {
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.selectedPage;
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
    // The selection has moved off this page - picked out of a search, or
    // loaded from somewhere else - so follow it there.
    if (widget.selectedPage != oldWidget.selectedPage) {
      _goTo(widget.selectedPage, animate: false);
    }
    // A shrinking collection can leave the controller on a page that no
    // longer exists, which renders blank. Snap back rather than strand the
    // user on nothing.
    if (_page >= _pageCount) {
      _goTo(_pageCount - 1, animate: false);
    }
  }

  int get _pageCount => widget.itemCount == 0
      ? 1
      : (widget.itemCount + widget.perPage - 1) ~/ widget.perPage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          _build(_tileHeightFor(constraints.maxHeight)),
    );
  }

  /// The height one row takes: the fixed one if the caller named it, otherwise
  /// an equal share of what is left of [available] once the pager and the gaps
  /// are out of it. Clamped off zero only so an impossibly short page reports
  /// an overflow rather than failing an assertion.
  double _tileHeightFor(double available) {
    final fixed = widget.tileHeight;
    if (fixed != null) {
      return fixed;
    }
    if (!available.isFinite) {
      return PagedGrid._unboundedTileHeight;
    }
    final forRows =
        available -
        PagedGrid._pagerHeight -
        (widget.rows - 1) * AppSpacing.sm -
        widget.padding.vertical;
    return (forRows / widget.rows).clamp(1, double.infinity);
  }

  Widget _build(double tileHeight) {
    final pages = PageView.builder(
      controller: _controller,
      itemCount: _pageCount,
      onPageChanged: (page) => setState(() => _page = page),
      itemBuilder: (context, page) => _buildPage(page, tileHeight),
    );
    return Column(
      children: [
        SizedBox(height: _gridHeight(tileHeight), child: pages),
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

  /// Jumps rather than slides where the move was not a page turn: sliding
  /// seventeen pages to a searched-for patch is a blur, not an animation.
  void _goTo(int page, {bool animate = true}) {
    _page = page;
    if (animate) {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    } else {
      _controller.jumpToPage(page);
    }
  }

  double _gridHeight(double tileHeight) =>
      widget.rows * tileHeight +
      (widget.rows - 1) * AppSpacing.sm +
      widget.padding.vertical;

  Widget _buildPage(int page, double tileHeight) {
    final first = page * widget.perPage;
    final count = (widget.itemCount - first).clamp(0, widget.perPage);
    return GridView.builder(
      padding: widget.padding,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: tileHeight,
      ),
      itemCount: count,
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, first + index),
    );
  }
}
