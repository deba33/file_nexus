import 'dart:io';
import 'package:flutter/material.dart';
import '../models/file_system_model.dart';

class FileMetadataWidget extends StatelessWidget {
  final FileSystemEntity? selectedFile;
  final FileSystemModel fileSystemModel;

  const FileMetadataWidget({
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

    final fileStat = selectedFile!.statSync();
    final fileName = selectedFile!.path.split('/').last;
    final isDirectory = FileSystemEntity.isDirectorySync(selectedFile!.path);
    final fileType =
        isDirectory ? 'Directory' : fileSystemModel.getFileType(fileName);
    final fileSize =
        isDirectory ? '-' : fileSystemModel.formatBytes(fileStat.size);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fileName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: $fileType'),
                  const SizedBox(height: 4),
                  Text('Size: $fileSize'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modified: ${fileSystemModel.dateFormat.format(fileStat.modified)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${fileSystemModel.dateFormat.format(fileStat.changed)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
