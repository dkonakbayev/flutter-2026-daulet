import 'package:flutter/material.dart';

import 'icon_tile.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onReset});

  final VoidCallback onAbout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Volunteer Shifts',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          IconTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              onAbout();
            },
          ),
          IconTile(
            icon: Icons.restore,
            title: 'Reset data',
            onTap: () {
              Navigator.pop(context);
              onReset();
            },
          ),
        ],
      ),
    );
  }
}
