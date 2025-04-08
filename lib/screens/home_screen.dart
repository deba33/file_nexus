import 'dart:io';

import 'package:flutter/material.dart';

import '../models/file_system_model.dart';
import '../utils/file_operations.dart';
import '../utils/permission_handler.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/file_metadata_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FileSystemEntity> _files = [];
  String _currentPath = '';
  FileSystemEntity? _selectedFile;

  // Initialize the helper classes
  final FileSystemModel _fileSystemModel = FileSystemModel();
  final FileOperations _fileOperations = FileOperations();
  final FilePermissionHandler _permissionHandler = FilePermissionHandler();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsAndLoadFiles();
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestPermissionsAndLoadFiles() async {
    await _permissionHandler.requestPermissionsAndLoadFiles(
      context,
      () => _loadRootDirectory(),
      () => _loadInitialDirectory(),
      _showSnackBar,
    );
  }

  Future<void> _loadRootDirectory() async {
    await _fileOperations.loadRootDirectory(
      (path) => _navigateToDirectory(path),
      () => _loadInitialDirectory(),
    );
  }

  Future<void> _loadInitialDirectory() async {
    await _fileOperations.loadInitialDirectory(
      context,
      (path) => _navigateToDirectory(path),
      (error) => _showSnackBar(error),
    );
  }

  Future<void> _navigateToDirectory(String path) async {
    await _fileOperations.navigateToDirectory(
      path,
      (path, files) {
        if (!mounted) return;
        setState(() {
          _currentPath = path;
          _files = files;
          _selectedFile = null;
        });
      },
      (error) {
        _showSnackBar(error);
      },
    );
  }

  void _navigateUp() {
    _fileOperations.navigateUp(
      _currentPath,
      (path) => _navigateToDirectory(path),
    );
  }

  void _selectFile(FileSystemEntity file) {
    setState(() {
      _selectedFile = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('File Nexus'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _navigateToDirectory(_currentPath),
            ),
          ],
        ),
        body: Column(
          children: [
            // Top container for file metadata
            Flexible(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.blue),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FileMetadataWidget(
                  selectedFile: _selectedFile,
                  fileSystemModel: _fileSystemModel,
                ),
              ),
            ),

            // Bottom container for file listing
            Flexible(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.green),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FileListWidget(
                  currentPath: _currentPath,
                  files: _files,
                  selectedFile: _selectedFile,
                  fileSystemModel: _fileSystemModel,
                  onNavigateToDirectory: _navigateToDirectory,
                  onNavigateUp: _navigateUp,
                  onSelectFile: _selectFile,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
