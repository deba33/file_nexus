import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileOperations {
  Future<void> navigateToDirectory(
    String path,
    Function(String, List<FileSystemEntity>) onSuccess,
    Function(String) onError,
  ) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        final files = await directory.list().toList();
        onSuccess(path, files);
      }
    } catch (e) {
      onError('Error opening directory: $e');
    }
  }

  void navigateUp(String currentPath, Function(String) onNavigate) {
    final parent = Directory(currentPath).parent;
    if (parent.path != currentPath) {
      onNavigate(parent.path);
    }
  }

  Future<void> loadRootDirectory(
    Function(String) onNavigate,
    Function() onFallback,
  ) async {
    try {
      const rootPath = '/storage/emulated/0';
      final directory = Directory(rootPath);

      if (await directory.exists()) {
        onNavigate(rootPath);
      } else {
        // Fallback to default directory if root storage is not accessible
        onFallback();
      }
    } catch (e) {
      debugPrint('Error accessing root directory: $e');
      // Fallback to default directory
      onFallback();
    }
  }

  Future<void> loadInitialDirectory(
    BuildContext context,
    Function(String) onNavigate,
    Function(String) onError,
  ) async {
    try {
      Directory? directory = await getExternalStorageDirectory();
      directory ??= await getApplicationDocumentsDirectory();
      await navigateToDirectory(
        directory.path,
        (path, files) => onNavigate(path),
        onError,
      );
    } catch (e) {
      onError('Error loading files: $e');
    }
  }
}
