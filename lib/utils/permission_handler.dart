import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FilePermissionHandler {
  Future<void> requestPermissionsAndLoadFiles(
    BuildContext context,
    Function() onLoadRoot,
    Function() onLoadInitial,
    Function(String) onShowSnackBar,
  ) async {
    if (Platform.isAndroid) {
      // Check Android version for the appropriate permission strategy
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        // Android 11 (API level 30) and above
        // Check for MANAGE_EXTERNAL_STORAGE permission
        final status = await Permission.manageExternalStorage.status;

        if (status.isGranted) {
          onLoadRoot();
        } else {
          // Show a dialog explaining why we need the permission
          // Store context.mounted check for the dialog
          if (!context.mounted) return;

          final shouldRequest = await _showPermissionDialog(context);
          if (!context.mounted) return;

          if (shouldRequest) {
            final result = await Permission.manageExternalStorage.request();
            if (result.isGranted) {
              onLoadRoot();
            } else {
              _showPermissionDeniedMessage(onShowSnackBar);
            }
          } else {
            _showPermissionDeniedMessage(onShowSnackBar);
          }
        }
      } else {
        // For older Android versions, request basic storage permission
        final status = await Permission.storage.request();
        if (status.isGranted) {
          onLoadRoot();
        } else {
          _showPermissionDeniedMessage(onShowSnackBar);
        }
      }
    } else {
      // For non-Android platforms
      onLoadInitial();
    }
  }

  void _showPermissionDeniedMessage(Function(String) onShowSnackBar) {
    onShowSnackBar('Storage permission is required to access all files');
  }

  Future<bool> _showPermissionDialog(BuildContext context) async {
    // This method only uses the context to show a dialog and doesn't have any await calls
    // before using the context, so it's safe as is.
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
              'This app needs full access to storage to browse all your files. '
              'Please grant "All files access" permission on the next screen.\n\n'
              'After granting permission, you\'ll be able to access all files on your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}
