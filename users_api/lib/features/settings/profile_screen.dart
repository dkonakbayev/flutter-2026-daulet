import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return; // Cancel gives null
      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(picked.path)
          .copy('${dir.path}${Platform.pathSeparator}avatar.jpg');
      await FileImage(saved).evict(); // same path, so drop the old pixels
      if (!mounted) return;
      await context.read<SettingsModel>().setAvatar(saved.path);
    } on PlatformException {
      if (mounted) _say('The camera or gallery is not available');
    } on FileSystemException {
      if (mounted) _say('Could not save the photo');
    }
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request(); // at the tap
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _say(
          'The camera is needed for a new photo. '
          'You can still choose one from the gallery.',
        );
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        await _askSettings();
    }
  }

  Future<void> _askSettings() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Camera access is off'),
        content: const Text(
          'To take a photo, allow the camera in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.select<SettingsModel, String?>((s) => s.avatarPath);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: path == null ? null : FileImage(File(path)),
              child: path == null ? const Icon(Icons.person, size: 56) : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
