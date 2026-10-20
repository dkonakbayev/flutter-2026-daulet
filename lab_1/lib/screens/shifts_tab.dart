import 'package:flutter/material.dart';

import '../models/cause.dart';
import '../models/shift.dart';
import '../widgets/empty_state.dart';
import '../widgets/shift_list_view.dart';

class ShiftsTab extends StatefulWidget {
  const ShiftsTab({
    super.key,
    required this.shifts,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Shift> shifts;
  final ValueChanged<Shift> onOpen;
  final ValueChanged<Shift> onToggleFavourite;

  @override
  State<ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends State<ShiftsTab> {
  final _search = TextEditingController();
  String _query = '';
  Cause? _cause;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  List<Shift> get _visible {
    final query = _query.trim().toLowerCase();
    return sortedByDate(
      widget.shifts.where(
        (s) =>
            (_showPast || !s.isPast) &&
            (_cause == null || s.cause == _cause) &&
            s.title.toLowerCase().contains(query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search shifts',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _cause == null,
                onSelected: (_) => setState(() => _cause = null),
              ),
              for (final cause in Cause.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(cause.icon),
                    showCheckmark: false,
                    label: Text(cause.label),
                    selected: _cause == cause,
                    onSelected: (_) => setState(() => _cause = cause),
                  ),
                ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No shifts match your filters',
                  actionLabel: _query.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : ShiftListView(
                  shifts: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
