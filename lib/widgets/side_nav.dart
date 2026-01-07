import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggleTheme;

  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: IconButton(
          tooltip: 'Toggle theme',
          icon: const Icon(Icons.dark_mode),
          onPressed: onToggleTheme,
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.event),
          label: Text('Events'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.groups),
          label: Text('Clubs'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
