import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_arch_cli/src/commands/create_command.dart';
import 'package:mason_logger/mason_logger.dart';

Future<void> main(List<String> arguments) async {
  final logger = Logger();
  final runner = CommandRunner<int>(
    'flutter_arch',
    'A CLI tool to scaffold Flutter projects with clean architecture and your preferred state management.',
  )..addCommand(CreateCommand(logger: logger));

  try {
    final exitCode = await runner.run(arguments) ?? ExitCode.success.code;
    exit(exitCode);
  } on UsageException catch (e) {
    logger.err(e.message);
    logger.info(e.usage);
    exit(ExitCode.usage.code);
  } catch (e) {
    logger.err('An unexpected error occurred: $e');
    exit(ExitCode.software.code);
  }
}