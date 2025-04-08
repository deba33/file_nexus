import 'dart:io';
import 'package:flutter/material.dart';
import '../models/file_system_model.dart';

class FilePreviewWidget extends StatelessWidget {
  final FileSystemEntity? selectedFile;
  final FileSystemModel fileSystemModel;

  const FilePreviewWidget({
    super.key,
    required this.selectedFile,
    required this.fileSystemModel,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFile == null) {
      return const Center(
        child: Text('Select a file to Preview', style: TextStyle(fontSize: 16)),
      );
    }

    final fileName = selectedFile!.path.split('/').last;
    final isDirectory = FileSystemEntity.isDirectorySync(selectedFile!.path);
    final fileType =
        isDirectory ? 'Directory' : fileSystemModel.getFileType(fileName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const Divider(height: 1),
        // File preview section
        Expanded(child: _buildFilePreview(fileType)),
      ],
    );
  }

  Widget _buildFilePreview(String fileType) {
    if (selectedFile == null) {
      return const Center(child: Text('No file selected'));
    }

    switch (fileType) {
      case 'Image':
        return _buildImagePreview();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.insert_drive_file, size: 64),
              const SizedBox(height: 16),
              Text('Preview not available for $fileType files'),
            ],
          ),
        );
    }
  }

  Widget _buildImagePreview() {
    try {
      return Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            File(selectedFile!.path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Failed to load image'),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error previewing image: ${e.toString()}'),
          ],
        ),
      );
    }
  }
}
