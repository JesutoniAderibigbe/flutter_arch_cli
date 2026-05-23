import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

class PubspecEditor {
  PubspecEditor(this.projectPath);

  final String projectPath;

  Future<void> addDependencies(Map<String, String> dependencies) async {
    if (dependencies.isEmpty) return;
    await _addToSection('dependencies', dependencies);
  }

  Future<void> addDevDependencies(Map<String, String> dependencies) async {
    if (dependencies.isEmpty) return;
    await _addToSection('dev_dependencies', dependencies);
  }

  Future<void> addAssets(List<String> assetPaths) async {
    if (assetPaths.isEmpty) return;

    final pubspecPath = p.join(projectPath, 'pubspec.yaml');
    final file = File(pubspecPath);
    final contents = await file.readAsString();
    final editor = YamlEditor(contents);

    // flutter create scaffolds an `assets:` section as a comment.
    // We need to insert a real one.
    try {
      editor.update(['flutter', 'assets'], assetPaths);
    } on Exception {
      // 'assets' key didn't exist; create it.
      editor.update(['flutter', 'assets'], assetPaths);
    }

    await file.writeAsString(editor.toString());
  }

  Future<void> _addToSection(
    String section,
    Map<String, String> dependencies,
  ) async {
    final pubspecPath = p.join(projectPath, 'pubspec.yaml');
    final file = File(pubspecPath);
    final contents = await file.readAsString();
    final editor = YamlEditor(contents);

    for (final entry in dependencies.entries) {
      editor.update([section, entry.key], entry.value);
    }

    await file.writeAsString(editor.toString());
  }
}