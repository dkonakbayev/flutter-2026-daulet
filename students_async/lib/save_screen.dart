import 'package:flutter/material.dart';

import 'api/fake_api.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  final _api = FakeApi();

  bool _saving = false;
  String? _errorMessage;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await _api.save(100);

      if (!mounted) return;

      Navigator.pop(context);
    } on StateError catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message.toString();
        _saving = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Data'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
