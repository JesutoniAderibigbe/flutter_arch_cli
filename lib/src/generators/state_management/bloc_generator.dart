import 'state_management_generator.dart';

class BlocGenerator extends StateManagementGenerator {
  BlocGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await fileWriter.writeFile(
      '$featureBasePath/sample_event.dart',
      _eventContent(),
    );
    await fileWriter.writeFile(
      '$featureBasePath/sample_state.dart',
      _stateContent(),
    );
    await fileWriter.writeFile(
      '$featureBasePath/sample_bloc.dart',
      _blocContent(),
    );
  }

  String _eventContent() => '''
abstract class SampleEvent {
  const SampleEvent();
}

class SamplesRequested extends SampleEvent {
  const SamplesRequested();
}
''';

  String _stateContent() => '''
abstract class SampleState {
  const SampleState();
}

class SampleInitial extends SampleState {
  const SampleInitial();
}

class SampleLoading extends SampleState {
  const SampleLoading();
}

class SampleLoaded extends SampleState {
  const SampleLoaded(this.items);
  final List<String> items;
}

class SampleError extends SampleState {
  const SampleError(this.message);
  final String message;
}
''';

  String _blocContent() => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sample_event.dart';
import 'sample_state.dart';

class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc() : super(const SampleInitial()) {
    on<SamplesRequested>(_onSamplesRequested);
  }

  Future<void> _onSamplesRequested(
    SamplesRequested event,
    Emitter<SampleState> emit,
  ) async {
    emit(const SampleLoading());
    try {
      // TODO: replace with real data source call.
    await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(const SampleLoaded(['Sample 1', 'Sample 2', 'Sample 3']));
    } catch (e) {
      emit(SampleError(e.toString()));
    }
  }
}
''';
}