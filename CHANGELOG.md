## 0.4.0

- Added optional "AI agent context" extra that generates `CLAUDE.md`, `AGENTS.md`, and `.cursorrules` files
- Content adapts to architecture, state management, codegen, networking, and storage choices
- Files travel with the repo so every contributor's AI agent (Claude Code, Cursor, Windsurf, Copilot, etc.) gets the right project conventions

## 0.3.0

- Always scaffolds an `assets/` folder with subfolders for images, icons, fonts, animations, and translations
- Drops in tiny placeholder files so `flutter run` works on first try with no missing-asset errors
- Auto-registers asset paths in `pubspec.yaml` (except fonts, which need their own block)
- Generates `lib/core/constants/app_assets.dart` with typed paths so widgets reference assets by constant, not string

## 0.2.0

- Added optional code generation for Riverpod (riverpod_generator + freezed)
- Auto-runs `dart run build_runner build` after scaffolding when codegen is enabled
- Falls back to printing the manual command if build_runner fails

## 0.1.0

Initial release.

- `create` command with interactive prompts
- Clean Architecture and Feature-first scaffolding
- Riverpod, Bloc, Provider state management generators
- Networking with dio + interceptors
- Local storage: shared_preferences, hive, isar, sqflite, flutter_secure_storage
- Material 3 light/dark theming
- very_good_analysis lint setup
- Test folder scaffolding mirroring lib structure
- Working main.dart with a sample screen for each state management option