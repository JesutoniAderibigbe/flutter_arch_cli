import 'state_management_generator.dart';

class ProviderGenerator extends StateManagementGenerator {
  ProviderGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    await fileWriter.writeFile(
      '$featureBasePath/sample_provider.dart',
      _providerContent(),
    );
  }

  String _providerContent() => '''
import 'package:flutter/foundation.dart';

class SampleProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<String> _items = const [];
  String? _error;

  bool get isLoading => _isLoading;
  List<String> get items => _items;
  String? get error => _error;

  Future<void> loadSamples() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: replace with real data source call.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _items = const ['Sample 1', 'Sample 2', 'Sample 3'];
    } catch (e) {e
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
''';
}