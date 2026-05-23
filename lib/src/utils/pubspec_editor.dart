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