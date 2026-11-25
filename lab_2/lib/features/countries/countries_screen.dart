import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/list_state_view.dart';
import '../../core/widgets/message_view.dart';
import '../../core/widgets/stale_banner.dart';
import 'countries_model.dart';
import 'countries_view.dart';
import 'region_chips.dart';

/// Catalogue list: search by name through the API (debounced), filter by
/// region, pull to refresh.
class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _submit(text));
  }

  void _submit(String text) {
    _debounce?.cancel();
    unawaited(context.read<CountriesModel>().search(text));
  }

  void _clear() {
    _search.clear();
    _submit('');
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<CountriesModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _submit,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name',
              ),
            ),
          ),
          const RegionChips(),
          if (m.fromCache && m.error == null) StaleBanner(onRetry: m.load),
          Expanded(
            child: ListStateView(
              loading: m.loading,
              error: m.error,
              isEmpty: m.items.isEmpty,
              onRetry: m.load,
              empty: MessageView(
                icon: Icons.travel_explore,
                text: 'No countries match your search.',
                actionLabel: 'Clear search',
                onAction: _clear,
              ),
              child: CountriesView(m.items, onRefresh: m.load),
            ),
          ),
        ],
      ),
    );
  }
}
