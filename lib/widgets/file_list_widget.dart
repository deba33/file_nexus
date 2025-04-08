import 'dart:io';
import 'package:flutter/material.dart';
import '../models/file_system_model.dart';

enum ViewMode { list, grid }

class FileListWidget extends StatefulWidget {
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
  State<FileListWidget> createState() => _FileListWidgetState();
}

class _FileListWidgetState extends State<FileListWidget> {
  ViewMode _viewMode = ViewMode.list;

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
    });
  }

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
                    widget.fileSystemModel.isAtRootDirectory(widget.currentPath)
                        ? null
                        : widget.onNavigateUp,
                tooltip: 'Go up',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Path: ${widget.currentPath}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  _viewMode == ViewMode.list ? Icons.grid_view : Icons.list,
                ),
                onPressed: _toggleViewMode,
                tooltip: _viewMode == ViewMode.list ? 'Grid view' : 'List view',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // File list
        Expanded(
          child:
              widget.files.isEmpty
                  ? const Center(child: Text('No files or folders found'))
                  : _viewMode == ViewMode.list
                  ? _buildListView()
                  : _buildGridView(),
        ),
      ],
    );
  }

  // Helper methods
  String _getFileName(FileSystemEntity file) {
    return file.path.split('/').last;
  }

  bool _isDirectory(FileSystemEntity file) {
    return FileSystemEntity.isDirectorySync(file.path);
  }

  bool _isSelected(FileSystemEntity file) {
    return widget.selectedFile?.path == file.path;
  }

  void _handleFileTap(FileSystemEntity file) {
    if (_isDirectory(file)) {
      widget.onNavigateToDirectory(file.path);
    } else {
      widget.onSelectFile(file);
    }
  }

  Icon _getFileIcon(FileSystemEntity file) {
    final isDir = _isDirectory(file);

    if (isDir) {
      return Icon(
        Icons.folder,
        color: Colors.amber,
        size: _viewMode == ViewMode.grid ? 40 : 24,
      );
    } else {
      // Get file type from the model
      final fileName = _getFileName(file);
      final fileType = widget.fileSystemModel.getFileType(fileName);

      // Return appropriate icon based on file type
      IconData iconData;
      Color iconColor;

      switch (fileType) {
        case 'Image':
          iconData = Icons.image;
          iconColor = Colors.green;
          break;
        case 'Document':
          iconData = Icons.description;
          iconColor = Colors.blue;
          break;
        case 'Text':
          iconData = Icons.article;
          iconColor = Colors.teal;
          break;
        case 'Audio':
          iconData = Icons.audio_file;
          iconColor = Colors.purple;
          break;
        case 'Video':
          iconData = Icons.video_file;
          iconColor = Colors.red;
          break;
        case 'Archive':
          iconData = Icons.archive;
          iconColor = Colors.brown;
          break;
        default:
          iconData = Icons.insert_drive_file;
          iconColor = Colors.blue;
      }

      return Icon(
        iconData,
        color: iconColor,
        size: _viewMode == ViewMode.grid ? 40 : 24,
      );
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: widget.files.length,
      itemBuilder: (context, index) {
        final file = widget.files[index];

        return ListTile(
          leading: _getFileIcon(file),
          title: Text(_getFileName(file), overflow: TextOverflow.ellipsis),
          selected: _isSelected(file),
          selectedTileColor: Colors.blue.withAlpha(100),
          onTap: () => _handleFileTap(file),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      itemCount: widget.files.length,
      itemBuilder: (context, index) {
        final file = widget.files[index];
        final isSelected = _isSelected(file);

        return InkWell(
          onTap: () => _handleFileTap(file),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withAlpha(100) : null,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getFileIcon(file),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    _getFileName(file),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
