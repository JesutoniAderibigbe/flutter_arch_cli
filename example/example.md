# Example usage

## Install the CLI

```bash
dart pub global activate flutter_arch_cli
```

## Create a project

```bash
flutter_arch create my_app
```

You'll be prompted interactively:

Let's set up your Flutter project.
? Organization (e.g. com.yourcompany) (com.example) › com.toni.myapp
? Pick an architecture › Clean Architecture
? Pick a state management solution › Riverpod
? Use code generation (riverpod_generator + freezed)? Recommended for new projects. (Y/n) › yes
? Pick the extras you want set up (space to toggle, enter to confirm) ›
◉ Networking (dio + interceptors)
◉ Local storage (shared_preferences + hive)
◉ Theming (light/dark, Material 3)
◉ Linting (very_good_analysis)
◉ Tests folder structure
? Pick the storage solution(s) you want › shared_preferences, flutter_secure_storage

The CLI then:

1. Runs `flutter create` under the hood
2. Scaffolds the architecture you picked
3. Wires up your chosen state management with a working sample feature
4. Generates `DioClient`, storage services, theme files, and lint config
5. Updates `pubspec.yaml` with all the right packages
6. Runs `flutter pub get`
7. Runs `dart run build_runner build` if you picked codegen

## Run the generated app

```bash
cd my_app
flutter run
```

You'll see a sample screen with a refresh button that demonstrates loading, success, and error states using your chosen state management — ready to delete and replace with your own features.

## Generated structure (Clean Architecture + Riverpod with codegen)
my_app/
├── lib/
│   ├── core/
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart
│   │   │       └── logger_interceptor.dart
│   │   ├── storage/
│   │   │   ├── preferences_service.dart
│   │   │   └── secure_storage_service.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       └── app_theme.dart
│   ├── features/
│   │   └── sample/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   ├── models/
│   │       │   │   └── sample_model.dart
│   │       │   └── repositories/
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── sample_entity.dart
│   │       │   ├── repositories/
│   │       │   │   └── sample_repository.dart
│   │       │   └── usecases/
│   │       └── presentation/
│   │           ├── pages/
│   │           │   └── sample_page.dart
│   │           ├── providers/
│   │           │   ├── sample_provider.dart
│   │           │   ├── sample_provider.g.dart
│   │           │   ├── sample_state.dart
│   │           │   └── sample_state.freezed.dart
│   │           └── widgets/
│   └── main.dart
├── test/
└── analysis_options.yaml

