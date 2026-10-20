import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/shift.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.shifts,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Shift> shifts;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{2,4}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_name.text != widget.profile.name) _name.text = widget.profile.name;
    if (_group.text != widget.profile.group) _group.text = widget.profile.group;
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.length < 2) return 'Enter at least 2 characters';
    if (name.length > 40) return 'At most 40 characters';
    return null;
  }

  String? _validateGroup(String? value) {
    final group = (value ?? '').trim();
    if (group.isEmpty) return null;
    return _groupPattern.hasMatch(group) ? null : 'Format: SE-2401';
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onChanged(
      Profile(name: _name.text.trim(), group: _group.text.trim()),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    final lists = widget.shifts.fold(
      0,
      (count, s) => s.contains(name) ? count + 1 : count,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Your name',
                helperText: 'Press Enter to save',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: _validateName,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _group,
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'SE-2401',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: _validateGroup,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            Text(
              widget.profile.hasName
                  ? 'You are on $lists lists'
                  : 'Enter your name to sign up for shifts',
              style: theme.textTheme.titleMedium,
            ),
            const Divider(height: 40),
            Text('Theme', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in ThemeMode.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      ThemeMode.system => 'System',
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                    }),
                    selected: widget.themeMode == mode,
                    onSelected: (_) => widget.onThemeModeChanged(mode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
