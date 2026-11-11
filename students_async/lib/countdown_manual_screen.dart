import 'dart:async';

import 'package:flutter/material.dart';

import 'countdown.dart';

class CountdownManualScreen extends StatefulWidget {
  const CountdownManualScreen({super.key});

  @override
  State<CountdownManualScreen> createState() => _CountdownManualScreenState();
}

class _CountdownManualScreenState extends State<CountdownManualScreen> {
  int? _value;
  bool _finished = false;

  late StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = countdown(5).listen(
      (value) {
        if (!mounted) return;

        setState(() {
          _value = value;
        });
      },
      onDone: () {
        if (!mounted) return;

        setState(() {
          _finished = true;
        });
      },
    );
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Countdown'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _finished
            ? const Text('Countdown finished')
            : Text(
                _value?.toString() ?? 'Starting...',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
