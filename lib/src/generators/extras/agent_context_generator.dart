import '../../models/project_config.dart';
import 'extras_generator.dart';

class AgentContextGenerator extends ExtrasGenerator {
  AgentContextGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    final content = _buildMarkdownContent();
    final rulesContent = _buildCursorRulesContent();

    await fileWriter.writeFile('CLAUDE.md', content);
    await fileWriter.writeFile('AGENTS.md', content);
    await fileWriter.writeFile('.cursorrules', rulesContent);
  }

  String _buildMarkdownContent() {
    return '''
# Project context for AI coding agents

This file provides context about the codebase for AI coding assistants (Claude Code, Cursor, Windsurf, Copilot, and others). Read this before making changes so you produce code that matches the project's conventions.

## Project summary

- **Name:** ${config.projectName}
- **Organization:** ${config.organization}
- **Architecture:** ${_architectureLabel()}
- **State management:** ${_stateManagementLabel()}${_codegenSuffix()}
- **Storage:** ${_storageLabel()}
- **Networking:** ${config.extras.contains(Extra.networking) ? 'dio with logger and auth interceptors' : 'not configured'}
- **Theming:** ${config.extras.contains(Extra.theming) ? 'Material 3, light and dark themes from a seed color' : 'not configured'}
- **Linting:** ${config.extras.contains(Extra.linting) ? 'very_good_analysis with project overrides' : 'default Flutter lints'}

Scaffolded with [`flutter_arch_cli`](https://pub.dev/packages/flutter_arch_cli).

## Architecture conventions

${_architectureSection()}

## State management conventions

${_stateManagementSection()}

## Adding a new feature

${_newFeatureSection()}

## Networking

${_networkingSection()}

## Storage

${_storageSection()}

## Theming

${_themingSection()}

## Assets

Asset paths are centralized in `lib/core/constants/app_assets.dart`. **Never hardcode an asset path** in a widget — always reference it via an `AppAssets` constant. When you add a new asset:

1. Drop the file into the appropriate `assets/` subfolder
2. Add a typed constant in `AppAssets`
3. Use the constant in your widget

Asset subfolders:
- `assets/images/` — PNG, JPG, WebP (auto-registered in pubspec)
- `assets/icons/` — SVG and small UI icons (auto-registered)
- `assets/animations/` — Lottie and Rive files (auto-registered)
- `assets/translations/` — localization JSON (auto-registered)
- `assets/fonts/` — TTF and OTF font files (require manual pubspec `fonts:` registration)

## Running and building

```bash
flutter pub get          # install dependencies
flutter run              # run the app
flutter test             # run tests
flutter analyze          # check lint and analyzer issues${_codegenCommands()}
```

## Hard rules

These are non-negotiable for keeping the codebase consistent. Do not violate them without an explicit instruction from the user.

- **Do not bypass the architecture.** ${_architectureRule()}
- **Do not hardcode asset paths.** Use `AppAssets` constants.
- **Do not introduce a new state management library.** This project uses ${_stateManagementLabel()}; if you genuinely need a different approach for one feature, discuss it with the user first.
- **Do not commit `.g.dart`, `.freezed.dart`, or other generated files.** They are gitignored. Run codegen instead.
- **Do not weaken lint rules** in `analysis_options.yaml` to make warnings disappear. Fix the underlying issue.
- **Do not reach across feature boundaries.** One feature should not import from another feature's internal folders. If two features need to share code, put it in `lib/core/` or extract a shared feature.

## Common tasks

### Add a model

${_addModelGuidance()}

### Add a repository

${_addRepositoryGuidance()}

### Add a screen

${_addScreenGuidance()}

## Project structure (top level)
${config.projectName}/
├── assets/                  # images, icons, fonts, animations, translations
├── lib/
│   ├── core/                # shared infrastructure
│   │   ${config.extras.contains(Extra.networking) ? '├── network/             # dio client and interceptors' : ''}
│   │   ${config.storageOptions.isNotEmpty ? '├── storage/             # storage service wrappers' : ''}
│   │   ${config.extras.contains(Extra.theming) ? '├── theme/               # AppTheme, AppColors' : ''}
│   │   ├── constants/           # AppAssets and other constants
│   │   └── errors/              # exceptions and failures
│   ├── features/            # feature modules
│   │   └── sample/              # delete this once you have real features
│   └── main.dart
├── test/                    # tests mirroring lib/
├── analysis_options.yaml
└── pubspec.yaml
''';
  }

  String _architectureLabel() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => 'Clean Architecture (data / domain / presentation layers per feature)',
      Architecture.featureFirst => 'Feature-first (flat structure per feature)',
    };
  }

  String _stateManagementLabel() {
    return switch (config.stateManagement) {
      StateManagement.riverpod => 'Riverpod',
      StateManagement.bloc => 'Bloc',
      StateManagement.provider => 'Provider',
    };
  }

  String _codegenSuffix() {
    if (config.stateManagement == StateManagement.riverpod && config.useCodegen) {
      return ' with code generation (riverpod_generator + freezed)';
    }
    return '';
  }

  String _storageLabel() {
    if (config.storageOptions.isEmpty) return 'not configured';
    return config.storageOptions.map((s) {
      return switch (s) {
        Storage.sharedPreferences => 'shared_preferences',
        Storage.hive => 'hive',
        Storage.isar => 'isar',
        Storage.sqflite => 'sqflite',
        Storage.secureStorage => 'flutter_secure_storage',
      };
    }).join(', ');
  }

  String _architectureSection() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => '''
This project uses **Clean Architecture**. Each feature is split into three layers:

- **`data/`** — datasources (remote/local), models (with `fromJson`/`toJson`), and repository implementations. This layer depends on the domain layer.
- **`domain/`** — entities (pure Dart, no Flutter imports), abstract repository contracts, and usecases. This layer has no dependencies on data or presentation.
- **`presentation/`** — pages, widgets, and state management. Depends on domain (and through it, indirectly, data via DI).

The flow of dependencies is always **presentation → domain ← data**. Domain is the stable core. Never import from `data/` in `presentation/`; go through the abstract repository in `domain/`.

Shared infrastructure (network client, storage, theme, errors) lives in `lib/core/`.
''',
      Architecture.featureFirst => '''
This project uses **Feature-first** architecture. Each feature is a self-contained directory:
lib/features/<feature>/
├── models/         # data classes with fromJson/toJson
├── repository/     # concrete repository (no abstract layer)
├── pages/          # screen-level widgets
├── widgets/        # feature-specific widgets
└── <state_folder>/ # state management

There is no three-layer split. Repositories are concrete, not abstract. This is intentional — it's the right pattern for small to medium apps where Clean Architecture's ceremony would slow you down.

Shared infrastructure (network client, storage, theme, errors) lives in `lib/core/`.
''',
    };
  }

  String _stateManagementSection() {
    return switch (config.stateManagement) {
      StateManagement.riverpod => config.useCodegen
          ? '''
This project uses **Riverpod with code generation** (`riverpod_generator` + `freezed`).

State classes are immutable, generated with `@freezed`:

```dart
@freezed
class SampleState with _\$SampleState {
  const factory SampleState({
    @Default(false) bool isLoading,
    @Default(<String>[]) List<String> items,
    String? error,
  }) = _SampleState;
}
```

Notifiers use the `@riverpod` annotation. The class name (e.g. `Sample`) becomes the provider name (`sampleProvider`):

```dart
@riverpod
class Sample extends _\$Sample {
  @override
  SampleState build() => const SampleState();

  Future<void> loadSamples() async { ... }
}
```

After changing any annotated file, run codegen: `dart run build_runner build --delete-conflicting-outputs`.

Consume providers in widgets via `ConsumerWidget` or `Consumer`:

```dart
class SamplePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sampleProvider);
    return ...;
  }
}
```

To trigger actions: `ref.read(sampleProvider.notifier).loadSamples()`.
'''
          : '''
This project uses **Riverpod** with manual providers (no code generation).

State classes are immutable, written by hand with a `copyWith` method. `StateNotifier` is the notifier base class:

```dart
class SampleNotifier extends StateNotifier<SampleState> {
  SampleNotifier() : super(const SampleState());
  Future<void> loadSamples() async { ... }
}

final sampleProvider = StateNotifierProvider<SampleNotifier, SampleState>(
  (ref) => SampleNotifier(),
);
```

Consume providers in widgets via `ConsumerWidget` or `Consumer`:

```dart
final state = ref.watch(sampleProvider);
ref.read(sampleProvider.notifier).loadSamples();
```
''',
      StateManagement.bloc => '''
This project uses **Bloc** (`flutter_bloc`).

Each feature's state management lives in a `bloc/` folder with three files:
- `<feature>_event.dart` — events as sealed classes
- `<feature>_state.dart` — states as sealed classes
- `<feature>_bloc.dart` — the bloc itself, mapping events to states

Pattern:

```dart
class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc() : super(const SampleInitial()) {
    on<SamplesRequested>(_onSamplesRequested);
  }
  Future<void> _onSamplesRequested(...) async { ... }
}
```

Consume in widgets via `BlocBuilder`, `BlocListener`, or `BlocConsumer`:

```dart
BlocBuilder<SampleBloc, SampleState>(
  builder: (context, state) {
    if (state is SampleLoading) return ...;
    if (state is SampleLoaded) return ...;
    return const SizedBox();
  },
)
```

To dispatch events: `context.read<SampleBloc>().add(const SamplesRequested())`.

Blocs are provided to the widget tree via `MultiBlocProvider` in `main.dart` (or feature-scoped via `BlocProvider`).
''',
      StateManagement.provider => '''
This project uses **Provider** with `ChangeNotifier`.

Each feature's state lives in a `providers/` folder. Pattern:

```dart
class SampleProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<String> _items = const [];
  String? _error;

  bool get isLoading => _isLoading;
  List<String> get items => _items;
  String? get error => _error;

  Future<void> loadSamples() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    // ...
    _isLoading = false;
    notifyListeners();
  }
}
```

Consume in widgets:

```dart
final provider = context.watch<SampleProvider>();
context.read<SampleProvider>().loadSamples();
```

Providers are wired up via `MultiProvider` in `main.dart`.
''',
    };
  }

  String _newFeatureSection() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => '''
To add a feature called `orders`:

1. Create the folder structure:
lib/features/orders/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
├── pages/
├── widgets/
└── ${_stateFolderName()}/
2. Define the entity in `domain/entities/order.dart` (pure Dart, no Flutter imports)
3. Define the abstract repository in `domain/repositories/order_repository.dart`
4. Define usecases in `domain/usecases/` (one class per usecase)
5. Implement the data layer (model extending the entity, datasource, repository implementation)
6. Build the ${_stateManagementLabel()} state management in `presentation/${_stateFolderName()}/`
7. Build the page and any feature-specific widgets in `presentation/pages/` and `presentation/widgets/`
8. Mirror the structure in `test/features/orders/`
''',
      Architecture.featureFirst => '''
To add a feature called `orders`:

1. Create the folder structure:
lib/features/orders/
├── models/
├── repository/
├── pages/
├── widgets/
└── ${_stateFolderName()}/
2. Define the data class in `models/order.dart`
3. Define the concrete repository in `repository/order_repository.dart`
4. Build the ${_stateManagementLabel()} state management in `${_stateFolderName()}/`
5. Build the page and any feature-specific widgets in `pages/` and `widgets/`
6. Mirror the structure in `test/features/orders/`
''',
    };
  }

  String _stateFolderName() {
    return switch (config.stateManagement) {
      StateManagement.riverpod => 'providers',
      StateManagement.bloc => 'bloc',
      StateManagement.provider => 'providers',
    };
  }

  String _networkingSection() {
    if (!config.extras.contains(Extra.networking)) {
      return 'Not configured for this project. If you add HTTP, prefer `dio` and follow the interceptor pattern.';
    }
    return '''
HTTP is handled by `DioClient` at `lib/core/network/dio_client.dart`. Use it everywhere — do not instantiate `Dio` directly in features.

Two interceptors are configured:
- **`LoggerInterceptor`** — prints requests/responses in debug builds only
- **`AuthInterceptor`** — attaches a Bearer token to outgoing requests; hook for handling 401 responses (token refresh, sign-out)

To set the auth token: `authInterceptor.token = 'your_token'`. Wire this up wherever you handle login/session.

When adding a new endpoint, write a typed method in your feature's repository that calls `DioClient`'s `get`/`post`/`put`/`delete` methods. Do not put HTTP calls directly in providers/blocs.
''';
  }

  String _storageSection() {
    if (config.storageOptions.isEmpty) {
      return 'No storage is configured for this project.';
    }
    final buf = StringBuffer();
    buf.writeln('Storage services live in `lib/core/storage/`. Use these wrappers — do not call the underlying packages directly from features.');
    buf.writeln();
    for (final s in config.storageOptions) {
      switch (s) {
        case Storage.sharedPreferences:
          buf.writeln('- **`PreferencesService`** (`shared_preferences`) — simple key-value, good for user settings and feature flags. Get an instance via `PreferencesService.init()`.');
          break;
        case Storage.hive:
          buf.writeln('- **`HiveService`** (`hive`) — fast NoSQL boxes, good for cached domain models. Access via `HiveService.instance`.');
          break;
        case Storage.isar:
          buf.writeln('- **`IsarService`** (`isar`) — modern type-safe DB with built-in querying. Initialize with schemas via `IsarService.instance.init(schemas: [...])`.');
          break;
        case Storage.sqflite:
          buf.writeln('- **`DatabaseService`** (`sqflite`) — classic SQL. Add table creation in the `onCreate` callback.');
          break;
        case Storage.secureStorage:
          buf.writeln('- **`SecureStorageService`** (`flutter_secure_storage`) — encrypted, the right home for auth tokens and other secrets. Access via `SecureStorageService.instance`.');
          break;
      }
    }
    return buf.toString();
  }

  String _themingSection() {
    if (!config.extras.contains(Extra.theming)) {
      return 'Theming is not configured for this project.';
    }
    return '''
Themes live in `lib/core/theme/`. The seed color in `AppColors.primary` drives the entire palette via `ColorScheme.fromSeed`. To rebrand, change the seed.

Light and dark themes are both wired into `MaterialApp` in `main.dart` with `themeMode: ThemeMode.system`, so the app respects the user's OS preference automatically.

Use `Theme.of(context).colorScheme` in widgets — never hardcode colors.
''';
  }

  String _codegenCommands() {
    if (config.stateManagement == StateManagement.riverpod && config.useCodegen) {
      return '\ndart run build_runner build --delete-conflicting-outputs   # run codegen\ndart run build_runner watch --delete-conflicting-outputs   # watch mode';
    }
    return '';
  }

  String _architectureRule() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => 'Do not import from `data/` in `presentation/`. Cross the boundary via the abstract repository in `domain/`.',
      Architecture.featureFirst => 'Do not import from one feature into another. Shared code goes in `lib/core/` or a separate shared feature.',
    };
  }

  String _addModelGuidance() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => '''
Models live in `lib/features/<feature>/data/models/`. Each model **extends** the domain entity and adds `fromJson` / `toJson`:

```dart
class OrderModel extends Order {
  const OrderModel({required super.id, required super.total});
  factory OrderModel.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```
''',
      Architecture.featureFirst => '''
Models live in `lib/features/<feature>/models/`. Plain data classes with `fromJson` / `toJson`:

```dart
class Order {
  const Order({required this.id, required this.total});
  final String id;
  final double total;
  factory Order.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```
''',
    };
  }

  String _addRepositoryGuidance() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture => '''
Repositories have two parts:
1. **Abstract contract** in `domain/repositories/<feature>_repository.dart` — only method signatures, returning domain entities
2. **Concrete implementation** in `data/repositories/<feature>_repository_impl.dart` — uses datasources, returns concrete `Model` instances which are also entities

The presentation layer depends only on the abstract contract.
''',
      Architecture.featureFirst => '''
Repositories are concrete, in `lib/features/<feature>/repository/<feature>_repository.dart`. No abstract layer — write the methods directly, using `DioClient` and your storage services as needed.
''',
    };
  }

  String _addScreenGuidance() {
    final stateFolder = _stateFolderName();
    return switch (config.architecture) {
      Architecture.cleanArchitecture => '''
Screens go in `lib/features/<feature>/presentation/pages/`. They consume state management from `lib/features/<feature>/presentation/$stateFolder/` and should contain layout logic only — no HTTP, no DB calls. If you need data, go through the state management.
''',
      Architecture.featureFirst => '''
Screens go in `lib/features/<feature>/pages/`. They consume state management from `lib/features/<feature>/$stateFolder/` and should contain layout logic only — no HTTP, no DB calls. If you need data, go through the state management.
''',
    };
  }

  String _buildCursorRulesContent() {
    return '''
You are working on a Flutter project scaffolded with flutter_arch_cli.

Project: ${config.projectName}
Architecture: ${_architectureLabel()}
State management: ${_stateManagementLabel()}${_codegenSuffix()}

When making changes:
- Follow the established folder structure. Do not introduce new top-level directories without discussion.
- Use the existing state management library. Do not introduce alternatives.
- Reference assets via `AppAssets` constants in `lib/core/constants/app_assets.dart`.
- Use `DioClient` for HTTP, not raw `Dio` instances.
- Use the storage service wrappers in `lib/core/storage/`, not the underlying packages directly.
- Use `Theme.of(context).colorScheme` for colors, never hardcoded values.
- Do not weaken lints in `analysis_options.yaml` to suppress warnings; fix the underlying issue.
- Do not commit generated files (`.g.dart`, `.freezed.dart`).
${config.stateManagement == StateManagement.riverpod && config.useCodegen ? '- After editing annotated files, run: dart run build_runner build --delete-conflicting-outputs' : ''}

See CLAUDE.md / AGENTS.md for full conventions including how to add new features, models, repositories, and screens.
''';
  }
}