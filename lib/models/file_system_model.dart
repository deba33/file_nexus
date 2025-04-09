import 'package:intl/intl.dart';

class FileSystemModel {
  final DateFormat dateFormat = DateFormat('MMM dd, yyyy HH:mm');
  final NumberFormat sizeFormat = NumberFormat('#,##0.## KB');

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 KB';
    return sizeFormat.format(bytes / 1024);
  }

  String getFileType(String fileName) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

    final typeMap = {
      'jpg': 'Image',
      'jpeg': 'Image',
      'png': 'Image',
      'gif': 'Image',
      'pdf': 'Document',
      'txt': 'Text',
      'mp3': 'Audio',
      'wav': 'Audio',
      'mp4': 'Video',
      'avi': 'Video',
      'mkv': 'Video',
      'zip': 'Archive',
      'rar': 'Archive',
    };

    return typeMap[extension] ?? extension;
  }

  bool isAtRootDirectory(String path) {
    return path == '/storage/emulated/0';
  }
}
