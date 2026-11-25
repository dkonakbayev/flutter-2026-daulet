import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_error_message.dart';
import '../../core/api/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/list_state_view.dart';
import '../../core/widgets/message_view.dart';
import 'trip.dart';
import 'trip_tile.dart';
import 'trips_model.dart';

/// "My trips": the collection from MockAPI.io with create, edit, delete.
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  static void _say(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  static Future<void> _open(BuildContext context, [Trip? trip]) async {
    final saved = await Navigator.of(context)
        .pushNamed<Trip>(AppRoutes.tripForm, arguments: trip);
    if (saved == null || !context.mounted) return;
    _say(context, 'Trip to ${saved.countryName} saved');
  }

  static Future<void> _delete(BuildContext context, Trip trip) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this trip?'),
        content: Text('${trip.countryName} will be removed from the server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    try {
      await context.read<TripsModel>().delete(trip.id);
      if (context.mounted) _say(context, 'Trip deleted');
    } on ApiException catch (e) {
      if (context.mounted) _say(context, ApiErrorMessage.of(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<TripsModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('My trips')),
      body: ListStateView(
        loading: m.loading,
        error: m.error,
        isEmpty: m.items.isEmpty,
        onRetry: m.load,
        empty: MessageView(
          icon: Icons.luggage_outlined,
          text: 'No trips yet. Plan your first one.',
          actionLabel: 'Add trip',
          onAction: () => _open(context),
        ),
        child: RefreshIndicator(
          onRefresh: m.load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: m.items.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) => TripTile(
              m.items[i],
              onEdit: () => _open(context, m.items[i]),
              onDelete: () => _delete(context, m.items[i]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _open(context),
        tooltip: 'Add trip',
        child: const Icon(Icons.add),
      ),
    );
  }
}
