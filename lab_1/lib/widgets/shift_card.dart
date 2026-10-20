import 'package:flutter/material.dart';

import '../models/shift.dart';
import '../utils/format.dart';
import 'shift_avatar.dart';

class ShiftCard extends StatelessWidget {
  const ShiftCard({
    super.key,
    required this.shift,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Shift shift;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              ShiftAvatar(shift: shift),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    _line(
                      Icons.schedule,
                      shift.isPast
                          ? '${formatDateTime(shift.startsAt)} · past'
                          : formatDateTime(shift.startsAt),
                      muted,
                    ),
                    _line(
                      shift.online ? Icons.link : Icons.place_outlined,
                      shift.place,
                      muted,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: shift.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                icon: Icon(shift.favourite ? Icons.star : Icons.star_border),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text, TextStyle? style) {
    return Row(
      children: [
        Icon(icon, size: 16, color: style?.color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
