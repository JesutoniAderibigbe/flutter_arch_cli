import '../../models/project_config.dart';
import 'architecture_generator.dart';

class CleanArchitectureGenerator extends ArchitectureGenerator {
  CleanArchitectureGenerator({
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
    await fileWriter.createDirectory('lib/core/errors');
    await fileWriter.createDirectory('lib/core/utils');

    await fileWriter.writeFile(
      'lib/core/errors/failures.dart',
      _failuresContent(),
    );
    await fileWriter.writeFile(
      'lib/core/errors/exceptions.dart',
      _exceptionsContent(),
    );
  }

  Future<void> _createSampleFeature() async {
    const feature = 'sample';
    final basePath = 'lib/features/$feature';

    await fileWriter.createDirectory('$basePath/data/datasources');
    await fileWriter.createDirectory('$basePath/data/models');
    await fileWriter.createDirectory('$basePath/data/repositories');
    await fileWriter.createDirectory('$basePath/domain/entities');
    await fileWriter.createDirectory('$basePath/domain/repositories');
    await fileWriter.createDirectory('$basePath/domain/usecases');
    await fileWriter.createDirectory('$basePath/presentation/pages');
    await fileWriter.createDirectory('$basePath/presentation/widgets');

    final smFolder = switch (config.stateManagement) {
      StateManagement.riverpod => 'providers',
      StateManagement.bloc => 'bloc',
      StateManagement.provider => 'providers',
    };
    await fileWriter.createDirectory('$basePath/presentation/$smFolder');

    await fileWriter.writeFile(
      '$basePath/domain/entities/sample_entity.dart',
      _sampleEntityContent(),
    );
    await fileWriter.writeFile(
      '$basePath/domain/repositories/sample_repository.dart',
      _sampleRepositoryAbstractContent(),
    );
    await fileWriter.writeFile(
      '$basePath/data/models/sample_model.dart',
      _sampleModelContent(),
    );
  }

  String _failuresContent() => '''
abstract class Failure {
  const Failure(this.message);
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
''';

  String _exceptionsContent() => '''
class ServerException implements Exception {
  const ServerException(this.message);
  final String message;
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
}
''';

  String _sampleEntityContent() => '''
class SampleEntity {
  const SampleEntity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
''';

  String _sampleRepositoryAbstractContent() => '''
import '../entities/sample_entity.dart';

abstract class SampleRepository {
  Future<List<SampleEntity>> getSamples();
  Future<SampleEntity> getSampleById(String id);
}
''';

  String _sampleModelContent() => '''
import '../../domain/entities/sample_entity.dart';

class SampleModel extends SampleEntity {
  const SampleModel({
    required super.id,
    required super.name,
  });

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    return SampleModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
''';
}