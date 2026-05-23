import '../../models/project_config.dart';
import '../../utils/file_writer.dart';

abstract class ExtrasGenerator {
  ExtrasGenerator({
    required this.config,
    required this.fileWriter,
  });

  final ProjectConfig config;
  final FileWriter fileWriter;

  Future<void> generate();
}