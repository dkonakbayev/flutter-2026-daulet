import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/shift.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Shift _shift;
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _shift = widget.args.shift;
    _now = DateTime.now();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _me => widget.args.profileName.trim();

  void _apply(Shift updated) {
    setState(() => _shift = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _signUp() async {
    if (_me.isEmpty) {
      _askForName();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign up?'),
        content: Text('Add $_me to "${_shift.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _apply(_shift.signUp(_me));
  }

  void _withdraw() => _apply(_shift.withdraw(_me));

  void _askForName() {
    final showProfile = widget.args.onShowProfile;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Enter your name in Profile first'),
        action: SnackBarAction(
          label: 'Profile',
          onPressed: () {
            if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
            showProfile();
          },
        ),
      ),
    );
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Shift>(
      context,
      Routes.form,
      arguments: FormArgs(_shift),
    );
    if (edited == null || !mounted) return;
    _apply(edited);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete shift?'),
        content: Text('"${_shift.title}" will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_shift);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final (:taken, free: _) = _shift.places;
    final joined = _shift.contains(_me);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_shift.title, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(shift: _shift, countdown: _shift.countdownAt(_now)),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Volunteers ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(shift: _shift),
                  _VolunteersTab(shift: _shift, me: _me),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: joined
                ? OutlinedButton.icon(
                    onPressed: _withdraw,
                    icon: const Icon(Icons.logout),
                    label: const Text('Withdraw'),
                  )
                : FilledButton.icon(
                    onPressed: _shift.isFull ? null : _signUp,
                    icon: const Icon(Icons.volunteer_activism),
                    label: Text(_shift.isFull ? 'Full' : 'Sign up'),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.shift, required this.countdown});

  final Shift shift;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(
                shift.cause.icon,
                size: 40,
                color: shift.cause.color(scheme),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(shift.cause.icon),
              label: Text(shift.cause.label),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(countdownLabel(countdown)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = shift.places;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(shift.startsAt)),
          subtitle: Text(shift.isPast ? 'Past' : 'Upcoming'),
        ),
        ListTile(
          leading: Icon(shift.online ? Icons.link : Icons.place_outlined),
          title: Text(shift.place),
          subtitle: Text(shift.online ? 'Online — meeting link' : 'Address'),
        ),
        ListTile(
          leading: const Icon(Icons.groups_outlined),
          title: Text('$taken of ${shift.slots} places taken'),
          subtitle: Text(free == 0 ? 'No free places' : '$free free'),
        ),
        if (shift.notes case final notes?)
          ListTile(leading: const Icon(Icons.notes), title: Text(notes)),
      ],
    );
  }
}

class _VolunteersTab extends StatelessWidget {
  const _VolunteersTab({required this.shift, required this.me});

  final Shift shift;
  final String me;

  @override
  Widget build(BuildContext context) {
    if (shift.volunteers.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off_outlined,
        message: 'Nobody has signed up yet',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final bold = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(fontWeight: FontWeight.bold);

    return ListView(
      children: shift.volunteers.map((name) {
        final isMe = name.toLowerCase() == me.toLowerCase();
        return ListTile(
          leading: Icon(isMe ? Icons.person : Icons.person_outline),
          title: Text(isMe ? '$name (You)' : name, style: isMe ? bold : null),
          tileColor: isMe ? scheme.primaryContainer : null,
        );
      }).toList(),
    );
  }
}
