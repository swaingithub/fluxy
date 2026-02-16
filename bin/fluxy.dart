import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:fluxy/src/cli/cloud.dart';

const String version = '0.1.10';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('init')
    ..addCommand('generate')
    ..addCommand('g')
    ..addCommand('run')
    ..addCommand('doctor')
    ..addCommand('build')
    ..addCommand('deploy')
    ..addCommand('cloud')
    ..addCommand('serve');

  parser.addFlag('help', abbr: 'h', negatable: false);
  parser.addFlag('version', abbr: 'v', negatable: false);
  parser.addOption('port', abbr: 'p', defaultsTo: '8080');

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
    case 'generate':
    case 'g':
      await _handleGenerate(command.rest);
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
    case 'serve':
      await _handleServe(command);
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
  print('  init <name>      Scaffold a complete Fluxy application (Expo-style).');
  print('  generate <feat>  (g) Create a new feature domain with full architecture.');
  print('  run              Launch the application.');
  print('  serve            Start a local OTA development server.');
  print('  build            Compile the application.');
  print('  cloud            Configure GitHub Actions CI/CD.');
}

Future<void> _handleInit(List<String> args) async {
  if (args.isEmpty) {
    print('Error: Name required. Usage: fluxy init <project_name>');
    exit(1);
  }

  final projectName = args.first;
  print('🚀 Scaffolding Fluxy Application: $projectName...');

  final result = await Process.run('flutter', ['create', projectName], runInShell: true);
  if (result.exitCode != 0) {
    print('Error creating Flutter project: ${result.stderr}');
    exit(1);
  }

  final projectDir = Directory(projectName);
  final libDir = Directory(p.join(projectDir.path, 'lib'));

  print('🏛️ Organizing Architecture (core/features)...');
  if (libDir.existsSync()) libDir.deleteSync(recursive: true);
  libDir.createSync();
  
  final coreDir = Directory(p.join(libDir.path, 'core'))..createSync();
  Directory(p.join(libDir.path, 'features')).createSync();

  // Create Core Sub-dirs
  Directory(p.join(coreDir.path, 'theme')).createSync();
  Directory(p.join(coreDir.path, 'routing')).createSync();

  print('📦 Injecting Fluxy dependencies...');
  await Process.run('flutter', ['pub', 'add', 'fluxy'], workingDirectory: projectDir.path, runInShell: true);

  // Write Templates
  File(p.join(libDir.path, 'main.dart')).writeAsStringSync(_fluxyMainTemplate);
  File(p.join(coreDir.path, 'theme', 'app_theme.dart')).writeAsStringSync(_coreThemeTemplate);
  
  print('🏠 Building starter home feature...');
  await _createFeature(projectDir.path, 'home');

  print('\n🎉 Success! Fluxy project "$projectName" created successfully.');
  print('cd $projectName\nfluxy run');
}

Future<void> _handleGenerate(List<String> args) async {
  if (args.isEmpty) {
    print('Error: Feature name required.');
    return;
  }
  final name = args.first.toLowerCase();
  final type = args.length > 1 ? args[1].toLowerCase() : 'default';
  
  await _createFeature('.', name, type: type);
}

Future<void> _createFeature(String path, String name, {String type = 'default'}) async {
  final featDir = Directory(p.join(path, 'lib', 'features', name))..createSync(recursive: true);
  final camel = name[0].toUpperCase() + name.substring(1);

  if (type == 'login') {
    _createLoginBlueprint(featDir, name, camel);
  } else if (type == 'feed') {
    _createFeedBlueprint(featDir, name, camel);
  } else {
    _createDefaultBlueprint(featDir, name, camel);
  }

  print('✅ Generated $type feature: $name');
}

