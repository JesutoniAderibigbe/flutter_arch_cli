import 'dart:io';

import 'package:path/path.dart' as p;

class FileWriter {
  FileWriter(this.projectPath);

  final String projectPath;

  Future<void> writeFile(String relativePath, String content) async {
    final fullPath = p.join(projectPath, relativePath);
    final file = File(fullPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<void> createDirectory(String relativePath) async {
    final fullPath = p.join(projectPath, relativePath);
    await Directory(fullPath).create(recursive: true);
  }

  Future<void> deleteFile(String relativePath) async {
    final fullPath = p.join(projectPath, relativePath);
    final file = File(fullPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteDirectory(String relativePath) async {
    final fullPath = p.join(projectPath, relativePath);
    final dir = Directory(fullPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}