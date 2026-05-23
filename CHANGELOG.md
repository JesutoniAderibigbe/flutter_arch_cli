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