void _createLoginBlueprint(Directory dir, String name, String camel) {
  // 1. Repository
  File(p.join(dir.path, '$name.repository.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Repository extends FluxRepository<bool> {
  @override
  Future<bool> fetchRemote() async {
    // Simulate auth check
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }

  Future<void> login(String email, String password) async {
    // Zero-dependency FluxyHttp!
    await Fluxy.http.post('/auth/login', body: {'email': email, 'password': password});
  }

  @override
  Future<bool> fetchLocal() async => false;
  @override
  Future<void> saveLocal(bool data) async {}
}
''');

  // 2. Controller
  File(p.join(dir.path, '$name.controller.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.repository.dart';

class ${camel}Controller extends FluxController {
  final repo = ${camel}Repository();
  
  final email = flux("");
  final password = flux("");
  final isLoading = flux(false);

  Future<void> submit() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Fx.toast.error("Please fill all fields");
      return;
    }

    isLoading.value = true;
    try {
      await repo.login(email.value, password.value);
      Fx.toast.success("Welcome back!");
      Fluxy.offAll('/home');
    } catch (e) {
      Fx.toast.error("Login failed: \$e");
    } finally {
      isLoading.value = false;
    }
  }
}
''');

  // 3. View
  File(p.join(dir.path, '$name.view.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '$name.controller.dart';

class ${camel}View extends StatelessWidget {
  const ${camel}View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<${camel}Controller>();

    return Scaffold(
      body: Fx.center(
        child: Fx.container(
          maxWidth: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Fx.text('LOGIN').font.xl3().bold().letterSpacing(4),
              Fx.text('Enter your credentials').muted(),
              Fx.gap(40),
              
              Fx.input(
                signal: controller.email, 
                placeholder: 'Email',
                icon: Icons.email_outlined,
              ),
              Fx.gap(16),
              Fx.password(
                signal: controller.password,
                placeholder: 'Password',
              ),
              Fx.gap(24),
              
              Fx(() => Fx.button(
                controller.isLoading.value ? 'PROCESSING...' : 'SIGN IN',
                onTap: controller.submit,
              ).w(double.infinity).background(Colors.black)),
              
              Fx.gap(16),
              Fx.textButton('Forgot Password?', onTap: () {}),
            ],
          ).p(24),
        ),
      ),
    );
  }
}
''');

  // 4. Routes
  _createRoutesFile(dir, name, camel);
}

void _createFeedBlueprint(Directory dir, String name, String camel) {
  // 1. Repository
  File(p.join(dir.path, '$name.repository.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Repository extends FluxRepository<List<String>> {
  @override
  Future<List<String>> fetchRemote() async {
    final response = await Fluxy.http.get('/posts');
    return List<String>.from(response.data.map((e) => e['title']));
  }

  @override
  Future<List<String>> fetchLocal() async => [];
  @override
  Future<void> saveLocal(List<String> data) async {}
}
''');

  // 2. Controller
  File(p.join(dir.path, '$name.controller.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.repository.dart';

class ${camel}Controller extends FluxController {
  final repo = ${camel}Repository();
  final items = flux(<String>[]);
  final isLoading = flux(true);

  @override
  void onInit() async {
    super.onInit();
    await refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    items.value = await repo.sync();
    isLoading.value = false;
  }
}
''');

  // 3. View
  File(p.join(dir.path, '$name.view.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '$name.controller.dart';

class ${camel}View extends StatelessWidget {
  const ${camel}View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<${camel}Controller>();

    return Scaffold(
      appBar: AppBar(title: Fx.text('$camel').bold()),
      body: Fx(() {
        if (controller.isLoading.value) {
          return Fx.list(
            itemCount: 5,
            itemBuilder: (_, __) => Fx.loader.shimmer(height: 80).m(16),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: Fx.list(
            itemCount: controller.items.value.length,
            itemBuilder: (context, index) {
              final item = controller.items.value[index];
              return Fx.box(
                style: FxStyle(
                  padding: const EdgeInsets.all(16), 
                  borderBottom: BorderSide(color: Colors.grey.shade200),
                ),
                child: Fx.text(item).bold(),
              );
            },
          ),
        );
      }),
    );
  }
}
''');

  // 4. Routes
  _createRoutesFile(dir, name, camel);
}

