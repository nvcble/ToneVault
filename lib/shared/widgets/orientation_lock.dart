import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Holds the device in [orientations] for as long as [child] is on screen, and
/// hands every orientation back on the way out.
///
/// A screen asks for this by wrapping itself rather than the app setting one
/// preference globally: only some screens - a wide control surface played with
/// both thumbs - have a side they are meant to be held. On platforms with no
/// rotation to lock (desktop, web) this is a no-op, which is why nothing here
/// branches on platform.
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
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(widget.orientations);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
