import 'package:flutter/material.dart';

import '../models/shift.dart';
import 'shift_card.dart';

class ShiftListView extends StatelessWidget {
  const ShiftListView({
    super.key,
    required this.shifts,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  static const gridBreakpoint = 600.0;
  static const maxCellWidth = 360.0;

  final List<Shift> shifts;
  final ValueChanged<Shift> onOpen;
  final ValueChanged<Shift> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    Widget card(int i) => ShiftCard(
      shift: shifts[i],
      onTap: () => onOpen(shifts[i]),
      onToggleFavourite: () => onToggleFavourite(shifts[i]),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= gridBreakpoint) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCellWidth,
              mainAxisExtent: 128,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: shifts.length,
            itemBuilder: (context, i) => card(i),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: shifts.length,
          separatorBuilder: (context, i) => const SizedBox(height: 8),
          itemBuilder: (context, i) => card(i),
        );
      },
    );
  }
}
