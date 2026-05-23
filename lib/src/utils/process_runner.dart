import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

class ProcessRunner {
  ProcessRunner({required this.logger});

  final Logger logger;

  Future<bool> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool silent = false,
  }) async {
    if (!silent) {
      logger.detail('Running: $executable ${arguments.join(' ')}');
    }

    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    if (!silent) {
      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        stdout.write(data);
      });
      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        stderr.write(data);
      });
    }

    final exitCode = await process.exitCode;
    return exitCode == 0;
  }
}