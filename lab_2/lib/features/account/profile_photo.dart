import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'settings_model.dart';

/// The avatar with "Gallery" and "Camera". The camera permission is asked
/// at the tap; every status is handled.
class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({super.key});

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return; // Cancel → null
      // documents, not temporary: the photo must survive a restart
      final dir = await getApplicationDocumentsDirectory();
      final name = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final saved = await File(picked.path)
          .copy('${dir.path}${Platform.pathSeparator}$name');
      if (!mounted) return;
      final settings = context.read<SettingsModel>();
      final old = settings.photoPath;
      await settings.setPhoto(saved.path);
      if (old != null) await File(old).delete();
    } on PlatformException {
      if (mounted) _say('The camera or gallery is not available');
    } on FileSystemException {
      if (mounted) _say('Could not save the photo');
    }
  }

  Future<void> _camera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _say(
          'Without the camera you can still choose a photo from the gallery.',
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
        content: const Text('To take a photo, allow the camera in Settings.'),
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
    final path = context.select<SettingsModel, String?>((s) => s.photoPath);
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: path == null ? null : FileImage(File(path)),
          child: path == null ? const Icon(Icons.person, size: 48) : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Gallery'),
            ),
            TextButton.icon(
              onPressed: _camera,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Camera'),
            ),
          ],
        ),
      ],
    );
  }
}
