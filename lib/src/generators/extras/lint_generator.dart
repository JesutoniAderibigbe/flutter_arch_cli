import 'extras_generator.dart';

class LintGenerator extends ExtrasGenerator {
  LintGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await fileWriter.writeFile(
      'analysis_options.yaml',
      _analysisOptionsContent(),
    );
  }

  String _analysisOptionsContent() => '''
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"
    - "**/*.mocks.dart"
    - "build/**"
    - ".dart_tool/**"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    flutter_style_todos: false
    prefer_const_constructors: false
    avoid_redundant_argument_values: false
    sort_pub_dependencies: false
    always_use_package_imports: false
''';
}