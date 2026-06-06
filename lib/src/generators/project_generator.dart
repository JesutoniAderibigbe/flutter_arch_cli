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

  // Pre-flight warning for the known build hooks incompatibility
  if (config.useCodegen && config.storageOptions.contains(Storage.secureStorage)) {
    logger.warn(
      'Heads up: Riverpod codegen + flutter_secure_storage may fail at the\n'
      'build_runner step due to a known Dart SDK issue with build hooks.\n'
      '  See: https://github.com/dart-lang/build/issues/4343\n'
      'The project will scaffold correctly either way. Continuing.',
    );
    logger.info('');
  }

  if (!await _runFlutterCreate()) return false;
  await _cleanDefaults();
  await _scaffoldArchitecture();
  await _scaffoldStateManagement();
  await _scaffoldExtras();
  if (!await _addDependencies()) return false;
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
    return;
  }

  progress.fail('build_runner failed');
  logger.info('');

  // If the project uses flutter_secure_storage with codegen, this is almost
  // certainly the known Dart SDK + build_runner + build hooks incompatibility.
  // See: https://github.com/dart-lang/build/issues/4343
  final likelyHooksConflict = config.storageOptions.contains(Storage.secureStorage);

  if (likelyHooksConflict) {
    logger.warn(
      'This is most likely the known Dart SDK + build_runner + build hooks issue.\n'
      'flutter_secure_storage uses native build hooks, which the current build_runner\n'
      'cannot AOT-compile through. The Dart team is tracking this:\n'
      '  https://github.com/dart-lang/build/issues/4343\n\n'
      'Workarounds while this is being fixed:\n'
      '  1. Run codegen against an older Dart SDK (Dart 3.9 or earlier), or\n'
      '  2. Temporarily remove flutter_secure_storage from pubspec.yaml,\n'
      '     run "dart run build_runner build --delete-conflicting-outputs",\n'
      '     then add flutter_secure_storage back.\n\n'
      'Your project is otherwise scaffolded correctly. You can keep building\n'
      'and add the generated files (.g.dart / .freezed.dart) when codegen runs.',
    );
  } else {
    logger.warn(
      'You can try running code generation manually:\n'
      '  cd ${config.projectName}\n'
      '  dart run build_runner build --delete-conflicting-outputs\n\n'
      'If that also fails, check whether any of your dependencies use Dart\n'
      'build hooks (this is a known incompatibility tracked at\n'
      'https://github.com/dart-lang/build/issues/4343).',
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

  Future<bool> _addDependencies() async {
  final progress = logger.progress('Adding dependencies (resolving latest)');

  final deps = <String>[];
  final devDeps = <String>[];

  // State management
  switch (config.stateManagement) {
   case StateManagement.riverpod:
  deps.add('flutter_riverpod');
  if (config.useCodegen) {
    deps.add('riverpod_annotation:^3.0.0');
    deps.add('freezed_annotation:^3.0.0');
    devDeps.add('build_runner');                    // unpinned — let pub pick latest
    devDeps.add('riverpod_generator:^3.0.0');
    devDeps.add('freezed:^3.0.0');
  }
  break;
    case StateManagement.bloc:
      deps.add('flutter_bloc');
      break;
    case StateManagement.provider:
      deps.add('provider');
      break;
  }

  // Networking
  if (config.extras.contains(Extra.networking)) {
    deps.add('dio');
  }

  // Storage
  if (config.extras.contains(Extra.storage)) {
    for (final option in config.storageOptions) {
      switch (option) {
        case Storage.sharedPreferences:
          deps.add('shared_preferences');
          break;
        case Storage.hive:
          deps.add('hive');
          deps.add('hive_flutter');
          break;
        case Storage.isar:
          deps.add('isar');
          deps.add('isar_flutter_libs');
          deps.add('path_provider');
          break;
        case Storage.sqflite:
          deps.add('sqflite');
          deps.add('path');
          break;
        case Storage.secureStorage:
          deps.add('flutter_secure_storage');
          break;
      }
    }
  }

  // Linting
  if (config.extras.contains(Extra.linting)) {
    devDeps.add('very_good_analysis');
  }

  // Add deps in one call - faster than one-at-a-time
  if (deps.isNotEmpty) {
    final ok = await processRunner.run(
      'flutter',
      ['pub', 'add', ...deps],
      workingDirectory: projectPath,
      silent: true,
    );
    if (!ok) {
      progress.fail('Failed to add dependencies');
      return false;
    }
  }

  // Add dev deps with the dev: prefix
  if (devDeps.isNotEmpty) {
    final devArgs = devDeps.map((d) => 'dev:$d').toList();
    final ok = await processRunner.run(
      'flutter',
      ['pub', 'add', ...devArgs],
      workingDirectory: projectPath,
      silent: true,
    );
    if (!ok) {
      progress.fail('Failed to add dev dependencies');
      return false;
    }
  }

  // Asset paths still need yaml_edit
  final editor = PubspecEditor(projectPath);
  await editor.addAssets([
    'assets/images/',
    'assets/icons/',
    'assets/animations/',
    'assets/translations/',
  ]);

  progress.complete('Dependencies added');
  return true;
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
