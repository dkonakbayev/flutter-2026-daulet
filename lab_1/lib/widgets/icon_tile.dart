import 'package:flutter/material.dart';

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleStyle,
    this.tileColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final Color? tileColor;

  static const _iconGap = 16.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: tileColor,
      title: Row(
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: _iconGap),
          Expanded(child: Text(title, style: titleStyle)),
        ],
      ),
      subtitle: switch (subtitle) {
        final text? => Padding(
          padding: const EdgeInsets.only(left: _iconSize + _iconGap),
          child: Text(text),
        ),
        null => null,
      },
    );
  }
}
