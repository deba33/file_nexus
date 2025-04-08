import 'dart:io';
import 'package:flutter/material.dart';
import '../models/file_system_model.dart';

class FileListWidget extends StatelessWidget {
  final String currentPath;
  final List<FileSystemEntity> files;
  final FileSystemEntity? selectedFile;
  final FileSystemModel fileSystemModel;
  final Function(String) onNavigateToDirectory;
  final Function() onNavigateUp;
  final Function(FileSystemEntity) onSelectFile;

  const FileListWidget({
    super.key,
    required this.currentPath,
    required this.files,
    required this.selectedFile,
    required this.fileSystemModel,
    required this.onNavigateToDirectory,
    required this.onNavigateUp,
    required this.onSelectFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current path and navigation
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed:
                    fileSystemModel.isAtRootDirectory(currentPath)
                        ? null
                        : onNavigateUp,
                tooltip: 'Go up',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Path: $currentPath',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // File list
        Expanded(
          child:
              files.isEmpty
                  ? const Center(child: Text('No files or folders found'))
                  : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      final fileName = file.path.split('/').last;
                      final isDirectory = FileSystemEntity.isDirectorySync(
                        file.path,
                      );

                      return ListTile(
                        leading: Icon(
                          isDirectory ? Icons.folder : Icons.insert_drive_file,
                          color: isDirectory ? Colors.amber : Colors.blue,
                        ),
                        title: Text(fileName, overflow: TextOverflow.ellipsis),
                        selected: selectedFile?.path == file.path,
                        selectedTileColor: Colors.blue.withAlpha(100),
                        onTap: () {
                          if (isDirectory) {
                            onNavigateToDirectory(file.path);
                          } else {
                            onSelectFile(file);
                          }
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
