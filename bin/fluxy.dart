import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'package:fluxy/src/cli/cloud.dart';

const String version = '0.1.2';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('init')
    ..addCommand('run')
    ..addCommand('doctor')
    ..addCommand('build')
    ..addCommand('deploy')
    ..addCommand('cloud');

  // Handle flags
  parser.addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information.');
  parser.addFlag('version', abbr: 'v', negatable: false, help: 'Show version.');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    printUsage(parser);
    exit(1);
  }

  if (argResults['help']) {
    printUsage(parser);
    return;
  }

  if (argResults['version']) {
    print('Fluxy CLI v$version');
    return;
  }

  final command = argResults.command;
  if (command == null) {
    printUsage(parser);
    return;
  }

  switch (command.name) {
    case 'init':
      await _handleInit(command.rest);
      break;
    case 'run':
      await _handleRun(command.rest);
      break;
    case 'doctor':
      await _handleDoctor();
      break;
    case 'build':
      await _handleBuild(command.rest);
      break;
    case 'deploy':
      await _handleDeploy();
      break;
    case 'cloud':
      await FluxyCloud.handle(command.rest);
      break;
    default:
      print('Unknown command: ${command.name}');
      printUsage(parser);
  }
}

void printUsage(ArgParser parser) {
  print('Fluxy CLI - The Ultimate Flutter Framework Tool\n');
  print('Usage: fluxy <command> [arguments]\n');
  print('Commands:');
  print('  init <name>   Create a new Fluxy project.');
  print('  run           Run the app (wraps flutter run).');
  print('  build         Build the app (wraps flutter build).');
  print('  doctor        Check environment status.');
  print('  deploy        Deploy the app (manual).');
  print('  cloud         Manage cloud builds (GitHub Actions).');
  print('\nOptions:');
  print(parser.usage);
}

Future<void> _handleInit(List<String> args) async {
  if (args.isEmpty) {
    print('Error: Please provide a project name.');
    print('Usage: fluxy init <project_name>');
    exit(1);
  }

  final projectName = args.first;
  print('🚀 Creating Fluxy project: $projectName...');

  // 1. Flutter Create
  final result = await Process.run('flutter', ['create', projectName], runInShell: true);
  if (result.exitCode != 0) {
    print('Error creating Flutter project:');
    print(result.stderr);
    exit(1);
  }
  print('✅ Basic Flutter scaffold created.');

  final projectDir = Directory(projectName);
  if (!projectDir.existsSync()) {
    print('Error: Project directory not found.');
    exit(1);
  }

  // 2. Add Fluxy Dependency
  print('📦 Adding fluxy dependency...');
  final pubResult = await Process.run(
    'flutter', 
    ['pub', 'add', 'fluxy', 'provider', 'shared_preferences', 'flutter_secure_storage'], 
    workingDirectory: projectDir.path,
    runInShell: true,
  );
  
  if (pubResult.exitCode != 0) {
    print('Warning: Failed to add dependencies automatically. You may need to add "fluxy" manually.');
    print(pubResult.stderr);
  }

  // 3. Replace main.dart with Fluxy Template
  final mainFile = File(p.join(projectDir.path, 'lib', 'main.dart'));
  if (mainFile.existsSync()) {
    mainFile.writeAsStringSync(_fluxyStarterTemplate);
    print('✨ Fluxy starter template applied.');
  }

  print('\n🎉 Success! Project $projectName is ready.');
  print('cd $projectName');
  print('fluxy run');
}

Future<void> _handleRun(List<String> args) async {
  print('🚀 Launching Fluxy App...');
  // Wrap flutter run
  final process = await Process.start('flutter', ['run', ...args], mode: ProcessStartMode.inheritStdio, runInShell: true);
  final exitCode = await process.exitCode;
  if (exitCode != 0) exit(exitCode);
}

Future<void> _handleDoctor() async {
  print('🩺 Fluxy Doctor\n');
  print('Fluxy CLI Version: $version');
  
  print('\nChecking Flutter...');
  final flutterResult = await Process.run('flutter', ['--version'], runInShell: true);
  if (flutterResult.exitCode == 0) {
    print(flutterResult.stdout);
  } else {
    print('❌ Flutter not found or error executing.');
  }
  
  print('\nChecking Doctor...');
  final process = await Process.start('flutter', ['doctor'], mode: ProcessStartMode.inheritStdio, runInShell: true);
  await process.exitCode;
}

Future<void> _handleBuild(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: fluxy build <apk|ios|web|appbundle> [args]');
    return;
  }
  
  final target = args.first;
  print('🏗️ Building for $target...');
  
  final buildArgs = ['build', target, ...args.skip(1)];
  
  // Add optimization flags automatically if release
  if (!args.contains('--debug') && !args.contains('--profile')) {
    if (!buildArgs.contains('--release')) buildArgs.add('--release');
    // Obfuscation recommendations
    // buildArgs.add('--obfuscate');
    // buildArgs.add('--split-debug-info=./debug-info');
  }

  final process = await Process.start('flutter', buildArgs, mode: ProcessStartMode.inheritStdio, runInShell: true);
  final exitCode = await process.exitCode;
  if (exitCode != 0) exit(exitCode);
  
  print('✅ Build Complete!');
}

Future<void> _handleDeploy() async {
  print('🚀 Deployment integrations (Firebase, TestFlight, Play Store) are coming in Phase 5!');
  print('For now, use manual upload of the artifacts generated in "build".');
}

// --- Templates ---

const String _fluxyStarterTemplate = '''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FluxyPersistence.init(); // Initialize Persistence
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluxyApp(
      title: 'Fluxy Starter',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute: FxRoute(path: '/', builder: (_, __) => const HomePage()),
      routes: [
        FxRoute(path: '/', builder: (_, __) => const HomePage()),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = flux(0); // Reactive Signal
    
    return Scaffold(
      appBar: AppBar(title: const Text('Fluxy Starter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fx.text('Hello Fluxy! 🚀', style: const FxStyle(fontSize: 24, fontWeight: FontWeight.bold))
              .animate(fade: 0.0, slide: const Offset(0, -20), spring: Spring.bouncy),
            const SizedBox(height: 20),
            Fx.text(() => 'Count: \${counter.value}', style: const FxStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counter.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
