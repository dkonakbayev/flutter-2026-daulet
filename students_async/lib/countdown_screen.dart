import 'package:flutter/material.dart';

import 'countdown.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StreamBuilder Countdown'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<int>(
        stream: countdown(5),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return const Center(child: Text('Countdown finished'));
          }

          return Center(
            child: Text(
              snapshot.data?.toString() ?? 'Starting...',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
