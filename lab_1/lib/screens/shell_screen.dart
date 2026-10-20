import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/shift.dart';
import '../routes.dart';
import '../widgets/app_drawer.dart';
import 'favourites_tab.dart';
import 'profile_tab.dart';
import 'shifts_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const _titles = ['Shifts', 'Favourites', 'Profile'];
  static const profileTab = 2;

  List<Shift> _shifts = seedShifts();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  void _updateShift(Shift updated) => setState(
    () => _shifts = [
      for (final s in _shifts)
        if (s.id == updated.id) updated else s,
    ],
  );

  void _deleteShift(Shift shift) =>
      setState(() => _shifts = _shifts.where((s) => s.id != shift.id).toList());

  void _toggleFavourite(Shift shift) => _updateShift(shift.toggleFavourite());

  void _updateProfile(Profile profile) => setState(() => _profile = profile);

  void _openDetail(Shift shift) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        shift: shift,
        profileName: _profile.name,
        onChanged: _updateShift,
        onDelete: _deleteShift,
        onShowProfile: () => _selectTab(profileTab),
      ),
    );
  }

  Future<void> _addShift() async {
    final created = await Navigator.pushNamed<Shift>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _shifts = [..._shifts, created]);
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volunteer Shifts'),
        content: const Text(
          'Find volunteering shifts in your city, keep favourites '
          'and sign up with one tap.\n\nLab 1 · Mobile Development',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All shifts go back to the starting list and your profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _shifts = seedShifts();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: AppDrawer(onAbout: _showAbout, onReset: _resetData),
      body: IndexedStack(
        index: _tab,
        children: [
          ShiftsTab(
            shifts: _shifts,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            shifts: _shifts,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _selectTab(0),
          ),
          ProfileTab(
            profile: _profile,
            shifts: _shifts,
            onChanged: _updateProfile,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              tooltip: 'New shift',
              onPressed: _addShift,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Shifts',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
