import '../../models/project_config.dart';
import '../../utils/file_writer.dart';

class MainDartGenerator {
  MainDartGenerator({
    required this.config,
    required this.fileWriter,
  });

  final ProjectConfig config;
  final FileWriter fileWriter;

  Future<void> generate() async {
    await fileWriter.writeFile('lib/main.dart', _mainContent());
    await fileWriter.writeFile(_sampleScreenPath(), _sampleScreenContent());
  }

  String _sampleScreenPath() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture =>
        'lib/features/sample/presentation/pages/sample_page.dart',
      Architecture.featureFirst =>
        'lib/features/sample/pages/sample_page.dart',
    };
  }

  String _sampleStateImportPath() {
    final folder = switch (config.stateManagement) {
      StateManagement.riverpod => 'providers',
      StateManagement.bloc => 'bloc',
      StateManagement.provider => 'providers',
    };
    return switch (config.architecture) {
      Architecture.cleanArchitecture =>
        'package:${config.projectName}/features/sample/presentation/$folder',
      Architecture.featureFirst =>
        'package:${config.projectName}/features/sample/$folder',
    };
  }

  String _mainContent() {
    final imports = <String>{
      "import 'package:flutter/material.dart';",
    };
    final initLines = <String>[];
    final appWrapperOpen = StringBuffer();
    final appWrapperClose = StringBuffer();

    if (config.extras.contains(Extra.theming)) {
      imports.add(
        "import 'package:${config.projectName}/core/theme/app_theme.dart';",
      );
    }

    // Storage inits
  if (config.storageOptions.contains(Storage.sharedPreferences)) {
      imports.add(
        "import 'package:${config.projectName}/core/storage/preferences_service.dart';",
      );
      imports.add("import 'package:flutter/foundation.dart';");
      initLines.add('  final preferencesService = await PreferencesService.init();');
      initLines.add(
        "  debugPrint('PreferencesService ready: \${preferencesService.runtimeType}');",
      );
    }
    if (config.storageOptions.contains(Storage.hive)) {
      imports.add(
        "import 'package:${config.projectName}/core/storage/hive_service.dart';",
      );
      initLines.add('  await HiveService.instance.init();');
    }
    if (config.storageOptions.contains(Storage.isar)) {
      imports.add(
        "import 'package:${config.projectName}/core/storage/isar_service.dart';",
      );
      initLines.add('  // TODO: call IsarService.instance.init(schemas: [...]);');
    }
    if (config.storageOptions.contains(Storage.sqflite)) {
      imports.add(
        "import 'package:${config.projectName}/core/storage/database_service.dart';",
      );
      initLines.add('  await DatabaseService.instance.init();');
    }

    // State management wrapping
    final sampleImport = _sampleStateImportPath();
    switch (config.stateManagement) {
      case StateManagement.riverpod:
        imports.add("import 'package:flutter_riverpod/flutter_riverpod.dart';");
        appWrapperOpen.write('ProviderScope(child: ');
        appWrapperClose.write(')');
        break;
      case StateManagement.bloc:
        imports.add("import 'package:flutter_bloc/flutter_bloc.dart';");
        imports.add("import '$sampleImport/sample_bloc.dart';");
        appWrapperOpen.write(
          'MultiBlocProvider(providers: [BlocProvider(create: (_) => SampleBloc())], child: ',
        );
        appWrapperClose.write(')');
        break;
      case StateManagement.provider:
        imports.add("import 'package:provider/provider.dart';");
        imports.add("import '$sampleImport/sample_provider.dart';");
        appWrapperOpen.write(
          'MultiProvider(providers: [ChangeNotifierProvider(create: (_) => SampleProvider())], child: ',
        );
        appWrapperClose.write(')');
        break;
    }

    imports.add("import '${_samplePageImport()}';");

    final themePart = config.extras.contains(Extra.theming)
        ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,'''
        : '';

    final sortedImports = imports.toList()..sort();
    final initBlock = initLines.isEmpty ? '' : '\n${initLines.join('\n')}';
    final mainBody = initLines.isEmpty
        ? '  runApp(${appWrapperOpen}const MyApp()${appWrapperClose});'
        : '$initBlock\n  runApp(${appWrapperOpen}const MyApp()${appWrapperClose});';

    return '''
${sortedImports.join('\n')}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
$mainBody
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.projectName}',
      debugShowCheckedModeBanner: false,$themePart
      home: const SamplePage(),
    );
  }
}
''';
  }

  String _samplePageImport() {
    return switch (config.architecture) {
      Architecture.cleanArchitecture =>
        'package:${config.projectName}/features/sample/presentation/pages/sample_page.dart',
      Architecture.featureFirst =>
        'package:${config.projectName}/features/sample/pages/sample_page.dart',
    };
  }

  String _sampleScreenContent() {
    return switch (config.stateManagement) {
      StateManagement.riverpod => _riverpodSamplePage(),
      StateManagement.bloc => _blocSamplePage(),
      StateManagement.provider => _providerSamplePage(),
    };
  }

  String _riverpodSamplePage() {
    final providerImport = switch (config.architecture) {
      Architecture.cleanArchitecture =>
        '../providers/sample_provider.dart',
      Architecture.featureFirst => '../providers/sample_provider.dart',
    };
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '$providerImport';

class SamplePage extends ConsumerWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sampleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sample')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: \${state.error}'))
              : ListView(
                  children: state.items
                      .map((e) => ListTile(title: Text(e)))
                      .toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(sampleProvider.notifier).loadSamples(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';
  }

  String _blocSamplePage() {
    final blocImport = switch (config.architecture) {
      Architecture.cleanArchitecture => '../bloc',
      Architecture.featureFirst => '../bloc',
    };
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '$blocImport/sample_bloc.dart';
import '$blocImport/sample_event.dart';
import '$blocImport/sample_state.dart';

class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample')),
      body: BlocBuilder<SampleBloc, SampleState>(
        builder: (context, state) {
          if (state is SampleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SampleError) {
            return Center(child: Text('Error: \${state.message}'));
          }
          if (state is SampleLoaded) {
            return ListView(
              children: state.items
                  .map((e) => ListTile(title: Text(e)))
                  .toList(),
            );
          }
          return const Center(child: Text('Tap refresh to load.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<SampleBloc>().add(const SamplesRequested()),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';
  }

  String _providerSamplePage() {
    final providerImport = switch (config.architecture) {
      Architecture.cleanArchitecture => '../providers/sample_provider.dart',
      Architecture.featureFirst => '../providers/sample_provider.dart',
    };
    return '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '$providerImport';

class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SampleProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sample')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('Error: \${provider.error}'))
              : ListView(
                  children: provider.items
                      .map((e) => ListTile(title: Text(e)))
                      .toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SampleProvider>().loadSamples(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';
  }
}