import '../../models/project_config.dart';
import 'extras_generator.dart';

class TestsGenerator extends ExtrasGenerator {
  TestsGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await fileWriter.createDirectory('test/core');
    await fileWriter.createDirectory('test/features/sample');

    final featureTestPath = switch (config.architecture) {
      Architecture.cleanArchitecture => 'test/features/sample/domain',
      Architecture.featureFirst => 'test/features/sample',
    };
    await fileWriter.createDirectory(featureTestPath);

    await fileWriter.writeFile(
      '$featureTestPath/sample_test.dart',
      _sampleTestContent(),
    );
  }

  String _sampleTestContent() => '''
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sample', () {
    test('placeholder', () {
      expect(true, isTrue);
    });
  });
}
''';
}