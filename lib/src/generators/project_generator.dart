import 'dart:io';

import 'package:flutter_arch_cli/src/generators/extras/assets_generator.dart';
import 'package:flutter_arch_cli/src/generators/extras/lint_generator.dart';
import 'package:flutter_arch_cli/src/generators/extras/main_dart_generator.dart';
import 'package:flutter_arch_cli/src/generators/extras/networking_generator.dart';
import 'package:flutter_arch_cli/src/generators/extras/storage_generator.dart';
import 'package:flutter_arch_cli/src/generators/extras/tests_generator.dart';
import 'package:flutter_arch_cli/src/generators/extras/theming_generator.dart';
import 'package:flutter_arch_cli/src/generators/state_management/bloc_generator.dart';
import 'package:flutter_arch_cli/src/generators/state_management/provider_generator.dart';
import 'package:flutter_arch_cli/src/generators/state_management/riverpod_generator.dart';
import 'package:flutter_arch_cli/src/utils/pubspec_editor.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../models/project_config.dart';
import '../utils/file_writer.dart';
import '../utils/process_runner.dart';
import 'architectures/clean_architecture_generator.dart';
import 'architectures/feature_first_generator.dart';
import 'extras/agent_context_generator.dart';

class ProjectGenerator {
  ProjectGenerator({
    required this.config,
    required this.logger,
  });

  final ProjectConfig config;
  final Logger logger;

  late final String projectPath;
  late final FileWriter fileWriter;
  late final ProcessRunner processRunner;

  Future<bool> generate() async {
    projectPath = p.join(Directory.current.path, config.projectName);
    fileWriter = FileWriter(projectPath);
    processRunner = ProcessRunner(logger: logger);

    if (!await _runFlutterCreate()) return false;
    await _cleanDefaults();
    await _scaffoldArchitecture();
    await _scaffoldStateManagement();
    await _scaffoldExtras();
    await _addDependencies();
    await _scaffoldMainDart();
    if (!await _runPubGet()) return false;
    await _runBuildRunner();

    return true;
  }

  Future<void> _runBuildRunner() async {
    if (!config.useCodegen) return;

    final progress = logger.progress('Running build_runner');
    final success = await processRunner.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: projectPath,
      silent: true,
    );

