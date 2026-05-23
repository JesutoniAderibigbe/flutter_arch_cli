import 'extras_generator.dart';

class ThemingGenerator extends ExtrasGenerator {
  ThemingGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await fileWriter.createDirectory('lib/core/theme');

    await fileWriter.writeFile(
      'lib/core/theme/app_colors.dart',
      _colorsContent(),
    );
    await fileWriter.writeFile(
      'lib/core/theme/app_theme.dart',
      _themeContent(),
    );
  }

  String _colorsContent() => '''
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color error = Color(0xFFD32F2F);

  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color darkBackground = Color(0xFF121212);
}
''';

  String _themeContent() => '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: const AppBarTheme(centerTitle: true),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}
''';
}