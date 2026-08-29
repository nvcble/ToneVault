import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell around the four top-level tabs.
///
/// Four rather than five: the Academy is reached from the header of whichever
/// tab the user is on, not from a destination of its own. A bar of five reads as
/// a list to work through, and the Academy is somewhere you go and come back
/// from rather than a part of the collection to keep an eye on.
class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // `initialLocation: true` re-taps back to the tab's root, which is the
        // behaviour users expect from a bottom bar.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Pedals'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
