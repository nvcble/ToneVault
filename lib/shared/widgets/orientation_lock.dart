import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Holds the device in [orientations] for as long as [child] is the page the
/// user is looking at, and hands every orientation back otherwise.
///
/// A screen asks for this by wrapping itself rather than the app setting one
/// preference globally: only some screens - a wide control surface played with
/// both thumbs - have a side they are meant to be held. On platforms with no
/// rotation to lock (desktop, web) this is a no-op, which is why nothing here
/// branches on platform.
///
/// "On screen" means on top, not merely mounted. A page pushed over this one
/// stays mounted underneath it, and the lock used to hold the whole stack
/// sideways: every screen opened from a landscape control surface came up in
/// landscape, however it was designed. So the lock lifts while something
/// covers this page and goes back on when it is uncovered.
class OrientationLock extends StatefulWidget {
  const OrientationLock({
    required this.child,
    this.orientations = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    super.key,
  });

  final Widget child;
  final List<DeviceOrientation> orientations;

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  /// How far whatever is on top of this page has come in - 0 while nothing is.
  Animation<double>? _covering;

  /// What was last asked for, so the ticks of a transition do not each send
  /// the same request over the platform channel again.
  List<DeviceOrientation>? _requested;

  @override
  void initState() {
    super.initState();
    _request(widget.orientations);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final covering = ModalRoute.of(context)?.secondaryAnimation;
    if (covering == _covering) {
      return;
    }
    _covering?.removeListener(_followCover);
    _covering = covering?..addListener(_followCover);
    _followCover();
  }

  @override
  void dispose() {
    _covering?.removeListener(_followCover);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _followCover() => _request(
    (_covering?.value ?? 0) == 0
        ? widget.orientations
        : DeviceOrientation.values,
  );

  void _request(List<DeviceOrientation> orientations) {
    if (_requested == orientations) {
      return;
    }
    _requested = orientations;
    SystemChrome.setPreferredOrientations(orientations);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
