import 'state_management_generator.dart';

class RiverpodGenerator extends StateManagementGenerator {
  RiverpodGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    if (config.useCodegen) {
      await _generateCodegenFlavor();
    } else {
      await _generateManualFlavor();
    }
  }

  Future<void> _generateManualFlavor() async {
    await fileWriter.writeFile(
      '$featureBasePath/sample_provider.dart',
      _manualProviderContent(),
    );
  }

  Future<void> _generateCodegenFlavor() async {
    await fileWriter.writeFile(
      '$featureBasePath/sample_state.dart',
      _freezedStateContent(),
    );
    await fileWriter.writeFile(
      '$featureBasePath/sample_provider.dart',
      _codegenProviderContent(),
    );
  }

  String _manualProviderContent() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SampleState {
  const SampleState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  final bool isLoading;
  final List<String> items;
  final String? error;

  SampleState copyWith({
    bool? isLoading,
    List<String>? items,
    String? error,
  }) {
    return SampleState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class SampleNotifier extends StateNotifier<SampleState> {
  SampleNotifier() : super(const SampleState());

  Future<void> loadSamples() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(
        isLoading: false,
        items: const ['Sample 1', 'Sample 2', 'Sample 3'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final sampleProvider = StateNotifierProvider<SampleNotifier, SampleState>(
  (ref) => SampleNotifier(),
);
''';

  String _freezedStateContent() => '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_state.freezed.dart';

@freezed
class SampleState with _\$SampleState {
  const factory SampleState({
    @Default(false) bool isLoading,
    @Default(<String>[]) List<String> items,
    String? error,
  }) = _SampleState;
}
''';

  String _codegenProviderContent() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sample_state.dart';

part 'sample_provider.g.dart';

@riverpod
class Sample extends _\$Sample {
  @override
  SampleState build() => const SampleState();

  Future<void> loadSamples() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(
        isLoading: false,
        items: const ['Sample 1', 'Sample 2', 'Sample 3'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
''';
}