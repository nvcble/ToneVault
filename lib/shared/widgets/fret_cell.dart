import 'package:flutter/material.dart';

/// One fret of one string: the string across it, the wire at its end, and the note
/// marked on it where the diagram has one there.
///
/// Split out of the fretboard because a neck is a hundred of these and the interesting
/// part of the widget above is which of them are marked, not how a single one looks.
class FretCell extends StatelessWidget {
  const FretCell({
    required this.stringWeight,
    required this.isNut,
    this.label,
    this.isRoot = false,
    this.isMuted = false,
    super.key,
  });

  /// The degree or the note name to write in the dot, or null to leave the fret bare.
  final String? label;

  /// The root is marked differently, because a shape is only useful once a player
  /// knows where in it the key is.
  final bool isRoot;

  /// How thick to draw the string. A wound low E does not look like a plain high E,
  /// and the difference is how a player finds the right line at a glance.
  final double stringWeight;

  /// Whether the wire at the end of this fret is the nut rather than a fret wire.
  final bool isNut;

  /// Whether this string is deadened rather than played, which a chord box says with an
  /// `x` and this says by drawing the string faintly the whole way along. A player has
  /// to be able to see at a glance that a string is out, not read for it.
  final bool isMuted;

  static const double height = 34;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = label;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isNut ? scheme.onSurfaceVariant : scheme.outlineVariant,
              width: isNut ? 3 : 1,
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: stringWeight,
              color: isMuted
                  ? scheme.outlineVariant.withValues(alpha: 0.35)
                  : scheme.outlineVariant,
            ),
            if (text != null)
              _Marker(label: text, isRoot: isRoot, isMuted: isMuted),
          ],
        ),
      ),
    );
  }
}

/// The dot itself, with what it is called inside it.
class _Marker extends StatelessWidget {
  const _Marker({
    required this.label,
    required this.isRoot,
    this.isMuted = false,
  });

  final String label;
  final bool isRoot;

  /// A muted string's `x` is not a dot: there is nothing to press, so there is nothing
  /// to draw a fingertip on.
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (this) {
          _ when isMuted => Colors.transparent,
          _ when isRoot => scheme.primary,
          _ => scheme.surfaceContainerHighest,
        },
        border: Border.all(
          color: isMuted
              ? Colors.transparent
              : (isRoot ? scheme.primary : scheme.outlineVariant),
        ),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: switch (this) {
                _ when isMuted => scheme.onSurfaceVariant,
                _ when isRoot => scheme.onPrimary,
                _ => scheme.onSurface,
              },
              fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
