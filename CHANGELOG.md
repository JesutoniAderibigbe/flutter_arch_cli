## 0.4.2

- Better diagnostics for the known Dart SDK + `build_runner` + build hooks incompatibility ([dart-lang/build#4343](https://github.com/dart-lang/build/issues/4343)). When the user picks Riverpod codegen alongside `flutter_secure_storage`, the CLI now prints a pre-flight warning before scaffolding and a detailed, actionable message if `build_runner` fails — instead of a generic "try running it manually" message that would fail with the same error.
- The post-failure message now identifies the specific cause (build hooks) and gives two concrete workarounds: run codegen against an older Dart SDK, or temporarily remove `flutter_secure_storage` from `pubspec.yaml`, run `build_runner`, then re-add it.
- This is an upstream Dart SDK issue that the Dart team is actively fixing; projects scaffolded with this CLI are otherwise unaffected. Only the auto-run of `build_runner` is impacted, and only when the specific combination is chosen.

## 0.4.1

- Dependencies are now resolved to the latest compatible versions at scaffold time using `flutter pub add` instead of being pinned in the CLI, so generated projects automatically get current packages without needing version-bump releases
- Migrated the Riverpod codegen stack to 3.x (`flutter_riverpod` resolves to latest 3.x, `riverpod_annotation: ^3.0.0`, `riverpod_generator: ^3.0.0`) — the class-based codegen pattern is unchanged between 2.x and 3.x, so existing templates compile cleanly against the new versions
- Migrated the freezed templates to 3.x syntax (`abstract class SampleState with _$SampleState` — the `abstract` modifier is required in freezed 3.x for simple data classes); pinned `freezed: ^3.0.0` and `freezed_annotation: ^3.0.0`
- Migrated the manual Riverpod template from `StateNotifier` (now legacy in Riverpod 3.x, requires `package:flutter_riverpod/legacy.dart`) to `Notifier` + `NotifierProvider`, the recommended API for new code
- Agent context files (CLAUDE.md, AGENTS.md) updated to describe Riverpod 3.x behaviors: auto-retry by default, `==`-based equality checks, `ProviderException` wrapping, and `Ref.mounted`
- Cleaned up lint warnings in generated code so `flutter analyze` is clean on first run:
  - `auth_interceptor.dart` now exposes both a getter and setter for `token`
  - `preferences_service.setBool` uses a named `value` parameter
  - All state management templates use `on Exception catch (e)` instead of bare `catch (e)`
  - Removed unnecessary `foundation.dart` import from generated `main.dart`
  - Cleaned up `app_assets.dart` to remove a dead private field

Thanks to community feedback for flagging the outdated `StateNotifier` template and stale dependency versions.

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