void _createDefaultBlueprint(Directory dir, String name, String camel) {
  // 1. Repository
  File(p.join(dir.path, '$name.repository.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';

class ${camel}Repository extends FluxRepository<String> {
  @override
  Future<String> fetchRemote() async {
    final response = await Fluxy.http.get('/data');
    return response.data['message'] ?? "Fluxy Engine Active";
  }

  @override
  Future<String> fetchLocal() async => "Offline Cache Ready";
  
  @override
  Future<void> saveLocal(String data) async {}
}
''');

  // 2. Controller
  File(p.join(dir.path, '$name.controller.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.repository.dart';

class ${camel}Controller extends FluxController {
  final repo = ${camel}Repository();
  final count = flux(0, persistKey: 'counter_$name');
  final status = flux("Booting...");

  @override
  void onInit() async {
    super.onInit();
    status.value = await repo.sync();
  }
  
  void increment() => count.value++;
}
''');

  // 3. View
  File(p.join(dir.path, '$name.view.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '$name.controller.dart';

class ${camel}View extends StatelessWidget {
  const ${camel}View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<${camel}Controller>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fx.text('FLUXY').font.xl4().bold().letterSpacing(8).color(Colors.blue),
            Fx.text('FRAMEWORK').font.sm().letterSpacing(4).muted(),
            Fx.gap(60),
            Fx.text('$camel Feature Scaffolding').font.lg().bold(),
            Fx.gap(10),
            Fx(() => Fx.text(controller.status.value)).muted().italic(),
            Fx.gap(40),
            Fx(() => Fx.text('\${controller.count.value}')).font.xl4().bold().animate(fade: 0),
            Fx.gap(20),
            Fx.button('INCREMENT', onTap: controller.increment)
              .w(160).rounded(0).background(Colors.black),
            Fx.gap(100),
            Fx.text('Structural Authority for Flutter').font.xs().muted().letterSpacing(1),
          ],
        ),
      ),
    );
  }
}
''');

  // 4. Routes
  _createRoutesFile(dir, name, camel);
}

void _createRoutesFile(Directory dir, String name, String camel) {
  File(p.join(dir.path, '$name.routes.dart')).writeAsStringSync('''
import 'package:fluxy/fluxy.dart';
import '$name.view.dart';
import '$name.controller.dart';

final ${name}Routes = [
  FxRoute(
    path: '/$name',
    controller: () => ${camel}Controller(),
    builder: (params, args) => const ${camel}View(),
  ),
];
''');
}

Future<void> _handleServe(ArgResults command) async {
  final port = int.tryParse(command['port'] ?? '8080') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('📡 Fluxy OTA Server running at http://localhost:$port');
  print('Watching ./ota directory for updates...');

  final otaDir = Directory('ota');
  if (!otaDir.existsSync()) {
    otaDir.createSync();
    File(p.join(otaDir.path, 'manifest.json')).writeAsStringSync('''
{
  "version": 1,
  "assets": {
    "home.json": "http://localhost:$port/home.json"
  }
}
''');
    File(p.join(otaDir.path, 'home.json')).writeAsStringSync('''
{
  "type": "box",
  "style": { "padding": 20, "backgroundColor": "#ffffff" },
  "children": [
    { "type": "text", "data": "Hello from Fluxy Live OTA!", "style": { "fontSize": 20, "fontWeight": "bold" } },
    { "type": "text", "data": "Try changing the JSON and refresh." }
  ]
}
''');
  }

  await for (HttpRequest request in server) {
    final path = request.uri.path == '/' ? '/manifest.json' : request.uri.path;
    final file = File(p.join(otaDir.path, path.substring(1)));

    if (await file.exists()) {
      request.response.headers.contentType = ContentType.json;
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      await file.openRead().pipe(request.response);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Asset Not Found: $path');
      await request.response.close();
    }
  }
}

Future<void> _handleRun(List<String> args) async {
  await Process.start('flutter', ['run', ...args], mode: ProcessStartMode.inheritStdio, runInShell: true);
}

Future<void> _handleDoctor() async {
  print('🩺 Fluxy Framework Doctor v$version');
  await Process.start('flutter', ['doctor'], mode: ProcessStartMode.inheritStdio, runInShell: true);
}

Future<void> _handleBuild(List<String> args) async {
  if (args.isEmpty) return;
  await Process.start('flutter', ['build', ...args], mode: ProcessStartMode.inheritStdio, runInShell: true);
}

Future<void> _handleDeploy() async => print('🚀 Deployment coming soon!');

const String _fluxyMainTemplate = """
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home.routes.dart';

void main() async {
  await Fluxy.init();
  
  runApp(FluxyApp(
    title: 'Fluxy App',
    theme: AppTheme.light,
    initialRoute: homeRoutes.first,
    routes: [
      ...homeRoutes,
    ],
  ));
}
""";

const String _coreThemeTemplate = """
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );
}
""";
