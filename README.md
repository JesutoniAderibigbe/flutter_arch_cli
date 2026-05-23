# flutter_arch_cli

A CLI tool to scaffold Flutter projects with your chosen architecture, state management, and the production-ready extras every real app needs.

Skip the day-one setup decisions. Pick how you want to build, and `flutter_arch` writes the boilerplate for you — folder structure, state management plumbing, networking client, storage services, theming, lint rules, and a working `main.dart` that launches on first try.

## Install

```bash
dart pub global activate flutter_arch_cli
```

Make sure `~/.pub-cache/bin` is on your `PATH`. If it isn't, add this to your shell config:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## Usage

```bash
flutter_arch create my_app
```

You'll be prompted for:

- **Organization** (e.g. `com.yourcompany`)
- **Architecture** — Clean Architecture or Feature-first
- **State management** — Riverpod, Bloc, or Provider
- **Extras** — Networking, Local storage, Theming, Linting, Tests
- **Storage** — any combination of shared_preferences, hive, isar, sqflite, flutter_secure_storage

Then `cd` in and run:

```bash
cd my_app
flutter run
```

The generated app launches with a sample screen wired to your chosen state management, demonstrating loading/error/success patterns you can build on.

## What you get

### Architecture

**Clean Architecture** scaffolds three layers per feature — `data`, `domain`, `presentation` — plus a shared `core/` for cross-cutting concerns (errors, network, storage, theme).

**Feature-first** is flatter. Each feature is self-contained with its own `models/`, `repository/`, `pages/`, and state folder. Better for small to medium apps.

### State management

Each option ships with a working sample provider/bloc plus the right wrapper in `main.dart` (`ProviderScope`, `MultiBlocProvider`, or `MultiProvider`).

### Networking

A `DioClient` with `BaseOptions`, a logger interceptor, and a token-aware auth interceptor ready to hook into your storage.

### Storage

Each storage option you tick gets a dedicated service file in `core/storage/` that wraps the package with an app-friendly API. Mix and match — common combos like `shared_preferences` for settings plus `flutter_secure_storage` for tokens are first-class.

### Theming

Material 3 light and dark themes derived from a single seed color in `AppColors`. Change the seed, the whole app retones.

### Linting

`very_good_analysis` included with sensible overrides — strict where it matters, quiet where it'd just nag you.

## Roadmap

- Routing (`go_router`) scaffold
- Custom feature generator: `flutter_arch generate feature <name>`
- Optional Firebase setup
- Template export so teams can fork their own house style

## Author

Built by [Jesutoni Aderibigbe](https://github.com/JesutoniAderibigbe).

## License

MIT