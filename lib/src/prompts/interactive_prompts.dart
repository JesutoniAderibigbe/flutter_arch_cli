import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';

import '../models/project_config.dart';

class InteractivePrompts {
  InteractivePrompts({required this.logger});

  final Logger logger;

  ProjectConfig run({required String projectName}) {
  logger.info('');
  logger.info('Let\'s set up your Flutter project.');
  logger.info('');

  final organization = _askOrganization();
  final architecture = _askArchitecture();
  final stateManagement = _askStateManagement();

  bool useCodegen = false;
  if (stateManagement == StateManagement.riverpod) {
    useCodegen = _askUseCodegen();
  }

  final extras = _askExtras();

  Set<Storage> storageOptions = const {};
  if (extras.contains(Extra.storage)) {
    storageOptions = _askStorageOptions();
  }

  return ProjectConfig(
    projectName: projectName,
    organization: organization,
    architecture: architecture,
    stateManagement: stateManagement,
    extras: extras,
    storageOptions: storageOptions,
    useCodegen: useCodegen,
  );
}

bool _askUseCodegen() {
  return Confirm(
    prompt: 'Use code generation (riverpod_generator + freezed)? Recommended for new projects.',
    defaultValue: true,
  ).interact();
}

  String _askOrganization() {
    return Input(
      prompt: 'Organization (e.g. com.yourcompany)',
      defaultValue: 'com.example',
      validator: (value) {
        if (value.trim().isEmpty) {
          throw ValidationError('Organization cannot be empty.');
        }
        final pattern = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
        if (!pattern.hasMatch(value.trim())) {
          throw ValidationError(
            'Use reverse-domain format like com.dojoconnect.app',
          );
        }
        return true;
      },
    ).interact();
  }


  Set<Storage> _askStorageOptions() {
  const optionLabels = [
    'shared_preferences (simple key-value)',
    'hive (NoSQL, fast)',
    'isar (modern type-safe DB)',
    'sqflite (classic SQL)',
    'flutter_secure_storage (encrypted, for tokens/secrets)',
  ];

  final selectedIndices = MultiSelect(
    prompt: 'Pick the storage solution(s) you want (space to toggle, enter to confirm)',
    options: optionLabels,
    defaults: [true, false, false, false, false],
  ).interact();

  final options = <Storage>{};
  for (final index in selectedIndices) {
    options.add(switch (index) {
      0 => Storage.sharedPreferences,
      1 => Storage.hive,
      2 => Storage.isar,
      3 => Storage.sqflite,
      4 => Storage.secureStorage,
      _ => throw StateError('Unknown storage index: $index'),
    });
  }
  return options;
}

  Architecture _askArchitecture() {
    const options = ['Clean Architecture', 'Feature-first'];
    final selection = Select(
      prompt: 'Pick an architecture',
      options: options,
    ).interact();

    return switch (selection) {
      0 => Architecture.cleanArchitecture,
      1 => Architecture.featureFirst,
      _ => Architecture.cleanArchitecture,
    };
  }

  StateManagement _askStateManagement() {
    const options = ['Riverpod', 'Bloc', 'Provider'];
    final selection = Select(
      prompt: 'Pick a state management solution',
      options: options,
    ).interact();

    return switch (selection) {
      0 => StateManagement.riverpod,
      1 => StateManagement.bloc,
      2 => StateManagement.provider,
      _ => StateManagement.riverpod,
    };
  }

  Set<Extra> _askExtras() {
  const optionLabels = [
    'Networking (dio + interceptors)',
    'Local storage (shared_preferences + hive + more)',
    'Theming (light/dark, Material 3)',
    'Linting (very_good_analysis)',
    'Tests folder structure',
    'AI agent context (CLAUDE.md, AGENTS.md, .cursorrules)',
  ];

  final selectedIndices = MultiSelect(
    prompt: 'Pick the extras you want set up (space to toggle, enter to confirm)',
    options: optionLabels,
    defaults: [true, true, true, true, true, true],
  ).interact();

  final extras = <Extra>{};
  for (final index in selectedIndices) {
    extras.add(switch (index) {
      0 => Extra.networking,
      1 => Extra.storage,
      2 => Extra.theming,
      3 => Extra.linting,
      4 => Extra.tests,
      5 => Extra.agentContext,
      _ => throw StateError('Unknown extra index: $index'),
    });
  }
  return extras;
}
}