enum Architecture { cleanArchitecture, featureFirst }

enum StateManagement { riverpod, bloc, provider }

enum Extra { networking, storage, theming, linting, tests, agentContext }

enum Storage { sharedPreferences, hive, isar, sqflite, secureStorage }

class ProjectConfig {
  ProjectConfig({
    required this.projectName,
    required this.organization,
    required this.architecture,
    required this.stateManagement,
    required this.extras,
     required this.storageOptions,
     this.useCodegen = false,
  });

  final String projectName;
  final String organization;
  final Architecture architecture;
  final StateManagement stateManagement;
  final Set<Extra> extras;
  final Set<Storage> storageOptions;
  final bool useCodegen;

  @override
  String toString() {
    return '''
ProjectConfig(
  projectName: $projectName,
  organization: $organization,
  architecture: $architecture,
  stateManagement: $stateManagement,
  extras: $extras,
  storageOptions: $storageOptions,
  useCodegen: $useCodegen,
)''';

  }
}