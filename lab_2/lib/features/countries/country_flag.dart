import 'package:flutter/material.dart';

class CountryFlag extends StatelessWidget {
  const CountryFlag(this.url, {super.key, required this.width});

  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(Icons.flag_outlined, size: width * 0.6);
    final u = url;
    if (u == null) return SizedBox(width: width, child: placeholder);
    return Image.network(
      u,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          SizedBox(width: width, child: placeholder),
    );
  }
}
