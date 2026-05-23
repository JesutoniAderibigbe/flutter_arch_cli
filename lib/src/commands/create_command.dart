import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../generators/project_generator.dart';
import '../prompts/interactive_prompts.dart';

class CreateCommand extends Command<int> {
  CreateCommand({required this.logger});

  final Logger logger;

  @override
  String get name => 'create';

  @override
  String get description =>
      'Create a new Flutter project with a chosen architecture and state management.';

  @override
  String get invocation => 'flutter_arch create <project_name>';

  @override
  Future<int> run() async {
    final args = argResults?.rest ?? [];

    if (args.isEmpty) {
      logger.err('Project name is required.');
      logger.info('Usage: $invocation');
      return ExitCode.usage.code;
    }

    final projectName = args.first;

    if (!_isValidProjectName(projectName)) {
      logger.err(
        'Invalid project name. Use lowercase letters, numbers and underscores. '
        'It must start with a letter.',
      );
      return ExitCode.usage.code;
    }

    if (Directory(projectName).existsSync()) {
      logger.err('A folder named "$projectName" already exists here.');
      return ExitCode.cantCreate.code;
    }

    final config = InteractivePrompts(logger: logger).run(
      projectName: projectName,
    );

    logger.info('');
    final generator = ProjectGenerator(config: config, logger: logger);
    final success = await generator.generate();

    if (!success) {
      logger.err('Project generation failed.');
      return ExitCode.software.code;
    }

    logger.info('');
    logger.success('Done. Your project is ready at ./$projectName');
    logger.info('');
    logger.info('Next steps:');
    logger.info('  cd $projectName');
    logger.info('  flutter run');

    return ExitCode.success.code;
  }

  bool _isValidProjectName(String name) {
    final pattern = RegExp(r'^[a-z][a-z0-9_]*$');
    return pattern.hasMatch(name);
  }
}