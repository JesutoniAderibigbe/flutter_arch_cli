import '../../models/project_config.dart';
import '../../utils/file_writer.dart';

abstract class StateManagementGenerator {
  StateManagementGenerator({
    required this.config,
    required this.fileWriter,
  });

  final ProjectConfig config;
  final FileWriter fileWriter;

  Future<void> generate();

  String get sampleStateFolder {
    return switch (config.stateManagement) {
      StateManagement.riverpod => 'providers',
      StateManagement.bloc => 'bloc',
      StateManagement.provider => 'providers',
    };
  }

  String get featureBasePath {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => 'lib/features/sample/presentation/$sampleStateFolder',
      Architecture.featureFirst => 'lib/features/sample/$sampleStateFolder',
    };
  }
}