    if (success) {
      progress.complete('Code generation complete');
    } else {
      progress.fail('build_runner failed');
      logger.info('');
      logger.warn(
        'You can run code generation manually:\n'
        '  cd ${config.projectName}\n'
        '  dart run build_runner build --delete-conflicting-outputs',
      );
    }
  }

  Future<void> _scaffoldMainDart() async {
    final progress = logger.progress('Generating main.dart');
    await MainDartGenerator(config: config, fileWriter: fileWriter).generate();
    progress.complete('main.dart generated');
  }

  Future<void> _scaffoldExtras() async {
    final progress = logger.progress('Scaffolding extras');

    await AssetsGenerator(config: config, fileWriter: fileWriter).generate();

    if (config.extras.contains(Extra.agentContext)) {
  await AgentContextGenerator(config: config, fileWriter: fileWriter).generate();
}

    if (config.extras.contains(Extra.networking)) {
      await NetworkingGenerator(config: config, fileWriter: fileWriter)
          .generate();
    }
    if (config.extras.contains(Extra.storage)) {
      await StorageGenerator(config: config, fileWriter: fileWriter).generate();
    }
    if (config.extras.contains(Extra.theming)) {
      await ThemingGenerator(config: config, fileWriter: fileWriter).generate();
    }
    if (config.extras.contains(Extra.linting)) {
      await LintGenerator(config: config, fileWriter: fileWriter).generate();
    }
    if (config.extras.contains(Extra.tests)) {
      await TestsGenerator(config: config, fileWriter: fileWriter).generate();
    }

    progress.complete('Extras scaffolded');
  }

  Future<bool> _runFlutterCreate() async {
    final progress = logger.progress('Running flutter create');
    final success = await processRunner.run(
      'flutter',
      [
        'create',
        '--org',
        config.organization,
        '--platforms',
        'android,ios',
        config.projectName,
      ],
      silent: true,
    );

    if (success) {
      progress.complete('Flutter project created');
    } else {
      progress.fail('flutter create failed');
    }
    return success;
  }

  Future<void> _cleanDefaults() async {
    final progress = logger.progress('Cleaning default files');
    await fileWriter.deleteFile('lib/main.dart');
    await fileWriter.deleteFile('test/widget_test.dart');
    progress.complete('Defaults cleaned');
  }

  Future<void> _scaffoldArchitecture() async {
    final progress = logger.progress('Scaffolding architecture');

    final architectureGenerator = switch (config.architecture) {
      Architecture.cleanArchitecture => CleanArchitectureGenerator(
          config: config,
          fileWriter: fileWriter,
        ),
      Architecture.featureFirst => FeatureFirstGenerator(
          config: config,
          fileWriter: fileWriter,
        ),
    };

    await architectureGenerator.generate();
    progress.complete('Architecture scaffolded');
  }

  Future<void> _scaffoldStateManagement() async {
    final progress = logger.progress('Scaffolding state management');

    final stateManagementGenerator = switch (config.stateManagement) {
      StateManagement.riverpod => RiverpodGenerator(
          config: config,
          fileWriter: fileWriter,
        ),
      StateManagement.bloc => BlocGenerator(
          config: config,
          fileWriter: fileWriter,
        ),
      StateManagement.provider => ProviderGenerator(
          config: config,
          fileWriter: fileWriter,
        ),
    };

    await stateManagementGenerator.generate();
    progress.complete('State management scaffolded');
  }

  Future<void> _addDependencies() async {
    final progress = logger.progress('Updating pubspec dependencies');

    final editor = PubspecEditor(projectPath);
    final deps = <String, String>{};
    final devDeps = <String, String>{};

    await editor.addAssets([
      'assets/images/',
      'assets/icons/',
      'assets/animations/',
      'assets/translations/',
    ]);

    // State management
    switch (config.stateManagement) {
      case StateManagement.riverpod:
        deps['flutter_riverpod'] = '^2.5.1';
        if (config.useCodegen) {
          deps['riverpod_annotation'] = '^2.3.5';
          deps['freezed_annotation'] = '^2.4.4';
          devDeps['build_runner'] = '^2.4.13';
          devDeps['riverpod_generator'] = '^2.4.3';
          devDeps['freezed'] = '^2.5.7';
        }
        break;
      case StateManagement.bloc:
        deps['flutter_bloc'] = '^8.1.6';
        break;
      case StateManagement.provider:
        deps['provider'] = '^6.1.2';
        break;
    }
    // Extras
    if (config.extras.contains(Extra.networking)) {
      deps['dio'] = '^5.7.0';
    }
    if (config.extras.contains(Extra.storage)) {
      for (final option in config.storageOptions) {
        switch (option) {
          case Storage.sharedPreferences:
            deps['shared_preferences'] = '^2.3.2';
            break;
          case Storage.hive:
            deps['hive'] = '^2.2.3';
            deps['hive_flutter'] = '^1.1.0';
            break;
          case Storage.isar:
            deps['isar'] = '^3.1.0+1';
            deps['isar_flutter_libs'] = '^3.1.0+1';
            deps['path_provider'] = '^2.1.4';
            break;
          case Storage.sqflite:
            deps['sqflite'] = '^2.3.3+1';
            deps['path'] = '^1.9.0';
            break;
          case Storage.secureStorage:
            deps['flutter_secure_storage'] = '^9.2.2';
            break;
        }
      }
    }
    if (config.extras.contains(Extra.linting)) {
      devDeps['very_good_analysis'] = '^6.0.0';
    }

    await editor.addDependencies(deps);
    await editor.addDevDependencies(devDeps);
    progress.complete('Dependencies updated');
  }

  Future<bool> _runPubGet() async {
    final progress = logger.progress('Running flutter pub get');
    final success = await processRunner.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectPath,
      silent: true,
    );

    if (success) {
      progress.complete('Dependencies installed');
    } else {
      progress.fail('pub get failed');
    }
    return success;
  }
}
