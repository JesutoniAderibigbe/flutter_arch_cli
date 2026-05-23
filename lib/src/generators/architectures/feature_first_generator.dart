import '../../models/project_config.dart';
import 'architecture_generator.dart';

class FeatureFirstGenerator extends ArchitectureGenerator {
  FeatureFirstGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await _createCoreLayer();
    await _createSampleFeature();
  }

  Future<void> _createCoreLayer() async {
    await fileWriter.createDirectory('lib/core/constants');
    await fileWriter.createDirectory('lib/core/utils');
    await fileWriter.createDirectory('lib/core/errors');

    await fileWriter.writeFile(
      'lib/core/errors/app_exception.dart',
      _appExceptionContent(),
    );
  }

  Future<void> _createSampleFeature() async {
    const feature = 'sample';
    final basePath = 'lib/features/$feature';

    final smFolder = switch (config.stateManagement) {
      StateManagement.riverpod => 'providers',
      StateManagement.bloc => 'bloc',
      StateManagement.provider => 'providers',
    };

    await fileWriter.createDirectory('$basePath/models');
    await fileWriter.createDirectory('$basePath/repository');
    await fileWriter.createDirectory('$basePath/pages');
    await fileWriter.createDirectory('$basePath/widgets');
    await fileWriter.createDirectory('$basePath/$smFolder');

    await fileWriter.writeFile(
      '$basePath/models/sample.dart',
      _sampleModelContent(),
    );
    await fileWriter.writeFile(
      '$basePath/repository/sample_repository.dart',
      _sampleRepositoryContent(),
    );
  }

  String _appExceptionContent() => '''
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => 'AppException: \$message';
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
''';

  String _sampleModelContent() => '''
class Sample {
  const Sample({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
''';

  String _sampleRepositoryContent() => '''
import '../models/sample.dart';

class SampleRepository {
  Future<List<Sample>> getSamples() async {
    // TODO: implement
    return [];
  }

  Future<Sample> getSampleById(String id) async {
    // TODO: implement
    throw UnimplementedError();
  }
}
''';
}