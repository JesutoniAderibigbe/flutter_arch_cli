import 'dart:convert';

import 'extras_generator.dart';

class AssetsGenerator extends ExtrasGenerator {
  AssetsGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await _createImagesFolder();
    await _createIconsFolder();
    await _createFontsFolder();
    await _createAnimationsFolder();
    await _createTranslationsFolder();
    await _generateAssetConstants();
  }

  Future<void> _createImagesFolder() async {
    await fileWriter.writeFile(
      'assets/images/README.md',
      '''
# Images

Drop your raster images here (PNG, JPG, WebP).

To use one in code:

```dart
Image.asset('assets/images/your_image.png');
```

Reference it via `AppAssets.images.yourImage` once you've added it to `lib/core/constants/app_assets.dart`.
''',
    );

    await fileWriter.writeBinaryFile(
      'assets/images/placeholder.png',
      _transparentPngBytes(),
    );
  }

  Future<void> _createIconsFolder() async {
    await fileWriter.writeFile(
      'assets/icons/README.md',
      '''
# Icons

Drop your custom icons here. Prefer SVG for scalable assets.

For SVGs, add `flutter_svg` to your pubspec and use:

```dart
SvgPicture.asset('assets/icons/your_icon.svg');
```
''',
    );

    await fileWriter.writeFile(
      'assets/icons/placeholder.svg',
      '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <rect width="24" height="24" fill="none"/>
</svg>
''',
    );
  }

  Future<void> _createFontsFolder() async {
    await fileWriter.writeFile(
      'assets/fonts/README.md',
      '''
# Fonts

Drop your `.ttf` or `.otf` font files here, then register them in `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: YourFont
      fonts:
        - asset: assets/fonts/YourFont-Regular.ttf
        - asset: assets/fonts/YourFont-Bold.ttf
          weight: 700
```

Then use it: `TextStyle(fontFamily: 'YourFont')`.
''',
    );
  }

  Future<void> _createAnimationsFolder() async {
    await fileWriter.writeFile(
      'assets/animations/README.md',
      '''
# Animations

Drop your Lottie (`.json`) or Rive (`.riv`) files here.

For Lottie, add `lottie` to your pubspec and use:

```dart
Lottie.asset('assets/animations/your_animation.json');
```
''',
    );

    await fileWriter.writeFile(
      'assets/animations/placeholder.json',
      _emptyLottieJson(),
    );
  }

  Future<void> _createTranslationsFolder() async {
    await fileWriter.writeFile(
      'assets/translations/README.md',
      '''
# Translations

Drop your localization JSON files here, one per locale (e.g. `en.json`, `fr.json`, `yo.json`).

Recommended packages:
- [easy_localization](https://pub.dev/packages/easy_localization)
- Flutter's built-in [gen_l10n](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
''',
    );

    await fileWriter.writeFile(
      'assets/translations/en.json',
      const JsonEncoder.withIndent('  ').convert({
        'app': {
          'title': '${config.projectName}',
          'welcome': 'Welcome',
        },
      }),
    );
  }

  Future<void> _generateAssetConstants() async {
    await fileWriter.writeFile(
      'lib/core/constants/app_assets.dart',
      '''
/// Centralized asset paths so you never hardcode strings in widgets.
///
/// Add new assets here as you add them to the assets/ folder.
class AppAssets {
  AppAssets._();

  static const _imagesPath = 'assets/images';
  static const _iconsPath = 'assets/icons';
  static const _animationsPath = 'assets/animations';
  static const _translationsPath = 'assets/translations';

   // ignore: unused_field, reason: kept for symmetry with other paths; will be used when fonts are referenced from code
  static const _fontsPath = 'assets/fonts';

  // Images
  static const String placeholderImage = '\$_imagesPath/placeholder.png';

  // Icons
  static const String placeholderIcon = '\$_iconsPath/placeholder.svg';

  // Animations
  static const String placeholderAnimation =
      '\$_animationsPath/placeholder.json';

  // Translations
  static const String enTranslations = '\$_translationsPath/en.json';
}
''',
    );
  }

  /// Smallest valid PNG: 1x1 transparent pixel.
  List<int> _transparentPngBytes() => [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
        0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82,
      ];

  String _emptyLottieJson() => '''
{
  "v": "5.5.7",
  "fr": 30,
  "ip": 0,
  "op": 30,
  "w": 100,
  "h": 100,
  "nm": "placeholder",
  "ddd": 0,
  "assets": [],
  "layers": []
}
''';
}