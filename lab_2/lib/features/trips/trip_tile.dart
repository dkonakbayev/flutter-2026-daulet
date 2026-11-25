import 'package:flutter/material.dart';

import '../../core/format/date_text.dart';
import 'trip.dart';

class TripTile extends StatelessWidget {
  const TripTile(
    this.trip, {
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final Trip trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(child: Text('${trip.rating}')),
    title: Text(trip.countryName),
    subtitle: Text(
      '${DateText.of(trip.startDate)} → ${DateText.of(trip.endDate)}'
      ' · ${trip.days} days\n'
      '${trip.status.label} · budget ${trip.budget.toStringAsFixed(0)}',
    ),
    isThreeLine: true,
    onTap: onEdit,
    trailing: PopupMenuButton<VoidCallback>(
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(value: onEdit, child: const Text('Edit')),
        PopupMenuItem(value: onDelete, child: const Text('Delete')),
      ],
    ),
  );
}
