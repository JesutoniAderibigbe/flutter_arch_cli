# flutter_arch_cli

[![pub package](https://img.shields.io/pub/v/flutter_arch_cli.svg)](https://pub.dev/packages/flutter_arch_cli)
[![pub points](https://img.shields.io/pub/points/flutter_arch_cli)](https://pub.dev/packages/flutter_arch_cli/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Made for Flutter](https://img.shields.io/badge/Made%20for-Flutter-02569B?logo=flutter)](https://flutter.dev)

> A CLI tool to scaffold Flutter projects with your chosen architecture, state management, and the production-ready extras every real app needs.

Skip the day-one setup decisions. Pick how you want to build, and `flutter_arch` writes the boilerplate for you — folder structure, state management plumbing, networking client, storage services, theming, lint rules, an `assets/` folder ready to drop files into, and a working `main.dart` that launches on first try.

---

## Table of contents

- [Why this exists](#why-this-exists)
- [Features at a glance](#features-at-a-glance)
- [Install](#install)
- [Quick start](#quick-start)
- [What you get in detail](#what-you-get-in-detail)
  - [Architecture](#architecture)
  - [State management](#state-management)
  - [Code generation for Riverpod](#code-generation-for-riverpod)
  - [Networking](#networking)
  - [Storage](#storage)
  - [Theming](#theming)
  - [Assets](#assets)
  - [Linting](#linting)
  - [Tests](#tests)
- [Generated project structure](#generated-project-structure)
- [Example walkthrough](#example-walkthrough)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

---

## Why this exists

Every Flutter project starts with the same set of decisions. Which architecture? Which state management? How do I wire up `dio` properly? Where does the theme live? How do I configure `analysis_options.yaml` so it's strict but not annoying? Should I use `shared_preferences`, `hive`, or `flutter_secure_storage`? Probably all three, depending on what I'm storing.

You can spend the first half-day of every new project answering these questions. Or you can answer them once, encode the answers as a CLI, and never repeat yourself.

`flutter_arch_cli` is that CLI. It asks you the high-level questions in under a minute, then writes thousands of lines of correct, lint-clean, immediately-runnable boilerplate so you can skip straight to building features.

## Features at a glance

- **Two architectures** — Clean Architecture (layered) or Feature-first (flat)
- **Three state management options** — Riverpod, Bloc, or Provider
- **Optional Riverpod code generation** — `riverpod_generator` + `freezed`, with `build_runner` run for you
- **Networking** — `DioClient` with logger and auth interceptors
- **Five storage options** — pick any combination of `shared_preferences`, `hive`, `isar`, `sqflite`, `flutter_secure_storage`
- **Material 3 theming** — light and dark themes derived from a single seed color
- **Assets folder** — pre-organised subfolders for images, icons, fonts, animations, and translations, with pubspec registration handled for you
- **Lint setup** — `very_good_analysis` with sensible overrides
- **Tests folder** — mirrors your `lib/` structure
- **A working `main.dart`** — `flutter run` launches a real, interactive app the moment generation finishes

## Install

```bash
dart pub global activate flutter_arch_cli
```

Make sure `~/.pub-cache/bin` is on your `PATH`. If it isn't, add this to your shell config (`~/.zshrc`, `~/.bashrc`, or equivalent):

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Then reload your shell:

```bash
source ~/.zshrc
```

Verify the install:

```bash
flutter_arch --help
```

You should see the help text with the `create` command listed.

## Quick start

```bash
flutter_arch create my_app
```

Walk through the prompts:

```
Let's set up your Flutter project.

? Organization (e.g. com.yourcompany) (com.example) › com.yourname.myapp
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
```

Then run it:

```bash
cd my_app
flutter run
```

You'll see a sample screen with a refresh button. Tap it — three list items appear after a brief loading spinner. That's loading, success, and error state handling wired correctly out of the box.

---

## What you get in detail

### Architecture

**Clean Architecture** organises each feature into three layers:

- `data/` — datasources, models, repository implementations
- `domain/` — entities, repository interfaces, usecases
- `presentation/` — pages, widgets, state management

Plus a shared `core/` directory for cross-cutting concerns. This pattern scales well to large teams and long-lived codebases because it enforces clear boundaries between business logic and framework code.

**Feature-first** is flatter. Each feature is a self-contained directory with `models/`, `repository/`, `pages/`, `widgets/`, and a state folder. No three-layer split, no abstract repositories. The right choice for smaller apps or solo projects where the ceremony of Clean Architecture is overkill.

Both options scaffold a working `sample` feature so you can see the pattern in action and use it as a reference when adding your own.

### State management

You get a real, working sample provider/bloc for whichever option you pick, plus the right wrapper applied in `main.dart` (`ProviderScope`, `MultiBlocProvider`, or `MultiProvider`).

Each sample demonstrates the same three states — loading, success, error — so you learn the canonical pattern for that library regardless of which one you chose.

### Code generation for Riverpod

If you pick Riverpod, you'll be asked whether to enable code generation. If you say yes:

- `riverpod_generator`, `freezed`, `build_runner` are added to your `pubspec.yaml`
- Your sample state class is generated as a `@freezed` immutable class
- Your sample provider is written using the `@riverpod` annotation
- The CLI runs `dart run build_runner build --delete-conflicting-outputs` automatically after `flutter pub get`

If `build_runner` fails for any reason (most commonly a network issue while resolving generators), the CLI prints the exact command for you to run manually so you're never stuck.

If you say no to codegen, you get the classic `StateNotifierProvider` pattern with a hand-written state class — perfect for learning the underlying mental model before moving to generation.

### Networking

A `DioClient` class is generated at `lib/core/network/dio_client.dart` with:

- `BaseOptions` configured with sensible timeouts and JSON headers
- A typed wrapper around `get`, `post`, `put`, `delete`
- A `LoggerInterceptor` that prints requests and responses in debug builds only
- An `AuthInterceptor` with a `token` setter ready to wire into your storage solution, plus a hook for handling 401 responses (token refresh, sign-out, etc.)

Drop it into your DI of choice and you have a production-shaped HTTP layer from line one.

### Storage

You can pick any combination of:

- **`shared_preferences`** — simple key-value, great for user settings and feature flags
- **`hive`** — fast NoSQL, great for cached domain models
- **`isar`** — modern type-safe NoSQL with built-in querying
- **`sqflite`** — classic SQL, great when you need joins or migrations
- **`flutter_secure_storage`** — encrypted, the right home for auth tokens and secrets

Each one you pick gets a dedicated service file under `lib/core/storage/` that wraps the package with an app-friendly API. Common combinations like `shared_preferences` + `flutter_secure_storage` are first-class — your app initializes each service in `main.dart` automatically.

### Theming

Material 3 light and dark themes are generated at `lib/core/theme/app_theme.dart`, derived from a single seed color in `lib/core/theme/app_colors.dart`. Change the seed, the whole app retones.

`main.dart` wires both themes into `MaterialApp` with `themeMode: ThemeMode.system`, so your app respects the user's OS preference by default.

### Assets

Every project is scaffolded with an `assets/` folder containing:

- `images/` — for PNG, JPG, WebP
- `icons/` — for SVG and small UI icons
- `fonts/` — for custom typography
- `animations/` — for Lottie and Rive files
- `translations/` — for localization JSON

Each subfolder has a README explaining how to use it. Placeholder files are included where appropriate (a 1×1 transparent PNG, a blank SVG, a minimal Lottie JSON, a sample English translation) so `flutter run` works on first try without "asset not found" errors.

A typed `AppAssets` class is generated at `lib/core/constants/app_assets.dart` so you can reference assets via constants:

```dart
Image.asset(AppAssets.placeholderImage)
```

Instead of stringly-typed paths that break silently when you rename a file.

The relevant subfolders are pre-registered in `pubspec.yaml`. Fonts are not auto-registered because they need their own `fonts:` block — the README in `assets/fonts/` shows you the exact syntax when you add your first font.

### Linting

`very_good_analysis` is included with overrides for the rules that tend to nag more than help in app code:

- `lines_longer_than_80_chars` — disabled
- `flutter_style_todos` — disabled
- `prefer_const_constructors` — disabled (your formatter handles this)
- `avoid_redundant_argument_values` — disabled
- `sort_pub_dependencies` — disabled
- `always_use_package_imports` — disabled (relative imports inside features are idiomatic)
- `public_member_api_docs` — disabled (you're writing an app, not a library)

The result: strict where it matters, quiet where it'd just create noise.

### Tests

A `test/` folder is scaffolded that mirrors your `lib/` structure, with a placeholder test in your sample feature. Replace it with real tests as you go — the directory shape is already set up so you never have to think about where a new test file belongs.

## Generated project structure

Here's what a maximally-configured project looks like (Clean Architecture + Riverpod with codegen + all extras + `shared_preferences` and `flutter_secure_storage` storage):

```
my_app/
├── assets/
│   ├── animations/
│   │   ├── README.md
│   │   └── placeholder.json
│   ├── fonts/
│   │   └── README.md
│   ├── icons/
│   │   ├── README.md
│   │   └── placeholder.svg
│   ├── images/
│   │   ├── README.md
│   │   └── placeholder.png
│   └── translations/
│       ├── README.md
│       └── en.json
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_assets.dart
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
│   ├── core/
│   └── features/
│       └── sample/
│           └── domain/
│               └── sample_test.dart
├── analysis_options.yaml
└── pubspec.yaml
```

## Example walkthrough

Let's say you're starting a new project for a small e-commerce app. You want Clean Architecture (it's going to grow), Bloc (your team is comfortable with it), `dio` for HTTP, `flutter_secure_storage` for the auth token, and `shared_preferences` for things like onboarding flags.

```bash
flutter_arch create shop_app
```

Walk through:

```
? Organization (e.g. com.yourcompany) (com.example) › com.yourname.shop
? Pick an architecture › Clean Architecture
? Pick a state management solution › Bloc
? Pick the extras you want set up (space to toggle, enter to confirm) ›
  ◉ Networking (dio + interceptors)
  ◉ Local storage (shared_preferences + hive)
  ◉ Theming (light/dark, Material 3)
  ◉ Linting (very_good_analysis)
  ◉ Tests folder structure
? Pick the storage solution(s) you want ›
  ◉ shared_preferences (simple key-value)
  ◯ hive (NoSQL, fast)
  ◯ isar (modern type-safe DB)
  ◯ sqflite (classic SQL)
  ◉ flutter_secure_storage (encrypted, for tokens/secrets)
```

The CLI then:

1. Runs `flutter create` to scaffold the base project
2. Cleans out the default `main.dart` and widget test
3. Scaffolds the Clean Architecture layout
4. Generates the Bloc sample feature (`SampleBloc`, `SampleEvent`, `SampleState`)
5. Generates `DioClient`, `LoggerInterceptor`, `AuthInterceptor`
6. Generates `PreferencesService` and `SecureStorageService`
7. Generates `AppTheme`, `AppColors`
8. Generates the assets folder with placeholders
9. Writes `analysis_options.yaml` with `very_good_analysis`
10. Scaffolds the test folder
11. Writes `main.dart` with `MultiBlocProvider`, `MaterialApp`, theme wiring, storage init, and the sample page
12. Updates `pubspec.yaml` with all dependencies and asset paths
13. Runs `flutter pub get`

Now:

```bash
cd shop_app
flutter run
```

You're looking at a working app. Time to delete the sample feature and start building your real ones — but the entire scaffolding is done.

## FAQ

**Does `flutter_arch_cli` work on Windows?**

Yes. The CLI is pure Dart and uses cross-platform path handling. Make sure `flutter` is on your `PATH`.

**Does it modify existing projects?**

No. `flutter_arch create` only creates new projects. It refuses to run if a folder with the target name already exists. A separate `flutter_arch generate feature <name>` command for adding features to existing projects is on the roadmap.

**Can I change my mind after generation?**

Yes. The output is just code. Swap state management, change folder structure, delete the storage service you didn't end up needing — it's your project from the moment generation finishes.

**Why is `routing` not in the extras?**

Routing is the most opinionated layer of any app and the conventions shift faster than the rest. Forcing `go_router` (or any specific choice) felt like it'd age poorly. It's high on the roadmap as an optional extra.

**Why doesn't the generated `analysis_options.yaml` use the most aggressive `very_good_analysis` rules?**

Because new projects shouldn't open with 20 lint warnings on day one. The overrides drop the rules that are bikeshed-y in app code and keep the ones that catch real issues. You can re-enable any of them in your own `analysis_options.yaml` whenever you're ready.

**Will you add my favourite state management option / architecture / package?**

Open an issue and let's discuss. The bar is "would a meaningful share of the Flutter community pick this over what's already supported." If yes, it's a candidate.

## Roadmap

- Routing (`go_router`) scaffold as an optional extra
- Custom feature generator: `flutter_arch generate feature <name>`
- Optional Firebase setup (Core, Auth, Firestore, Crashlytics)
- Template export so teams can fork their own house style
- `bloc_test` and `mocktail` setup when Bloc is chosen
- `json_serializable` as an opt-in alongside `freezed`
- VS Code snippet pack matching the generated patterns

## Contributing

PRs are welcome. The repository lives at [github.com/JesutoniAderibigbe/flutter_arch_cli](https://github.com/JesutoniAderibigbe/flutter_arch_cli).

If you find a bug:

1. Open an issue with the command you ran, the choices you made, and the unexpected behaviour
2. If you have a fix, send a PR referencing the issue

If you want to add a feature:

1. Open an issue first to discuss the design — saves rework
2. Follow the existing patterns: abstract generator interface + concrete implementations
3. Update the README, CHANGELOG, and example walkthrough

## Author

Built by [Jesutoni Aderibigbe](https://github.com/JesutoniAderibigbe) — a Flutter engineer based in Ibadan, Nigeria, who got tired of writing the same boilerplate at the start of every project.

- GitHub: [@JesutoniAderibigbe](https://github.com/JesutoniAderibigbe)
- LinkedIn: [jesutoni-aderibigbe](https://linkedin.com/in/jesutoni-aderibigbe)
- Medium: [@aderibigbejesutoni860](https://medium.com/@aderibigbejesutoni860)
- dev.to: [@toniaderibigbe](https://dev.to/toniaderibigbe)

## License

MIT — see [LICENSE](LICENSE) for details.
