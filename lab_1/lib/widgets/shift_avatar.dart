import 'package:flutter/material.dart';

import '../models/shift.dart';

class ShiftAvatar extends StatelessWidget {
  const ShiftAvatar({super.key, required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = shift.cause.color(scheme);
    final (:taken, :free) = shift.places;

    return SizedBox(
      width: 56,
      height: 60,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(shift.cause.icon, color: color),
            ),
          ),
          if (shift.isFull)
            _badge(context, 'FULL', scheme.error, scheme.onError)
          else if (free <= 5)
            _badge(context, '$free left', scheme.tertiary, scheme.onTertiary),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String text, Color bg, Color fg) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
